import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_spacing.dart';
import '../detection/face_capture_assessment.dart';
import '../face_capture_localizer.dart';

const Color _onCameraColor = Color(0xFFFFFFFF);
const Color _onCameraMutedColor = Color(0xB3FFFFFF);

/// The big readiness number and its one-word summary.
///
/// Sits above the face window, where the reference puts it: the user
/// can watch it climb without looking away from their own face.
class FaceCaptureReadiness extends StatelessWidget {
  final int score;
  final FaceReadinessLabel label;

  const FaceCaptureReadiness({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$score',
              style: theme.textTheme.displaySmall?.copyWith(
                color: _onCameraColor,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _onCameraMutedColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          FaceCaptureLocalizer.readiness(context, label),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: label == FaceReadinessLabel.ready
                ? scheme.tertiary
                : scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
