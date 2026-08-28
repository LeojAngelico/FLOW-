import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

class AppBottomSheetAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AppBottomSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// A generic action sheet — an optional title plus a list of tappable
/// actions. Used wherever the app needs to offer a short list of
/// choices (e.g. "Take Photo" / "Choose from Gallery") without each
/// call site hand-rolling its own `showModalBottomSheet`.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<void> showActions(
    BuildContext context, {
    String? title,
    required List<AppBottomSheetAction> actions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: Theme.of(sheetContext).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              for (final action in actions)
                ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.label),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    action.onTap();
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}
