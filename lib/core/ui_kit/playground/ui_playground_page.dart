import 'package:flutter/material.dart';

import '../../face_capture/face_capture.dart';
import '../../image_viewer/image_viewer.dart';
import '../../qr_scanner/qr_scanner.dart';
import '../../signature_pad/signature_pad.dart';
import '../ui_kit.dart';

/// Living visual documentation for the Core UI Kit.
///
/// Debug-only — see the `kDebugMode`-gated route in `app_router.dart`
/// and the floating shortcut in `app.dart`. Every section shows a
/// component's name, purpose, and its available states side by side.
class UiPlaygroundPage extends StatefulWidget {
  const UiPlaygroundPage({super.key});

  @override
  State<UiPlaygroundPage> createState() => _UiPlaygroundPageState();
}

class _UiPlaygroundPageState extends State<UiPlaygroundPage> {
  bool _isButtonLoading = false;
  bool _chipSelected = false;

  /// Last value returned by the Core QR Scanner, or null if nothing has
  /// been scanned yet (or the last scan was cancelled).
  String? _scannedValue;

  // --------------------------------------------------
  // QR SCANNER — reference integration
  // --------------------------------------------------
  //
  // This is the whole contract: open the scanner, await a String?,
  // then decide what it means. The scanner itself never interprets
  // the value.

  Future<void> _scanQrCode({QrScannerConfig? config}) async {
    final result = await AppQrScanner.scan(
      context,
      config: config ?? const QrScannerConfig(),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      // The user closed the scanner without scanning.
      AppSnackbar.info(context, message: 'Scanner cancelled — returned null.');

      return;
    }

    setState(() => _scannedValue = result);

    AppSnackbar.success(context, message: 'QR code scanned.');
  }

  // --------------------------------------------------
  // FACE CAPTURE — reference integration
  // --------------------------------------------------
  //
  // One call per pose: configure it, await a FaceCaptureResult?, then
  // decide what the photo is for. The Core capability detects and
  // captures; sequencing and meaning live here, in the caller.
  //
  // Nothing is uploaded or persisted — these are the camera's temp
  // files, held in memory for this screen only.

  FaceCaptureCamera _faceCamera = FaceCaptureCamera.front;
  bool _faceSmileRequired = false;

  final Map<FaceOrientation, String> _faceCaptures =
      <FaceOrientation, String>{};

  Future<void> _captureFace(FaceOrientation orientation) async {
    final result = await AppFaceCapture.capture(
      context,
      config: FaceCaptureConfig(
        orientation: orientation,
        smileRequired: _faceSmileRequired,
        camera: _faceCamera,
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      // The user backed out of the scanner.
      AppSnackbar.info(
        context,
        message: 'Face capture cancelled — returned null.',
      );

      return;
    }

    setState(() => _faceCaptures[result.orientation] = result.imagePath);

    AppSnackbar.success(
      context,
      message:
          'Captured ${result.orientation.name} '
          'from the ${result.camera.name} camera.',
    );
  }

  // --------------------------------------------------
  // SIGNATURE PAD — reference integration
  // --------------------------------------------------
  //
  // Open the pad, await a SignatureResult?, then do whatever the
  // feature needs with the PNG. Nothing is uploaded or persisted here;
  // the bytes live in memory for this screen only.

  SignatureResult? _signature;

  Future<void> _captureSignature({SignaturePadConfig? config}) async {
    final result = await AppSignaturePad.show(
      context,
      config: config ?? const SignaturePadConfig(),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      AppSnackbar.info(
        context,
        message: 'Signature cancelled — returned null.',
      );

      return;
    }

    setState(() => _signature = result);

    AppSnackbar.success(
      context,
      message: 'Signature returned: ${result.width}x${result.height} PNG.',
    );
  }

  // --------------------------------------------------
  // IMAGE VIEWER — reference integration
  // --------------------------------------------------
  //
  // Hand it images, await the close. Public placeholder photos are
  // used here so the demo needs nothing from the project's own
  // storage; a feature would pass its own URLs, files or bytes.

  static const List<String> _demoImageUrls = [
    'https://picsum.photos/id/1015/1200/1600',
    'https://picsum.photos/id/1025/1600/1200',
    'https://picsum.photos/id/1035/1400/1400',
    'https://picsum.photos/id/1045/1200/1800',
  ];

  static const Object _heroTag = 'playground-image-hero';

  List<AppImageSource> get _demoImages {
    return [
      for (var i = 0; i < _demoImageUrls.length; i++)
        AppImageSource.network(
          _demoImageUrls[i],
          semanticLabel: 'Sample photo ${i + 1}',
        ),
    ];
  }

  /// The captured faces, viewed as a gallery — a file-backed source,
  /// and an example of one Core capability feeding another.
  List<AppImageSource> get _capturedFaceImages {
    return [
      for (final orientation in FaceOrientation.values)
        if (_faceCaptures[orientation] case final String path)
          AppImageSource.file(path, semanticLabel: '${orientation.name} photo'),
    ];
  }

  List<FaceCaptureReviewSlot> get _faceSlots {
    return [
      for (final orientation in FaceOrientation.values)
        FaceCaptureReviewSlot(
          orientation: orientation,
          imagePath: _faceCaptures[orientation],
          // Front is the only one this demo insists on, to show a
          // mixed required/optional row.
          isRequired: orientation == FaceOrientation.front,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Kit Playground')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            name: 'AppButton',
            purpose:
                'One flexible button with five variants, loading '
                'and disabled states, and optional icons.',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton(label: 'Primary', onPressed: () {}),
                AppButton(
                  label: 'Secondary',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Outlined',
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Text',
                  variant: AppButtonVariant.text,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Destructive',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'With icon',
                  icon: Icons.download_outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Trailing icon',
                  icon: Icons.arrow_forward,
                  iconPosition: AppButtonIconPosition.trailing,
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Loading',
                  isLoading: _isButtonLoading,
                  onPressed: () {
                    setState(() => _isButtonLoading = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isButtonLoading = false);
                    });
                  },
                ),
                const AppButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
          _Section(
            name: 'AppTextField',
            purpose: 'Standard text input with label/hint/error support.',
            child: const Column(
              children: [
                AppTextField(label: 'Email', hint: 'you@example.com'),
                SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  errorText: 'Password is required.',
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppPasswordField',
            purpose: 'Password input with a built-in visibility toggle.',
            child: const AppPasswordField(label: 'Password'),
          ),
          _Section(
            name: 'AppCard',
            purpose: 'Tappable card surface shared by list/grid items.',
            child: AppCard(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.description_outlined),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Tap this card')),
                ],
              ),
            ),
          ),
          _Section(
            name: 'AppBottomSheet',
            purpose:
                'Generic action sheet — a title plus a list of '
                'tappable actions.',
            child: AppButton(
              label: 'Show actions',
              variant: AppButtonVariant.outlined,
              onPressed: () => AppBottomSheet.showActions(
                context,
                title: 'Choose a photo',
                actions: [
                  AppBottomSheetAction(
                    icon: Icons.photo_camera_outlined,
                    label: 'Take Photo',
                    onTap: () {},
                  ),
                  AppBottomSheetAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from Gallery',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          _Section(
            name: 'AppAvatar',
            purpose: 'Image avatar with initials fallback.',
            child: const Row(
              children: [
                AppAvatar(initials: 'JD', size: AppSizing.avatarSm),
                SizedBox(width: AppSpacing.md),
                AppAvatar(initials: 'JD'),
                SizedBox(width: AppSpacing.md),
                AppAvatar(initials: 'JD', size: AppSizing.avatarLg),
              ],
            ),
          ),
          _Section(
            name: 'AppBadge',
            purpose: 'Status pills for list items and card headers.',
            child: const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(label: 'Neutral'),
                AppBadge(label: 'Info', variant: AppBadgeVariant.info),
                AppBadge(label: 'Success', variant: AppBadgeVariant.success),
                AppBadge(label: 'Warning', variant: AppBadgeVariant.warning),
                AppBadge(label: 'Error', variant: AppBadgeVariant.error),
              ],
            ),
          ),
          _Section(
            name: 'AppChip',
            purpose: 'Selectable filter chip.',
            child: AppChip(
              label: 'Filter',
              icon: Icons.filter_alt_outlined,
              selected: _chipSelected,
              onSelected: (value) => setState(() => _chipSelected = value),
            ),
          ),
          _Section(
            name: 'AppSnackbar',
            purpose: 'Themed feedback banners for success/error/warning/info.',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton(
                  label: 'Success',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.success(
                    context,
                    message: 'Saved successfully.',
                  ),
                ),
                AppButton(
                  label: 'Error',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.error(
                    context,
                    message: 'Something went wrong.',
                  ),
                ),
                AppButton(
                  label: 'Warning',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.warning(
                    context,
                    message: 'This action needs review.',
                  ),
                ),
                AppButton(
                  label: 'Info',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppSnackbar.info(
                    context,
                    message: 'Heads up — something changed.',
                  ),
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppLoadingIndicator',
            purpose: 'Sizeable loading spinner with an optional label.',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppLoadingIndicator(size: AppLoadingSize.small),
                AppLoadingIndicator(size: AppLoadingSize.medium),
                AppLoadingIndicator(
                  size: AppLoadingSize.large,
                  label: 'Loading…',
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppEmptyState',
            purpose: 'Centered "nothing here" state with an optional action.',
            child: AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No items yet',
              message: 'Items you add will show up here.',
              actionLabel: 'Add item',
              onAction: () {},
            ),
          ),
          _Section(
            name: 'AppErrorState',
            purpose: 'Centered error message with a retry action.',
            child: AppErrorState(
              message: 'Failed to load data.',
              onRetry: () {},
            ),
          ),
          _Section(
            name: 'AppDialog / AppConfirmationDialog',
            purpose:
                'Composable dialog shell, plus a ready-made '
                'confirm/cancel dialog built on top of it.',
            child: Wrap(
              spacing: AppSpacing.md,
              children: [
                AppButton(
                  label: 'Show dialog',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AppDialog(
                      title: 'Export complete',
                      icon: Icons.check_circle_outline,
                      content: const Text(
                        'Your report was saved to Downloads.',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        AppButton(
                          label: 'OK',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  label: 'Confirm dialog',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppConfirmationDialog.show(
                    context,
                    title: 'Delete Report',
                    message: 'Are you sure you want to delete this report?',
                    isDestructive: true,
                    confirmLabel: 'Delete',
                    onConfirm: () {
                      AppSnackbar.success(context, message: 'Report deleted.');
                    },
                  ),
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppQrScanner (Core capability)',
            purpose:
                'Opens the reusable QR scanner and returns the raw '
                'scanned string, or null when the user cancels. Lives in '
                'core/qr_scanner/, not in the UI Kit — copy the code below '
                'into any feature that needs to scan a code.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: 'Scan QR Code',
                  icon: Icons.qr_code_scanner,
                  onPressed: _scanQrCode,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Scan with custom copy',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => _scanQrCode(
                    config: const QrScannerConfig(
                      title: 'Scan asset tag',
                      instruction: 'Line up the tag inside the frame',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_scannedValue == null)
                  const AppEmptyState(
                    icon: Icons.qr_code_2_outlined,
                    title: 'Nothing scanned yet',
                    message: 'Scan a code to see the returned value here.',
                  )
                else
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scanned value',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(_scannedValue!),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: 'Clear',
                          variant: AppButtonVariant.text,
                          height: AppSizing.buttonHeightCompact,
                          onPressed: () => setState(() => _scannedValue = null),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            name: 'AppSignaturePad (Core capability)',
            purpose:
                'Captures a handwritten signature and returns a PNG '
                'containing only the strokes, on a transparent '
                'background — no pad UI, no border, no background fill. '
                'Lives in core/signature_pad/.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    AppButton(
                      label: 'Sign',
                      icon: Icons.draw_outlined,
                      onPressed: _captureSignature,
                    ),
                    AppButton(
                      label: 'Sign (uncropped)',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _captureSignature(
                        config: const SignaturePadConfig(
                          cropToSignature: false,
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Sign (custom copy)',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _captureSignature(
                        config: const SignaturePadConfig(
                          title: 'Sign the delivery receipt',
                          hint: 'Your signature',
                          completeLabel: 'Confirm',
                          strokeWidth: 4,
                          confirmDiscard: false,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                if (_signature == null)
                  const AppEmptyState(
                    icon: Icons.gesture_outlined,
                    title: 'No signature yet',
                    message: 'Sign to see the exported PNG here.',
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exported PNG — '
                        '${_signature!.width}x${_signature!.height}, '
                        '${(_signature!.bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Shown over a checkerboard: every square you can '
                        'see through the strokes is a transparent pixel.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // A checkerboard rather than a flat dark panel:
                      // a white-background export would show up as an
                      // obvious opaque rectangle over the squares.
                      ClipRRect(
                        borderRadius: AppRadius.mdAll,
                        child: CustomPaint(
                          painter: const _CheckerboardPainter(),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 160),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            alignment: Alignment.center,
                            child: Image.memory(
                              _signature!.bytes,
                              fit: BoxFit.contain,
                              height: 140,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Clear result',
                        variant: AppButtonVariant.text,
                        height: AppSizing.buttonHeightCompact,
                        onPressed: () => setState(() => _signature = null),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          _Section(
            name: 'AppImageViewer (Core capability)',
            purpose:
                'Immersive image viewer with pinch and double-tap '
                'zoom, panning, and swiping between images. Built on '
                'Flutter\'s InteractiveViewer — no image viewer package. '
                'Lives in core/image_viewer/.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tapping the thumbnail shows the Hero transition:
                // the same tag on both sides is all it takes.
                Align(
                  child: Semantics(
                    button: true,
                    label: 'Open sample photo',
                    child: InkWell(
                      onTap: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(
                          _demoImageUrls.first,
                          semanticLabel: 'Sample photo',
                          heroTag: _heroTag,
                        ),
                      ),
                      borderRadius: AppRadius.mdAll,
                      child: Hero(
                        tag: _heroTag,
                        child: ClipRRect(
                          borderRadius: AppRadius.mdAll,
                          child: Image.network(
                            _demoImageUrls.first,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    AppButton(
                      label: 'Single image',
                      icon: Icons.image_outlined,
                      onPressed: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(_demoImageUrls.first),
                      ),
                    ),
                    AppButton(
                      label: 'Gallery from 3rd',
                      icon: Icons.collections_outlined,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.showGallery(
                        context,
                        _demoImages,
                        initialIndex: 2,
                      ),
                    ),
                    AppButton(
                      label: 'With a title + action',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.showGallery(
                        context,
                        _demoImages,
                        config: AppImageViewerConfig(
                          title: 'Evidence photos',
                          actions: [
                            AppImageViewerAction(
                              icon: Icons.info_outline,
                              label: 'Photo details',
                              onPressed: (index, image) => AppSnackbar.info(
                                context,
                                message:
                                    'Action fired for image '
                                    '${index + 1}.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Error state',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => AppImageViewer.show(
                        context,
                        AppImageSource.network(
                          'https://example.invalid/missing.jpg',
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Captured faces (${_capturedFaceImages.length})',
                      icon: Icons.face_outlined,
                      variant: AppButtonVariant.outlined,
                      // Disabled until something has been captured —
                      // the viewer refuses an empty list by design.
                      onPressed: _capturedFaceImages.isEmpty
                          ? null
                          : () => AppImageViewer.showGallery(
                              context,
                              _capturedFaceImages,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppFaceCapture (Core capability)',
            purpose:
                'On-device face detection with auto-capture. Pick a '
                'pose, await a FaceCaptureResult?, and the photo is taken '
                'for you once the face is framed, turned the right way and '
                'held steady. Lives in core/face_capture/.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Camera', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppChip(
                      label: 'Front camera',
                      icon: Icons.person_outline,
                      selected: _faceCamera == FaceCaptureCamera.front,
                      onSelected: (_) =>
                          setState(() => _faceCamera = FaceCaptureCamera.front),
                    ),
                    AppChip(
                      label: 'Rear camera',
                      icon: Icons.photo_camera_outlined,
                      selected: _faceCamera == FaceCaptureCamera.rear,
                      onSelected: (_) =>
                          setState(() => _faceCamera = FaceCaptureCamera.rear),
                    ),
                    AppChip(
                      // Front only, by design — see FaceCaptureConfig.
                      label: 'Smile required (front)',
                      icon: Icons.mood_outlined,
                      selected: _faceSmileRequired,
                      onSelected: (value) =>
                          setState(() => _faceSmileRequired = value),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Capture a pose',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final orientation in FaceOrientation.values)
                      AppButton(
                        label: 'Capture ${orientation.name}',
                        icon: Icons.face_retouching_natural_outlined,
                        variant: orientation == FaceOrientation.front
                            ? AppButtonVariant.primary
                            : AppButtonVariant.outlined,
                        onPressed: () => _captureFace(orientation),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'FaceCaptureReviewView',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'The review step is a body widget, so a real feature '
                  'wraps it in its own Scaffold and AppBar ("Verify '
                  'Account"). Tap a slot to capture or retake it.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 620,
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: FaceCaptureReviewView(
                      slots: _faceSlots,
                      onSlotTapped: _captureFace,
                      onContinue:
                          FaceCaptureReviewView.allRequiredCompleted(_faceSlots)
                          ? () => AppSnackbar.success(
                              context,
                              message:
                                  'Continue — the feature would upload '
                                  '${_faceCaptures.length} photo(s) here.',
                            )
                          : null,
                      onRetake: _faceCaptures.isEmpty
                          ? null
                          : () => setState(_faceCaptures.clear),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            name: 'AppLoadingDialog',
            purpose:
                'Non-dismissible blocking dialog for short, '
                'must-wait operations (e.g. logging out).',
            child: AppButton(
              label: 'Show loading dialog',
              variant: AppButtonVariant.outlined,
              onPressed: () async {
                AppLoadingDialog.show(context, message: 'Loading…');
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) AppLoadingDialog.hide(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String name;
  final String purpose;
  final Widget child;

  const _Section({
    required this.name,
    required this.purpose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            purpose,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
          const Divider(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }
}

/// A light/dark checkerboard, so a transparent PNG is obviously
/// transparent and an accidentally-opaque one is obviously not.
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  static const double _square = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFF3A3A44);
    final dark = Paint()..color = const Color(0xFF2A2A32);

    canvas.drawRect(Offset.zero & size, dark);

    for (var y = 0; y * _square < size.height; y++) {
      for (var x = 0; x < size.width / _square; x++) {
        if ((x + y).isEven) {
          canvas.drawRect(
            Rect.fromLTWH(x * _square, y * _square, _square, _square),
            light,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) => false;
}
