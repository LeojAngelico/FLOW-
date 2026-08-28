import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/generated/app_localizations.dart';
import '../errors/error_codes.dart';
import '../localization/error_localizer.dart';
import '../ui_kit/feedback/app_error_state.dart';
import '../ui_kit/feedback/app_loading_indicator.dart';
import '../ui_kit/tokens/app_motion.dart';
import '../ui_kit/tokens/app_sizing.dart';
import '../ui_kit/tokens/app_spacing.dart';
import '../utils/app_camera_permission.dart';
import '../widgets/camera_permission_view.dart';
import 'qr_scan_session.dart';
import 'qr_scanner_config.dart';
import 'widgets/qr_scanner_overlay.dart';

// The camera preview is drawn on black on both platforms; a themed
// surface color behind it would show as a colored flash while the
// camera starts. Everything outside the preview uses the app theme.
const Color _cameraSurfaceColor = Color(0xFF000000);
const Color _cameraForegroundColor = Color(0xFFFFFFFF);

/// What the scanner is currently showing.
enum _ScannerStage {
  /// Resolving the camera permission — nothing to show yet.
  checkingPermission,

  /// The camera preview and the scan overlay.
  scanning,

  /// The camera permission is missing; [_ScannerPageState._permission]
  /// says whether asking again is still possible.
  permissionRequired,

  /// The camera or the scanner itself could not be started.
  failed,
}

/// The Core QR Scanner screen.
///
/// Reached through `AppQrScanner.scan(context)` rather than by being
/// constructed directly, so calling features only ever deal with a
/// `Future<String?>`. It pops itself with the raw scanned value, or
/// with null when the user closes it.
///
/// Deliberately free of any business logic: it does not validate,
/// parse, or act on what it read.
class QrScannerPage extends StatefulWidget {
  final QrScannerConfig config;

  const QrScannerPage({super.key, this.config = const QrScannerConfig()});

  @override
  State<QrScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  /// Guarantees a single result per visit, no matter how many times the
  /// camera reports the same code.
  final QrScanSession _session = QrScanSession();

  MobileScannerController? _controller;

  _ScannerStage _stage = _ScannerStage.checkingPermission;

  CameraPermissionStatus _permission = CameraPermissionStatus.denied;

  String _errorCode = ErrorCodes.scannerFailed;

  /// True between a successful scan and the route being popped, so the
  /// frame can confirm the read before the screen disappears.
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    unawaited(_resolvePermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // The camera must not outlive this screen. MobileScanner stops the
    // controller when it unmounts, but disposing it is ours to do since
    // we own the instance.
    unawaited(_controller?.dispose());
    _controller = null;

    super.dispose();
  }

  // --------------------------------------------------
  // PERMISSION
  // --------------------------------------------------

  /// Resolves the camera permission and moves to the matching stage.
  ///
  /// [request] shows the system dialog when the permission is still
  /// requestable; it's false when re-checking after the user comes back
  /// from the Settings app, where prompting again would be wrong.
  Future<void> _resolvePermission({bool request = true}) async {
    setState(() {
      _stage = _ScannerStage.checkingPermission;
    });

    final status = request
        ? await AppCameraPermission.request()
        : await AppCameraPermission.check();

    if (!mounted) {
      return;
    }

    switch (status) {
      case CameraPermissionStatus.granted:
        await _startScanner();
      case CameraPermissionStatus.unavailable:
        setState(() {
          _stage = _ScannerStage.failed;
          _errorCode = ErrorCodes.cameraUnavailable;
        });
      case CameraPermissionStatus.denied:
      case CameraPermissionStatus.permanentlyDenied:
      case CameraPermissionStatus.restricted:
        setState(() {
          _stage = _ScannerStage.permissionRequired;
          _permission = status;
        });
    }
  }

  Future<void> _openSettings() async {
    final opened = await AppCameraPermission.openSettings();

    if (!opened && mounted) {
      setState(() {
        _stage = _ScannerStage.failed;
        _errorCode = ErrorCodes.cameraUnavailable;
      });
    }
  }

  // --------------------------------------------------
  // CAMERA
  // --------------------------------------------------

  Future<void> _startScanner() async {
    await _disposeController();

    final controller = MobileScannerController(
      formats: widget.config.barcodeFormats,
      // Belt and braces next to QrScanSession: the platform side also
      // stops reporting a code it has already reported.
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    controller.addListener(_onScannerStateChanged);

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _stage = _ScannerStage.scanning;
    });
  }

  /// Runs a camera command, swallowing the scanner's own lifecycle
  /// exceptions.
  ///
  /// `start()` and `toggleTorch()` throw when the camera is
  /// mid-transition (already starting, not initialized yet). That is
  /// not a failure the user needs to hear about — the next lifecycle
  /// event or tap recovers on its own.
  Future<void> _runCameraCommand(Future<void> Function() command) async {
    try {
      await command();
    } on MobileScannerException catch (_) {
      // Transient — deliberately ignored.
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    controller.removeListener(_onScannerStateChanged);
    _controller = null;

    await controller.dispose();
  }

  /// Turns a camera failure reported by the scanner into one of this
  /// screen's states.
  ///
  /// Errors about the controller's own lifecycle (already started, not
  /// attached yet, still initializing) are transient and deliberately
  /// ignored — they resolve themselves on the next frame.
  void _onScannerStateChanged() {
    final error = _controller?.value.error;

    if (error == null || _session.isCompleted || !mounted) {
      return;
    }

    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        // The permission was revoked while the camera was running.
        unawaited(_resolvePermission(request: false));
      case MobileScannerErrorCode.unsupported:
        setState(() {
          _stage = _ScannerStage.failed;
          _errorCode = ErrorCodes.scannerUnsupported;
        });
      case MobileScannerErrorCode.genericError:
        setState(() {
          _stage = _ScannerStage.failed;
          _errorCode = ErrorCodes.scannerFailed;
        });
      case MobileScannerErrorCode.controllerAlreadyInitialized:
      case MobileScannerErrorCode.controllerDisposed:
      case MobileScannerErrorCode.controllerUninitialized:
      case MobileScannerErrorCode.controllerInitializing:
      case MobileScannerErrorCode.controllerNotAttached:
        return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the Settings app is the one case where the
    // permission may have changed behind our back.
    if (state == AppLifecycleState.resumed &&
        _stage == _ScannerStage.permissionRequired) {
      unawaited(_resolvePermission(request: false));

      return;
    }

    final controller = _controller;

    if (controller == null ||
        _stage != _ScannerStage.scanning ||
        _session.isCompleted ||
        !controller.value.hasCameraPermission) {
      return;
    }

    // Release the camera whenever the app is not in front, and pick it
    // back up on return, so the scanner never holds the camera in the
    // background.
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_runCameraCommand(controller.start));
      case AppLifecycleState.inactive:
        // stop() is safe to call in any state.
        unawaited(controller.stop());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
    }
  }

  // --------------------------------------------------
  // RESULT
  // --------------------------------------------------

  void _onDetect(BarcodeCapture capture) {
    final rawValue = _session.accept(
      capture.barcodes.map((barcode) => barcode.rawValue),
    );

    if (rawValue == null) {
      return;
    }

    unawaited(_complete(rawValue));
  }

  /// Stops the camera, confirms the read, and hands the raw value back
  /// to the calling screen.
  Future<void> _complete(String rawValue) async {
    setState(() {
      _isSuccess = true;
    });

    unawaited(HapticFeedback.mediumImpact());

    await _controller?.stop();

    // Long enough for the frame to read as "got it", short enough that
    // it doesn't feel like a delay.
    await Future<void>.delayed(AppMotion.fast);

    if (!mounted) {
      return;
    }

    context.pop(rawValue);
  }

  void _cancel() {
    // No value: `AppQrScanner.scan` completes with null.
    context.pop();
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_stage == _ScannerStage.scanning) {
      return _buildScannerScaffold(context);
    }

    return _buildMessageScaffold(context);
  }

  /// The immersive camera screen.
  Widget _buildScannerScaffold(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = _controller;

    // The preview fills the screen, so the frame is derived from the
    // window rather than from a LayoutBuilder — a LayoutBuilder here
    // would build the scanner during the layout phase, and the camera
    // starting up would then try to rebuild the controls mid-layout.
    final frame = QrScannerOverlay.frameFor(
      MediaQuery.sizeOf(context),
      widget.config.frameSizeFactor,
    );

    return Scaffold(
      backgroundColor: _cameraSurfaceColor,
      // No text input here, and the frame is measured against the full
      // window, so the body must not resize.
      resizeToAvoidBottomInset: false,
      body: Stack(
        // Scaffold hands its body *loose* constraints, so without this
        // the Stack shrink-wraps to the controls row and the preview
        // gets a thin strip while the frame lands off-screen.
        fit: StackFit.expand,
        children: [
          // Built before the controls on purpose: the camera reports its
          // first state change while this subtree mounts, and the torch
          // button must not exist yet when that happens.
          if (controller != null)
            Positioned.fill(
              child: MobileScanner(
                controller: controller,
                onDetect: _onDetect,
                // Only codes inside the frame are decoded, so the user
                // gets what they aimed at.
                scanWindow: frame,
                placeholderBuilder: (context) => const ColoredBox(
                  color: _cameraSurfaceColor,
                  child: Center(child: AppLoadingIndicator()),
                ),
                // Camera failures are handled by this screen (see
                // _onScannerStateChanged), so the preview itself stays
                // quiet instead of flashing an error icon.
                errorBuilder: (context, error) =>
                    const ColoredBox(color: _cameraSurfaceColor),
                overlayBuilder: (context, constraints) => QrScannerOverlay(
                  frame: frame,
                  title: widget.config.title ?? loc.qrScannerTitle,
                  instruction:
                      widget.config.instruction ?? loc.qrScannerInstruction,
                  isSuccess: _isSuccess,
                ),
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCameraControls(context, loc),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls(BuildContext context, AppLocalizations loc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              color: _cameraForegroundColor,
              iconSize: AppSizing.iconMd,
              tooltip: loc.qrScannerCloseTooltip,
              onPressed: _cancel,
            ),
            if (widget.config.showTorchButton) _buildTorchButton(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildTorchButton(AppLocalizations loc) {
    final controller = _controller;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        // Hidden rather than disabled on devices without a torch —
        // there is nothing the user could do with it.
        if (state.torchState == TorchState.unavailable) {
          return const SizedBox.shrink();
        }

        final isOn = state.torchState == TorchState.on;

        return IconButton(
          icon: Icon(isOn ? Icons.flashlight_on : Icons.flashlight_off),
          color: _cameraForegroundColor,
          iconSize: AppSizing.iconMd,
          tooltip: isOn
              ? loc.qrScannerTorchOffTooltip
              : loc.qrScannerTorchOnTooltip,
          onPressed: () => unawaited(_runCameraCommand(controller.toggleTorch)),
        );
      },
    );
  }

  /// The themed screen used for everything that isn't a live preview,
  /// so permission and error copy is readable and looks like the rest
  /// of the app.
  Widget _buildMessageScaffold(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title ?? loc.qrScannerTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: loc.qrScannerCloseTooltip,
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: switch (_stage) {
          _ScannerStage.checkingPermission => Center(
            child: AppLoadingIndicator(label: loc.qrScannerStartingCamera),
          ),
          _ScannerStage.permissionRequired => CameraPermissionView(
            status: _permission,
            onRequestPermission: () => unawaited(_resolvePermission()),
            onOpenSettings: () => unawaited(_openSettings()),
          ),
          _ScannerStage.failed => AppErrorState(
            message: ErrorLocalizer.resolve(context, _errorCode),
            retryLabel: loc.retry,
            onRetry: () => unawaited(_resolvePermission()),
          ),
          _ScannerStage.scanning => const SizedBox.shrink(),
        },
      ),
    );
  }
}
