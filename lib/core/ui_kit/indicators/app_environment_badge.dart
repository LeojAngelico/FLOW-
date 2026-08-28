import 'package:flutter/material.dart';

/// A small diagonal corner ribbon for non-production builds.
///
/// Thin wrapper over Flutter's built-in [Banner] — generic, with no
/// knowledge of specific environments. The caller (e.g. `app.dart`,
/// driven by `AppEnvironment`) decides the message and color, and
/// whether to show it at all.
class AppEnvironmentBadge extends StatelessWidget {
  final String message;
  final Color color;
  final Widget child;

  const AppEnvironmentBadge({
    super.key,
    required this.message,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: message,
      location: BannerLocation.topEnd,
      color: color,
      child: child,
    );
  }
}
