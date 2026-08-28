import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// The Core UI Kit's base dialog.
///
/// A composable shell (icon, title, content, actions) rather than
/// a family of specialized dialogs — build specific dialogs like
/// [AppConfirmationDialog] on top of it, or use it directly:
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     title: 'Export complete',
///     content: Text('Your report was saved to Downloads.'),
///     actions: [AppButton(label: 'OK', onPressed: () => context.pop())],
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? content;
  final List<Widget> actions;

  const AppDialog({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.content,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      icon: icon != null
          ? Icon(icon, color: iconColor ?? theme.colorScheme.primary)
          : null,
      title: Text(title, textAlign: TextAlign.center),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      content: content,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: actions.isEmpty ? null : actions,
    );
  }
}
