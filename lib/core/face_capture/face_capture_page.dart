import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../environment/app_environment.dart';
import '../errors/error_codes.dart';
import '../localization/error_localizer.dart';
import '../ui_kit/feedback/app_error_state.dart';
import '../ui_kit/feedback/app_loading_indicator.dart';
import '../ui_kit/tokens/app_motion.dart';
import '../ui_kit/tokens/app_radius.dart';
import '../ui_kit/tokens/app_sizing.dart';
import '../ui_kit/tokens/app_spacing.dart';
import '../utils/app_camera_permission.dart';
import '../widgets/camera_permission_view.dart';
import 'detection/face_capture_assessment.dart';
import 'detection/face_capture_detector.dart';
import 'detection/face_capture_evaluator.dart';
import 'detection/face_capture_geometry.dart';
import 'detection/face_sample.dart';
import 'detection/face_stability_tracker.dart';
import 'face_capture_config.dart';
import 'face_capture_result.dart';
import 'widgets/face_capture_diagnostics.dart';
import 'widgets/face_capture_guidance_view.dart';
import 'widgets/face_capture_readiness.dart';
import 'widgets/face_capture_ring.dart';
import 'widgets/face_capture_status_panel.dart';
import 'widgets/face_capture_sweep.dart';

// Fixed rather than themed: these sit on top of a live camera image.
const Color _cameraSurfaceColor = Color(0xFF000000);
const Color _onCameraColor = Color(0xFFFFFFFF);
const Color _pillColor = Color(0x66000000);

/// The most frames per second worth detecting on.
///
/// ML Kit is fast but not free, and a camera delivers 30+ frames a
/// second. Roughly nine is far more than enough for a human holding
/// still, and it leaves the UI thread alone.
const Duration _minFrameInterval = Duration(milliseconds: 110);

/// What the scanner is currently doing.
enum _Stage {
  checkingPermission,
  permissionRequired,
  starting,
  detecting,
  capturing,
  captured,
  failed,
}

/// The Core face capture screen.
///
/// Reached through `AppFaceCapture.capture(context)`, so callers only
/// ever deal with a `Future<FaceCaptureResult?>`. It detects a face,
/// scores how ready the shot is, takes the photo itself, and pops with
/// the file — or with null if the user leaves.
///
/// It holds no business logic: it does not know what the photo is for,
/// never uploads it, and never tries to work out who the person is.
class FaceCapturePage extends StatefulWidget {
  final FaceCaptureConfig config;

  const FaceCapturePage({super.key, this.config = const FaceCaptureConfig()});

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage>
    with WidgetsBindingObserver {
  late final FaceCaptureEvaluator _evaluator = FaceCaptureEvaluator(
    orientation: widget.config.orientation,
    smileRequired: widget.config.smileRequired,
    holdDuration: widget.config.holdDuration,
  );

  late final FaceStabilityTracker _tracker = FaceStabilityTracker(
    holdDuration: widget.config.holdDuration,
  );

  _Stage _stage = _Stage.checkingPermission;
  CameraPermissionStatus _permission = CameraPermissionStatus.denied;
  String _errorCode = ErrorCodes.cameraStartFailed;

  CameraController? _controller;
  FaceCaptureDetector? _detector;
  List<CameraDescription> _cameras = const [];
  late FaceCaptureCamera _activeCamera = widget.config.camera;

  late FaceCaptureAssessment _assessment = _evaluator.assess(
    _evaluator.check(const FaceSample.empty()),
    0,
  );

  /// Guards against a second capture: the stream can deliver another
  /// ready frame while the first photo is still being written.
  bool _hasCompleted = false;

  bool _isProcessingFrame = false;
  bool _isSwitchingCamera = false;
  DateTime? _lastProcessedAt;

  /// The most recent detection, for the development-only overlay.
  FaceSample? _lastSample;

  /// Written during build, read by the frame callback, so detection
  /// can express positions in the coordinates the user is looking at.
  Size _surfaceSize = Size.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    unawaited(_resolvePermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // The camera and the detector must not outlive this screen.
    final controller = _controller;
    final detector = _detector;

    _controller = null;
    _detector = null;

    unawaited(_disposeCamera(controller));
    unawaited(detector?.close());

    super.dispose();
  }

  // --------------------------------------------------
  // PERMISSION
  // --------------------------------------------------

  Future<void> _resolvePermission({bool request = true}) async {
    setState(() {
      _stage = _Stage.checkingPermission;
    });

    final status = request
        ? await AppCameraPermission.request()
        : await AppCameraPermission.check();

    if (!mounted) {
      return;
    }

    switch (status) {
      case CameraPermissionStatus.granted:
        await _startCamera();
      case CameraPermissionStatus.unavailable:
        _fail(ErrorCodes.cameraUnavailable);
      case CameraPermissionStatus.denied:
      case CameraPermissionStatus.permanentlyDenied:
      case CameraPermissionStatus.restricted:
        setState(() {
          _stage = _Stage.permissionRequired;
          _permission = status;
        });
    }
  }

  Future<void> _openSettings() async {
    final opened = await AppCameraPermission.openSettings();

    if (!opened && mounted) {
      _fail(ErrorCodes.cameraUnavailable);
    }
  }

  // --------------------------------------------------
  // CAMERA
  // --------------------------------------------------

  Future<void> _startCamera() async {
    setState(() {
      _stage = _Stage.starting;
    });

    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (_) {
        // Broad on purpose: enumerating cameras is platform code and
        // can fail with a CameraException, a MissingPluginException on
        // an unsupported platform, or a raw PlatformException. They
        // all mean the same thing to the user.
        _fail(ErrorCodes.cameraUnavailable);
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final description = _descriptionFor(_activeCamera);

    if (description == null) {
      _fail(ErrorCodes.cameraUnavailable);
      return;
    }

    // The device may not have the camera that was asked for; carry on
    // with what it does have rather than dead-ending the user, and
    // keep the result honest about which one was used.
    _activeCamera = description.lensDirection == CameraLensDirection.front
        ? FaceCaptureCamera.front
        : FaceCaptureCamera.rear;

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: FaceCaptureDetector.preferredImageFormat,
    );

    try {
      await controller.initialize();
    } catch (_) {
      // Same reasoning as above — and the camera must be released
      // whatever went wrong.
      await _disposeCamera(controller);

      if (mounted) {
        _fail(ErrorCodes.cameraStartFailed);
      }

      return;
    }

    if (!mounted) {
      await _disposeCamera(controller);
      return;
    }

    _detector ??= FaceCaptureDetector();

    _resetDetectionState();

    setState(() {
      _controller = controller;
      _stage = _Stage.detecting;
    });

    try {
      await controller.startImageStream(_onFrame);
    } catch (_) {
      if (mounted) {
        _fail(ErrorCodes.cameraStartFailed);
      }
    }
  }

  CameraDescription? _descriptionFor(FaceCaptureCamera camera) {
    if (_cameras.isEmpty) {
      return null;
    }

    final wanted = camera == FaceCaptureCamera.front
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    for (final description in _cameras) {
      if (description.lensDirection == wanted) {
        return description;
      }
    }

    return _cameras.first;
  }

  /// Tears the camera down without touching [_stage], so a resume can
  /// pick up where it left off.
  Future<void> _stopCamera() async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    _controller = null;

    _resetDetectionState();

    // Repaint without the controller *before* disposing it, so the
    // preview is out of the tree by the time its texture goes away.
    if (mounted) {
      setState(() {});
    }

    await _disposeCamera(controller);
  }

  Future<void> _disposeCamera(CameraController? controller) async {
    if (controller == null) {
      return;
    }

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Already stopped, or the platform is gone; disposing below is
      // what actually matters here.
    }

    await controller.dispose();
  }

  void _resetDetectionState() {
    _tracker.reset();
    _isProcessingFrame = false;
    _lastProcessedAt = null;
    _lastSample = null;
    _assessment = _evaluator.assess(
      _evaluator.check(const FaceSample.empty()),
      0,
    );
  }

  Future<void> _switchCamera() async {
    if (_isSwitchingCamera || _hasCompleted) {
      return;
    }

    _isSwitchingCamera = true;

    _activeCamera = _activeCamera == FaceCaptureCamera.front
        ? FaceCaptureCamera.rear
        : FaceCaptureCamera.front;

    try {
      await _stopCamera();

      if (!mounted) {
        return;
      }

      await _startCamera();
    } finally {
      _isSwitchingCamera = false;
    }
  }

  // --------------------------------------------------
  // DETECTION
  // --------------------------------------------------

  Future<void> _onFrame(CameraImage image) async {
    final controller = _controller;
    final detector = _detector;

    if (controller == null ||
        detector == null ||
        _stage != _Stage.detecting ||
        _hasCompleted ||
        _isProcessingFrame ||
        _surfaceSize.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final last = _lastProcessedAt;

    if (last != null && now.difference(last) < _minFrameInterval) {
      return;
    }

    _isProcessingFrame = true;
    _lastProcessedAt = now;

    try {
      final sample = await detector.process(
        image: image,
        camera: controller.description,
        deviceOrientation: controller.value.deviceOrientation,
        surfaceSize: _surfaceSize,
      );

      if (!mounted || _stage != _Stage.detecting || _hasCompleted) {
        return;
      }

      _lastSample = sample;

      final conditions = _evaluator.check(sample);

      final progress = _tracker.update(
        conditionsMet: conditions.allSatisfied,
        now: now,
      );

      final assessment = _evaluator.assess(conditions, progress);
      final isSameOnScreen = assessment.isVisuallySameAs(_assessment);

      _assessment = assessment;

      // Most frames look identical to the one before; only repaint
      // when something the user can see actually changed.
      if (!isSameOnScreen) {
        setState(() {});
      }

      if (assessment.isReady) {
        await _capture();
      }
    } catch (_) {
      // A frame that can't be interpreted is not worth reporting —
      // the next one usually is.
    } finally {
      _isProcessingFrame = false;
    }
  }

  // --------------------------------------------------
  // CAPTURE
  // --------------------------------------------------

  Future<void> _capture() async {
    final controller = _controller;

    if (_hasCompleted || controller == null) {
      return;
    }

    _hasCompleted = true;

    setState(() {
      _stage = _Stage.capturing;
    });

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final file = await controller.takePicture();

      if (!mounted) {
        return;
      }

      unawaited(HapticFeedback.mediumImpact());

      setState(() {
        _stage = _Stage.captured;
      });

      // Long enough to register as "got it", short enough not to feel
      // like waiting.
      await Future<void>.delayed(AppMotion.medium);

      if (!mounted) {
        return;
      }

      context.pop(
        FaceCaptureResult(
          imagePath: file.path,
          orientation: widget.config.orientation,
          camera: _activeCamera,
          capturedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      // Let the user try again rather than dropping them out.
      _hasCompleted = false;
      _fail(ErrorCodes.captureFailed);
    }
  }

  void _fail(String errorCode) {
    setState(() {
      _stage = _Stage.failed;
      _errorCode = errorCode;
    });
  }

  void _cancel() {
    // No result: `AppFaceCapture.capture` completes with null.
    context.pop();
  }

  Future<void> _retry() async {
    await _stopCamera();

    if (!mounted) {
      return;
    }

    _hasCompleted = false;

    await _resolvePermission();
  }

  // --------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _stage == _Stage.permissionRequired) {
      // The user may have granted access in the Settings app.
      unawaited(_resolvePermission(request: false));

      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
        // Never hold the camera while the app is not in front.
        unawaited(_stopCamera());
      case AppLifecycleState.resumed:
        if (_controller == null &&
            !_hasCompleted &&
            (_stage == _Stage.detecting || _stage == _Stage.starting)) {
          unawaited(_startCamera());
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        return;
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _surfaceSize = MediaQuery.sizeOf(context);

    switch (_stage) {
      case _Stage.starting:
      case _Stage.detecting:
      case _Stage.capturing:
      case _Stage.captured:
        return _buildScannerScaffold(context);
      case _Stage.checkingPermission:
      case _Stage.permissionRequired:
      case _Stage.failed:
        return _buildMessageScaffold(context);
    }
  }

  FaceGuideState get _guideState {
    switch (_stage) {
      case _Stage.capturing:
        return FaceGuideState.capturing;
      case _Stage.captured:
        return FaceGuideState.captured;
      default:
        return _assessment.isReady
            ? FaceGuideState.ready
            : FaceGuideState.detecting;
    }
  }

  FaceCaptureGuidance get _guidance {
    switch (_stage) {
      case _Stage.capturing:
        return FaceCaptureGuidance.capturing;
      case _Stage.captured:
        return FaceCaptureGuidance.captured;
      default:
        return _assessment.guidance;
    }
  }

  Widget _buildScannerScaffold(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = _controller;
    final size = _surfaceSize;
    final guide = FaceCaptureGeometry.guideCircle(size);

    final isLive = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: _cameraSurfaceColor,
      // The guide is measured against the whole window, so the body
      // must not resize, and the Stack must not shrink-wrap to the
      // controls (Scaffold hands its body loose constraints).
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isLive)
            _CameraSurface(controller: controller, surfaceSize: size)
          else
            const Center(child: AppLoadingIndicator()),

          if (isLive) ...[
            FaceCaptureSweep(
              guide: guide,
              isActive: _stage == _Stage.detecting && !_assessment.isReady,
            ),
            FaceCaptureRing(
              guide: guide,
              score: _stage == _Stage.captured ? 100 : _assessment.score,
              state: _guideState,
            ),
          ],

          // Readiness sits just above the window. Anchored to the
          // guide, not to a fixed offset, so the two never drift apart.
          Positioned(
            left: 0,
            right: 0,
            bottom: size.height - guide.top + AppSpacing.lg,
            child: FaceCaptureReadiness(
              score: _stage == _Stage.captured ? 100 : _assessment.score,
              label: _stage == _Stage.captured
                  ? FaceReadinessLabel.ready
                  : _assessment.label,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: guide.bottom + AppSpacing.xl,
            child: FaceCaptureGuidanceView(
              guidance: _guidance,
              isHolding: _stage == _Stage.detecting && _assessment.isHolding,
              countdownSeconds: _stage == _Stage.detecting
                  ? _assessment.holdCountdownSeconds
                  : 0,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaceCaptureStatusPanel(assessment: _assessment),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: AppSizing.iconSm,
                          color: Color(0x99FFFFFF),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          loc.faceCaptureLightingHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0x99FFFFFF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (AppEnvironment.current.enableUiPlayground && isLive)
            Positioned(
              left: AppSpacing.lg,
              top: guide.bottom + AppSpacing.xl * 3,
              child: FaceCaptureDiagnostics(
                sample: _lastSample,
                stabilityProgress: _assessment.stabilityProgress,
              ),
            ),

          // Built last so it paints above the preview, but it is the
          // first thing the user needs: a way out.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context, loc, isLive: isLive),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations loc, {
    required bool isLive,
  }) {
    final canSwitch =
        widget.config.allowCameraSwitch &&
        _cameras.length > 1 &&
        _stage == _Stage.detecting;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: _onCameraColor,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: _cancel,
                ),
                Expanded(
                  child: Text(
                    widget.config.title ?? loc.faceCaptureTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _onCameraColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (canSwitch)
                  IconButton(
                    icon: const Icon(Icons.cameraswitch_outlined),
                    color: _onCameraColor,
                    tooltip: loc.faceCaptureSwitchCameraTooltip,
                    onPressed: () => unawaited(_switchCamera()),
                  )
                else
                  const SizedBox(width: AppSizing.minTouchTarget),
              ],
            ),
          ),
          if (isLive && _stage == _Stage.detecting) _buildReadyPill(loc),
        ],
      ),
    );
  }

  Widget _buildReadyPill(AppLocalizations loc) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: _pillColor,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            loc.faceCaptureCameraReady,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: _onCameraColor),
          ),
        ],
      ),
    );
  }

  /// The themed screen for everything that isn't a live preview, so
  /// permission and error copy stays readable and looks like the app.
  Widget _buildMessageScaffold(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title ?? loc.faceCaptureTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: switch (_stage) {
          _Stage.checkingPermission => Center(
            child: AppLoadingIndicator(label: loc.faceCaptureStartingCamera),
          ),
          _Stage.permissionRequired => CameraPermissionView(
            status: _permission,
            onRequestPermission: () => unawaited(_resolvePermission()),
            onOpenSettings: () => unawaited(_openSettings()),
          ),
          _ => AppErrorState(
            message: ErrorLocalizer.resolve(context, _errorCode),
            retryLabel: loc.retry,
            onRetry: () => unawaited(_retry()),
          ),
        },
      ),
    );
  }
}

/// The live preview, scaled to cover the screen.
///
/// `CameraPreview` respects the sensor aspect ratio, which never
/// matches a phone screen. Scaling it up and cropping keeps the face
/// full-bleed — and matches the `BoxFit.cover` assumption that
/// `FaceSurfaceProjection` maps detections through, so the guide circle
/// lines up with where the face actually appears.
class _CameraSurface extends StatelessWidget {
  final CameraController controller;
  final Size surfaceSize;

  const _CameraSurface({required this.controller, required this.surfaceSize});

  @override
  Widget build(BuildContext context) {
    final surfaceRatio = surfaceSize.aspectRatio;
    final sensorRatio = controller.value.aspectRatio;

    if (surfaceRatio <= 0 || sensorRatio <= 0) {
      return CameraPreview(controller);
    }

    // CameraPreview flips the sensor ratio when the surface is
    // portrait, matching what it lays out.
    final previewRatio = surfaceSize.width > surfaceSize.height
        ? sensorRatio
        : 1 / sensorRatio;

    // CameraPreview fits *inside* its box, so the shortfall on the
    // other axis is exactly the ratio between the two aspects — the
    // larger of the two directions is the cover scale.
    final scale = math.max(
      previewRatio / surfaceRatio,
      surfaceRatio / previewRatio,
    );

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}
