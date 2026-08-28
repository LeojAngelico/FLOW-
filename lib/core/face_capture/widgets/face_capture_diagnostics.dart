import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_radius.dart';
import '../../ui_kit/tokens/app_spacing.dart';
import '../detection/face_sample.dart';

const Color _panelColor = Color(0xCC000000);
const Color _labelColor = Color(0x99FFFFFF);
const Color _valueColor = Color(0xFFFFFFFF);

/// The raw detection signals, for development builds only.
///
/// Face capture depends on values nobody can see — a yaw angle, a
/// width fraction — so when it misbehaves on a device the useful
/// question is "what did the detector actually report?". Guessing at
/// that from the outside costs a build-and-retest cycle each time; this
/// answers it at a glance.
///
/// Gated by `AppEnvironment.current.enableUiPlayground`, the project's
/// existing debug-tooling flag, so it is never present in prod.
class FaceCaptureDiagnostics extends StatelessWidget {
  final FaceSample? sample;

  /// 0..1 progress through the hold period.
  final double stabilityProgress;

  const FaceCaptureDiagnostics({
    super.key,
    required this.sample,
    required this.stabilityProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = sample;

    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: _panelColor,
          borderRadius: AppRadius.smAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(theme, 'faces', '${current?.faceCount ?? 0}'),
            // A dash here means ML Kit reported no head pose, which is
            // the difference between "the user is not turning far
            // enough" and "left/right cannot work at all".
            _row(theme, 'yaw', _degrees(current?.yawDegrees)),
            _row(theme, 'width', _fraction(current?.widthFraction)),
            _row(
              theme,
              'centre',
              '${_fraction(current?.centerX)}, ${_fraction(current?.centerY)}',
            ),
            // The second turn signal: keeps rising when the yaw has
            // stopped being meaningful.
            _row(theme, 'nose', _fraction(current?.noseOffsetFraction)),
            _row(theme, 'smile', _fraction(current?.smileProbability)),
            _row(theme, 'hold', _fraction(stabilityProgress)),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: _labelColor),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            color: _valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  static String _degrees(double? value) {
    return value == null ? '—' : '${value.toStringAsFixed(1)}°';
  }

  static String _fraction(double? value) {
    return value == null ? '—' : value.toStringAsFixed(2);
  }
}
