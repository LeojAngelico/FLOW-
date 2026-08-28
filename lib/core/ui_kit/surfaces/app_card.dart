import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// The Core UI Kit's card container.
///
/// Wraps [Card] with the tap target and padding conventions used
/// throughout the kit, so every card-like surface behaves the same
/// way instead of each screen hand-rolling `Card` + `InkWell`.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? color;
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius,
    this.elevation,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final shape = borderRadius != null
        ? RoundedRectangleBorder(borderRadius: borderRadius!)
        : null;

    return Card(
      margin: margin,
      elevation: elevation,
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
