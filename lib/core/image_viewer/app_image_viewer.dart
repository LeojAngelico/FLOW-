import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_image_source.dart';
import 'image_viewer_config.dart';
import 'image_viewer_page.dart';

/// The Core Image Viewer's entry point — the only thing a feature needs.
///
/// Opens an immersive, zoomable viewer and returns when the user closes
/// it. There is no result: viewing an image doesn't produce one, and
/// optional actions report through their own callbacks instead.
///
/// ```dart
/// // One image.
/// await AppImageViewer.show(
///   context,
///   AppImageSource.network(incident.image.fullPath),
/// );
///
/// // A gallery, opened on the third photo.
/// await AppImageViewer.showGallery(
///   context,
///   photos.map(AppImageSource.network).toList(),
///   initialIndex: 2,
/// );
/// ```
class AppImageViewer {
  AppImageViewer._();

  /// The route the viewer is registered under in `app_router.dart`.
  static const String routePath = '/image-viewer';

  /// Shows a single image.
  static Future<void> show(
    BuildContext context,
    AppImageSource image, {
    AppImageViewerConfig config = const AppImageViewerConfig(),
  }) {
    return showGallery(context, [image], config: config);
  }

  /// Shows [images] with horizontal swiping, starting at
  /// [initialIndex].
  ///
  /// An out-of-range [initialIndex] is clamped. An empty list opens
  /// nothing: there is no image to view, and a black screen with a
  /// close button is worse than staying put. In debug builds that
  /// trips an assertion, since it almost always means the caller
  /// forgot to check.
  static Future<void> showGallery(
    BuildContext context,
    List<AppImageSource> images, {
    int initialIndex = 0,
    AppImageViewerConfig config = const AppImageViewerConfig(),
  }) {
    assert(
      images.isNotEmpty,
      'AppImageViewer was given no images. Check the list is non-empty '
      'before opening the viewer.',
    );

    if (images.isEmpty) {
      return Future<void>.value();
    }

    return GoRouter.of(context).push<void>(
      routePath,
      extra: AppImageViewerArgs(
        images: List<AppImageSource>.unmodifiable(images),
        initialIndex: initialIndex.clamp(0, images.length - 1),
        config: config,
      ),
    );
  }

  /// Whether [images] can be shown — for callers that want to hide a
  /// "view photo" affordance rather than trip the assertion above.
  static bool canShow(List<AppImageSource>? images) {
    return images != null && images.isNotEmpty;
  }
}
