import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

/// Themed snackbars for the app's common feedback states.
///
/// ```dart
/// AppSnackbar.success(context, message: 'Saved successfully');
/// ```
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, {required String message}) {
    final scheme = Theme.of(context).colorScheme;

    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      background: scheme.tertiaryContainer,
      foreground: scheme.onTertiaryContainer,
    );
  }

  static void error(BuildContext context, {required String message}) {
    final scheme = Theme.of(context).colorScheme;

    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
    );
  }

  static void warning(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_outlined,
      background: AppColors.warningContainer,
      foreground: AppColors.onWarningContainer,
    );
  }

  static void info(BuildContext context, {required String message}) {
    final scheme = Theme.of(context).colorScheme;

    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
  }
}
