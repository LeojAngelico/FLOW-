import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../ui_kit/buttons/app_button.dart';
import '../ui_kit/tokens/app_spacing.dart';
import '../utils/app_camera_permission.dart';

/// The "we need the camera" state, shared by every camera capability.
///
/// Both the QR scanner and face capture hit exactly the same four
/// permission states with exactly the same wording, so this lives once
/// here rather than twice inside those features. It isn't in the Core
/// UI Kit because it carries camera-specific copy and depends on
/// `AppCameraPermission` — the UI Kit stays purely presentational.
///
/// Unlike `AppErrorState` this needs to choose between two actions:
/// asking again is only offered when the OS would actually still show
/// the dialog.
class CameraPermissionView extends StatelessWidget {
  final CameraPermissionStatus status;

  /// Shows the system permission dialog again.
  final VoidCallback onRequestPermission;

  /// Opens the app's page in the OS settings.
  final VoidCallback onOpenSettings;

  const CameraPermissionView({
    super.key,
    required this.status,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  bool get _isRequestable => status == CameraPermissionStatus.denied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              loc.qrScannerPermissionTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              _messageFor(loc),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            if (_isRequestable)
              AppButton(
                label: loc.qrScannerAllowCameraAccess,
                width: 240,
                onPressed: onRequestPermission,
              )
            else
              AppButton(
                label: loc.qrScannerOpenSettings,
                width: 240,
                onPressed: onOpenSettings,
              ),
          ],
        ),
      ),
    );
  }

  String _messageFor(AppLocalizations loc) {
    switch (status) {
      case CameraPermissionStatus.restricted:
        return loc.qrScannerPermissionRestrictedMessage;
      case CameraPermissionStatus.permanentlyDenied:
        return loc.qrScannerPermissionBlockedMessage;
      case CameraPermissionStatus.denied:
      case CameraPermissionStatus.granted:
      case CameraPermissionStatus.unavailable:
        return loc.qrScannerPermissionMessage;
    }
  }
}
