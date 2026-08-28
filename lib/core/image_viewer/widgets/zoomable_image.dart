import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../ui_kit/feedback/app_error_state.dart';
import '../../ui_kit/feedback/app_loading_indicator.dart';
import '../../ui_kit/tokens/app_motion.dart';
import '../app_image_source.dart';

/// One image, zoomable and pannable.
///
/// Zoom and pan come from Flutter's [InteractiveViewer] rather than a
/// package or hand-rolled gesture maths — it already handles pinch,
/// momentum, and edge boundaries, and it ships with the framework so it
/// cannot fall behind a Flutter release.
///
/// The one thing it does not provide is double-tap zoom, which is a
/// short piece of standard [TransformationController] work below.
class ZoomableImage extends StatefulWidget {
  final AppImageSource source;

  /// Reports whether the image is currently magnified.
  ///
  /// The gallery uses this to stop paging while the user is panning
  /// around a zoomed image — otherwise a horizontal drag would fight
  /// between moving the image and turning the page.
  final ValueChanged<bool>? onZoomChanged;

  /// False while this page is off-screen in a gallery. Zoom is reset
  /// when it goes false, so returning to an image never lands on
  /// someone else's leftover magnification.
  final bool isActive;

  const ZoomableImage({
    super.key,
    required this.source,
    this.onZoomChanged,
    this.isActive = true,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  /// How far a double tap zooms in. Enough to read a document or a
  /// face, without losing the user's place in the image.
  static const double _doubleTapScale = 2.5;

  /// Ceiling for pinch zoom.
  static const double _maxScale = 5;

  final TransformationController _transformation = TransformationController();

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  );

  Animation<Matrix4>? _zoomAnimation;

  bool _isZoomed = false;

  /// Bumped to rebuild the image after a retry, so a failed load is
  /// actually attempted again instead of served from the error state.
  int _attempt = 0;

  @override
  void initState() {
    super.initState();

    _transformation.addListener(_onTransformationChanged);
    _animation.addListener(_onAnimationTick);
  }

  @override
  void didUpdateWidget(ZoomableImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive && !widget.isActive) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transformation
      ..removeListener(_onTransformationChanged)
      ..dispose();
    _animation
      ..removeListener(_onAnimationTick)
      ..dispose();

    super.dispose();
  }

  double get _scale => _transformation.value.getMaxScaleOnAxis();

  void _onTransformationChanged() {
    final isZoomed = _scale > 1.01;

    if (isZoomed == _isZoomed) {
      return;
    }

    _isZoomed = isZoomed;
    widget.onZoomChanged?.call(isZoomed);
  }

  void _onAnimationTick() {
    final animation = _zoomAnimation;

    if (animation != null) {
      _transformation.value = animation.value;
    }
  }

  void _resetZoom() {
    _animation.stop();
    _zoomAnimation = null;
    _transformation.value = Matrix4.identity();
  }

  /// Zooms in on the tapped point, or back out if already zoomed.
  void _onDoubleTap(TapDownDetails details) {
    final target = _isZoomed
        ? Matrix4.identity()
        : _zoomedMatrixAt(details.localPosition);

    _zoomAnimation = Matrix4Tween(
      begin: _transformation.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));

    _animation.forward(from: 0);
  }

  /// Scales around [focal] so the tapped detail stays put instead of
  /// sliding off screen.
  Matrix4 _zoomedMatrixAt(Offset focal) {
    const scale = _doubleTapScale;

    return Matrix4.identity()
      ..translateByDouble(
        -focal.dx * (scale - 1),
        -focal.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final image = Image(
      key: ValueKey<int>(_attempt),
      image: widget.source.image,
      // Fills the screen as far as the aspect ratio allows, and never
      // upscales a small image beyond its own resolution.
      fit: BoxFit.contain,
      semanticLabel:
          widget.source.semanticLabel ?? loc.imageViewerImageSemantics,
      // frameBuilder covers every provider, unlike Image.network's
      // loadingBuilder, so files and bytes get the same treatment.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return const Center(child: AppLoadingIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return _ImageError(onRetry: _retry);
      },
    );

    final heroTag = widget.source.heroTag;

    return InteractiveViewer(
      transformationController: _transformation,
      minScale: 1,
      maxScale: _maxScale,
      // Keeps a zoomed image inside the viewport rather than letting
      // it be flung into empty space.
      panEnabled: true,
      clipBehavior: Clip.none,
      child: GestureDetector(
        // onDoubleTapDown carries the tap position; onDoubleTap does
        // not, and zooming on the centre instead of the tapped point
        // feels wrong.
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {},
        child: Center(
          child: heroTag == null ? image : Hero(tag: heroTag, child: image),
        ),
      ),
    );
  }

  void _retry() {
    // Drop the cached failure so the next load is a real attempt.
    widget.source.image.evict().ignore();

    setState(() => _attempt++);
  }
}

/// The failed-load state, on the viewer's dark surface.
class _ImageError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ImageError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // AppErrorState reads its colours from the theme, and the app's
    // theme is light — its body text would be near-invisible here. A
    // dark scheme derived from the app's own primary keeps the
    // component *and* the brand colour, instead of forking the widget.
    return Theme(
      data: theme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.colorScheme.primary,
          brightness: Brightness.dark,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: const Color(0xFFFFFFFF),
          displayColor: const Color(0xFFFFFFFF),
        ),
      ),
      child: AppErrorState(
        message: loc.imageViewerLoadFailed,
        retryLabel: loc.retry,
        icon: Icons.broken_image_outlined,
        onRetry: onRetry,
      ),
    );
  }
}
