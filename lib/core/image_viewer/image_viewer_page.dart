import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../ui_kit/tokens/app_sizing.dart';
import '../ui_kit/tokens/app_spacing.dart';
import 'app_image_source.dart';
import 'image_viewer_config.dart';
import 'widgets/image_viewer_counter.dart';
import 'widgets/zoomable_image.dart';

const Color _onViewerColor = Color(0xFFFFFFFF);

/// Everything the viewer needs, carried through the route.
///
/// Public because `app_router.dart` reads it back out of
/// `GoRouterState.extra`; callers use `AppImageViewer` instead of
/// building this themselves.
@immutable
class AppImageViewerArgs {
  final List<AppImageSource> images;
  final int initialIndex;
  final AppImageViewerConfig config;

  const AppImageViewerArgs({
    required this.images,
    this.initialIndex = 0,
    this.config = const AppImageViewerConfig(),
  });
}

/// The immersive image viewer.
///
/// Opened through `AppImageViewer.show`, so features never construct it
/// directly. Holds no business logic: it is handed images and shows
/// them.
class ImageViewerPage extends StatefulWidget {
  final AppImageViewerArgs args;

  const ImageViewerPage({super.key, required this.args});

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _pageController;
  late int _index;

  /// True while the visible image is magnified, which suspends paging.
  bool _isZoomed = false;

  List<AppImageSource> get _images => widget.args.images;

  bool get _isGallery => _images.length > 1;

  @override
  void initState() {
    super.initState();

    // Clamped rather than trusted: an out-of-range index from a caller
    // should not be a crash. The empty case is checked first because
    // clamp(0, -1) is itself an error.
    _index = _images.isEmpty
        ? 0
        : widget.args.initialIndex.clamp(0, _images.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _close() => context.pop();

  @override
  Widget build(BuildContext context) {
    final config = widget.args.config;
    final loc = AppLocalizations.of(context)!;

    // Defensive: AppImageViewer refuses to open with no images, so
    // this only happens if the page is built directly.
    if (_images.isEmpty) {
      return Scaffold(
        backgroundColor: config.backgroundColor,
        body: SafeArea(child: _buildTopBar(context, loc, config)),
      );
    }

    return Scaffold(
      backgroundColor: config.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // PageView.builder keeps only the visible page and its
          // neighbours alive, so a long gallery never decodes every
          // full-resolution image at once.
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            // Paging is suspended while zoomed so a horizontal drag
            // pans the image instead of fighting the page.
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _index = index;
                _isZoomed = false;
              });
            },
            itemBuilder: (context, index) {
              return ZoomableImage(
                key: ValueKey<int>(index),
                source: _images[index],
                isActive: index == _index,
                onZoomChanged: (isZoomed) {
                  if (isZoomed == _isZoomed) {
                    return;
                  }

                  setState(() => _isZoomed = isZoomed);
                },
              );
            },
          ),

          if (_isGallery && config.showCounter)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: ImageViewerCounter(
                      index: _index,
                      total: _images.length,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(context, loc, config),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations loc,
    AppImageViewerConfig config,
  ) {
    final theme = Theme.of(context);
    final title = config.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          if (config.showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              color: _onViewerColor,
              iconSize: AppSizing.iconMd,
              tooltip: loc.imageViewerCloseTooltip,
              onPressed: _close,
            )
          else
            const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _onViewerColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          for (final action in config.actions)
            IconButton(
              icon: Icon(action.icon),
              color: _onViewerColor,
              iconSize: AppSizing.iconMd,
              // Doubles as the accessibility label, so the action is
              // never icon-only to a screen reader.
              tooltip: action.label,
              onPressed: _images.isEmpty
                  ? null
                  : () => action.onPressed(_index, _images[_index]),
            ),
        ],
      ),
    );
  }
}
