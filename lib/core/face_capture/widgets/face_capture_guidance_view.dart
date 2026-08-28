import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_motion.dart';
import '../../ui_kit/tokens/app_spacing.dart';
import '../detection/face_capture_assessment.dart';
import '../face_capture_localizer.dart';

const Color _onCameraColor = Color(0xFFFFFFFF);
const Color _onCameraMutedColor = Color(0xB3FFFFFF);

/// The instruction under the face window, plus the quieter second line.
///
/// One instruction at a time, in plain words — never a probability, a
/// yaw angle, or anything else from inside the detector.
class FaceCaptureGuidanceView extends StatelessWidget {
  final FaceCaptureGuidance guidance;

  /// Shows the "hold still" line while the capture conditions are met
  /// and the hold period runs down.
  final bool isHolding;

  /// Whole seconds left to hold. Rendered as a countdown on the hold
  /// line, so the wait is something the user can watch ending rather
  /// than a ring they have to interpret.
  final int countdownSeconds;

  const FaceCaptureGuidanceView({
    super.key,
    required this.guidance,
    required this.isHolding,
    this.countdownSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nothing to add once the shutter is going, and nothing to say
    // until the pose is actually right.
    final isCountingDown =
        isHolding &&
        countdownSeconds > 0 &&
        guidance != FaceCaptureGuidance.capturing &&
        guidance != FaceCaptureGuidance.captured;

    final showHoldLine =
        isHolding &&
        guidance != FaceCaptureGuidance.capturing &&
        guidance != FaceCaptureGuidance.captured;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Keyed on the guidance value, so a new instruction
          // cross-fades in rather than snapping.
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              FaceCaptureLocalizer.guidance(context, guidance),
              key: ValueKey<FaceCaptureGuidance>(guidance),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _onCameraColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: showHoldLine ? AppSpacing.sm : 0),
          if (showHoldLine)
            Semantics(
              // Read as one sentence, so a screen reader announces the
              // count rather than a stray digit.
              label: isCountingDown
                  ? FaceCaptureLocalizer.holdCountdown(
                      context,
                      countdownSeconds,
                    )
                  : FaceCaptureLocalizer.guidance(
                      context,
                      FaceCaptureGuidance.holdStill,
                    ),
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      FaceCaptureLocalizer.guidance(
                        context,
                        FaceCaptureGuidance.holdStill,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _onCameraMutedColor,
                      ),
                    ),
                  ),
                  if (isCountingDown) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _CountdownBadge(seconds: countdownSeconds),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The seconds left, as a number the user can watch tick down.
///
/// A badge rather than part of the sentence: it is the only thing on
/// screen that changes every second, and it should be readable at a
/// glance without reading words.
class _CountdownBadge extends StatelessWidget {
  final int seconds;

  const _CountdownBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // `primary` rather than `tertiary`: the countdown is still in
    // progress, and it matches the readiness ring while it fills.
    final accent = theme.colorScheme.primary;

    return AnimatedSwitcher(
      duration: AppMotion.fast,
      child: Container(
        key: ValueKey<int>(seconds),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: 0.7)),
        ),
        child: Text(
          '$seconds',
          style: theme.textTheme.titleMedium?.copyWith(
            color: _onCameraColor,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
