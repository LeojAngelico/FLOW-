import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

enum AppBadgeVariant { neutral, info, success, warning, error }

/// A small status pill, e.g. for list items or card headers.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(Theme.of(context).colorScheme, variant);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _colorsFor(
    ColorScheme scheme,
    AppBadgeVariant variant,
  ) {
    switch (variant) {
      case AppBadgeVariant.neutral:
        return (
          background: scheme.surfaceContainerHighest,
          foreground: scheme.onSurfaceVariant,
        );
      case AppBadgeVariant.info:
        return (
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        );
      case AppBadgeVariant.success:
        return (
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        );
      case AppBadgeVariant.warning:
        return (
          background: AppColors.warningContainer,
          foreground: AppColors.onWarningContainer,
        );
      case AppBadgeVariant.error:
        return (
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
    }
  }
}
