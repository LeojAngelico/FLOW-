import 'package:flutter/material.dart';

import '../tokens/app_sizing.dart';
import '../tokens/app_spacing.dart';

/// Visual role of an [AppButton].
///
/// Maps onto Material 3 button types rather than inventing new
/// visuals: [primary] → filled, [secondary] → tonal, [outlined] →
/// outlined, [text] → text, [destructive] → filled with the error
/// color role.
enum AppButtonVariant { primary, secondary, outlined, text, destructive }

enum AppButtonIconPosition { leading, trailing }

/// The Core UI Kit's single button.
///
/// One flexible, composable button instead of specialized
/// `RedButton`/`LargeButton`-style variants — pick a [variant] and
/// customize from there. For styling beyond the exposed
/// properties, pass [style] to merge onto the base [ButtonStyle].
///
/// ```dart
/// AppButton(
///   label: 'Save',
///   isLoading: isSaving,
///   onPressed: save,
/// )
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final ButtonStyle? style;
  final String? semanticLabel;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.iconPosition = AppButtonIconPosition.leading,
    this.isLoading = false,
    this.width,
    this.height = AppSizing.buttonHeight,
    this.padding,
    this.borderRadius,
    this.style,
    this.semanticLabel,
  });

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseStyle = _baseStyleFor(variant, theme).copyWith(
      minimumSize: WidgetStatePropertyAll(Size(0, height)),
      padding: padding != null ? WidgetStatePropertyAll(padding) : null,
      shape: borderRadius != null
          ? WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: borderRadius!),
            )
          : null,
    );

    final mergedStyle = style != null ? baseStyle.merge(style) : baseStyle;

    final child = _buildChild(theme);

    final Widget button;

    switch (variant) {
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: mergedStyle,
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: _enabled ? onPressed : null,
          style: mergedStyle,
          child: child,
        );
      case AppButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: _enabled ? onPressed : null,
          style: mergedStyle,
          child: child,
        );
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        button = FilledButton(
          onPressed: _enabled ? onPressed : null,
          style: mergedStyle,
          child: child,
        );
    }

    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: _enabled,
      child: SizedBox(width: width, height: height, child: button),
    );
  }

  ButtonStyle _baseStyleFor(AppButtonVariant variant, ThemeData theme) {
    if (variant == AppButtonVariant.destructive) {
      return FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.12,
        ),
      );
    }

    return const ButtonStyle();
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: AppSizing.iconSm,
        width: AppSizing.iconSm,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: _spinnerColor(theme),
        ),
      );
    }

    if (icon == null) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final iconWidget = Icon(icon, size: AppSizing.iconSm);

    // Flexible so a long label truncates instead of overflowing the
    // button when width is constrained (e.g. two buttons sharing a
    // row via Expanded).
    final labelWidget = Flexible(
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconPosition == AppButtonIconPosition.leading
          ? [iconWidget, const SizedBox(width: AppSpacing.sm), labelWidget]
          : [labelWidget, const SizedBox(width: AppSpacing.sm), iconWidget],
    );
  }

  Color _spinnerColor(ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return theme.colorScheme.onPrimary;
      case AppButtonVariant.destructive:
        return theme.colorScheme.onError;
      case AppButtonVariant.secondary:
        return theme.colorScheme.onSecondaryContainer;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
