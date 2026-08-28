import 'package:flutter/widgets.dart';

import 'app_image_source.dart';

/// An action offered in the viewer's top bar.
///
/// The Core viewer deliberately ships **no** share, save or delete
/// button. Each of those needs a package and a policy decision (where
/// does a download go? what does deleting mean?), which makes them
/// feature concerns, not viewer concerns. Instead the caller supplies
/// the actions it wants and handles them itself:
///
/// ```dart
/// AppImageViewerAction(
///   icon: Icons.delete_outline,
///   label: 'Delete photo',
///   onPressed: (index, image) => _confirmDelete(index),
/// )
/// ```
@immutable
class AppImageViewerAction {
  final IconData icon;

  /// Tooltip *and* accessibility label, so the action is never
  /// icon-only to a screen reader.
  final String label;

  /// Called with the position and source of the visible image.
  final void Function(int index, AppImageSource image) onPressed;

  const AppImageViewerAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

/// Customization for one viewing session.
///
/// Every field has a sensible default, so the common case is
/// `AppImageViewer.show(context, image)` with no configuration.
/// Gesture behaviour is deliberately not configurable — zoom limits
/// and double-tap scale are the kind of thing that should feel the
/// same everywhere in an app.
@immutable
class AppImageViewerConfig {
  /// Shows the "2 / 5" counter. Ignored for a single image, which has
  /// nothing to count.
  final bool showCounter;

  /// Shows the close button. System back always works regardless.
  final bool showCloseButton;

  /// Optional caption in the top bar.
  final String? title;

  /// Actions for the top-right of the bar.
  final List<AppImageViewerAction> actions;

  /// The surface behind the image.
  ///
  /// Black by default and independent of the app's light theme: an
  /// image viewer is an immersive surface, and a light background
  /// changes how the image itself reads.
  final Color backgroundColor;

  const AppImageViewerConfig({
    this.showCounter = true,
    this.showCloseButton = true,
    this.title,
    this.actions = const [],
    this.backgroundColor = const Color(0xFF000000),
  });
}
