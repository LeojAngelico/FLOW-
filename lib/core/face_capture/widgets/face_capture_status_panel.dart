import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_radius.dart';
import '../../ui_kit/tokens/app_spacing.dart';
import '../detection/face_capture_assessment.dart';
import '../face_capture_localizer.dart';

const Color _panelColor = Color(0x66000000);

/// The compact condition read-out along the bottom of the scanner.
///
/// Shows *what the user can act on* — face, framing, orientation,
/// steadiness, smile — and nothing about how the detector reached that
/// conclusion. Position and distance are two rules internally but one
/// row here, because "your framing is off" is the only actionable part.
class FaceCaptureStatusPanel extends StatelessWidget {
  final FaceCaptureAssessment assessment;

  const FaceCaptureStatusPanel({super.key, required this.assessment});

  static const List<(FaceCaptureCheck, IconData)> _rows = [
    (FaceCaptureCheck.face, Icons.face_outlined),
    (FaceCaptureCheck.position, Icons.center_focus_strong_outlined),
    (FaceCaptureCheck.orientation, Icons.threesixty),
    (FaceCaptureCheck.stability, Icons.monitor_heart_outlined),
    (FaceCaptureCheck.smile, Icons.mood_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: _panelColor,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          for (final (check, icon) in _rows)
            Expanded(
              child: _StatusItem(
                icon: icon,
                check: check,
                status: _statusFor(check),
              ),
            ),
        ],
      ),
    );
  }

  /// Framing is only "good" when the face is both centred and at a
  /// usable distance.
  FaceCheckStatus _statusFor(FaceCaptureCheck check) {
    if (check != FaceCaptureCheck.position) {
      return assessment.statusOf(check);
    }

    final centered = assessment.statusOf(FaceCaptureCheck.position);
    final distance = assessment.statusOf(FaceCaptureCheck.distance);

    return centered == FaceCheckStatus.passed &&
            distance == FaceCheckStatus.passed
        ? FaceCheckStatus.passed
        : FaceCheckStatus.pending;
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final FaceCaptureCheck check;
  final FaceCheckStatus status;

  const _StatusItem({
    required this.icon,
    required this.check,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color color, Color background) = switch (status) {
      FaceCheckStatus.passed => (
        scheme.tertiary,
        scheme.tertiary.withValues(alpha: 0.16),
      ),
      FaceCheckStatus.pending => (
        const Color(0x99FFFFFF),
        const Color(0x1FFFFFFF),
      ),
      FaceCheckStatus.notApplicable => (
        const Color(0x61FFFFFF),
        const Color(0x14FFFFFF),
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          FaceCaptureLocalizer.checkLabel(context, check),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
        Text(
          FaceCaptureLocalizer.checkValue(context, check, status),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
