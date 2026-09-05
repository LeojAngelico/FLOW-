import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../utils/volume_format.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-22. One row per logged entry: amount + time, newest first.
///
/// Overflow menu deliberately absent this pass — see
/// `docs/workplans/2026-09-04-hydration-logging.md` Decisions #10.
/// `undo`/`delete`/`edit` all need the `BR-08` reconciliation pipeline
/// (reverse XP, streak, achievements), which ships with gamification; a
/// control that would do nothing is worse than no control.
class LogRow extends StatelessWidget {
  const LogRow({required this.amountMl, required this.occurredAt, super.key});

  final int amountMl;

  /// The instant this entry was logged, already converted to the
  /// device's local time by the caller — this widget only formats it
  /// (via `intl`'s [DateFormat.jm]), it does not convert timezones.
  final DateTime occurredAt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return MergeSemantics(
      child: Container(
        key: const ValueKey('log-row'),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: 2),
          // 8 matches FlowRadius.sm.
          borderRadius: BorderRadius.circular(FlowRadius.sm),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 11,
              height: 14,
              child: SvgPicture.asset(
                'assets/icons/onboarding/icon-droplet.svg',
              ),
            ),
            const SizedBox(width: FlowSpacing.sm),
            Expanded(
              child: Text(
                formatVolumeMl(amountMl),
                style: typography.bodyL.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              DateFormat.jm().format(occurredAt),
              style: typography.bodyM.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
