import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// A non-dismissible blocking dialog for short, must-wait operations
/// (e.g. logging out) — as opposed to inline button loading states,
/// which are preferred for form submissions.
class AppLoadingDialog {
  AppLoadingDialog._();

  static Future<void> show(BuildContext context, {required String message}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(child: Text(message)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Dismisses a dialog previously shown with [show].
  static void hide(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
