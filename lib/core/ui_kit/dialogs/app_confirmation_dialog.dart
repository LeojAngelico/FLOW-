import 'package:flutter/material.dart';

import '../buttons/app_button.dart';
import 'app_dialog.dart';

/// A yes/no confirmation dialog built on [AppDialog].
///
/// ```dart
/// AppConfirmationDialog.show(
///   context,
///   title: 'Delete Report',
///   message: 'Are you sure you want to delete this report?',
///   onConfirm: deleteReport,
/// );
/// ```
class AppConfirmationDialog {
  AppConfirmationDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;

        return AppDialog(
          title: title,
          icon: icon ?? (isDestructive ? Icons.warning_amber_rounded : null),
          iconColor: isDestructive ? scheme.error : null,
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            AppButton(
              label: cancelLabel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            AppButton(
              label: confirmLabel,
              variant: isDestructive
                  ? AppButtonVariant.destructive
                  : AppButtonVariant.primary,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirm();
    } else {
      onCancel?.call();
    }
  }
}
