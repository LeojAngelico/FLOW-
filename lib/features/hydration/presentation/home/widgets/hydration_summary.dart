import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design/components/hydration_glass.dart';
import '../../../../../core/design/theme/reduce_motion_provider.dart';
import '../../../../../core/design/tokens/flow_colors.dart';
import '../../../../../core/design/tokens/flow_spacing.dart';
import '../../../../../core/design/tokens/flow_typography.dart';
import '../../../../../core/utils/volume_format.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/logged_water.dart';
import '../../../domain/models/today_hydration.dart';

/// `FR-030`/`FR-031`: today's consumed ml, target ml, percentage and
/// remaining ml — all four, graphically (`CMP-47 HydrationGlass`) *and*
/// textually, without scrolling at 360x640dp.
///
/// Exposed as **one** semantics node (`APP-01` a11y requirement):
/// [HydrationGlass] already excludes itself from semantics (it has no
/// meaningful standalone reading), and every text descendant here is
/// wrapped in an outer [ExcludeSemantics] so a screen reader doesn't
/// also walk each number individually — the single [Semantics.label]
/// below is read instead, as one sentence. `liveRegion: true` is what
/// makes that label re-announce itself after a log changes the total.
class HydrationSummary extends ConsumerWidget {
  const HydrationSummary({required this.today, required this.lastLogged, super.key});

  final TodayHydration today;

  /// The most recent successful write, if any — shown as a small
  /// "+{amount}" (`CPY-106`) badge near the numbers.
  final LoggedWater? lastLogged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final reduceMotion = ref.watch(reduceMotionProvider);

    final totalText = formatVolumeMl(today.totalMl);
    final targetText = formatVolumeMl(today.effectiveTargetMl);
    final remainingText = formatVolumeMl(today.remainingMl);
    // The *textual* percent reads the true, uncapped progress
    // (`TodayHydration.progressFraction`'s own doc comment: "FR-033
    // requires the text to show the true total even past 100%"). Only
    // the glass's fill is capped, inside HydrationGlass itself.
    final percentText = formatPercent(today.progressFraction);
    final percentValue = (today.progressFraction * 100).round();
    final isEmpty = today.entryCount == 0;

    final semanticsLabel = today.goalCompleted
        ? loc.hydrationSummarySemanticsComplete(
            totalText,
            targetText,
            percentValue,
          )
        : loc.hydrationSummarySemantics(
            totalText,
            targetText,
            percentValue,
            remainingText,
          );

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEmpty ? loc.hydrationFreshDay : loc.hydrationTodaysGoal,
              style: typography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: FlowSpacing.sm),
            HydrationGlass(
              currentMl: today.totalMl,
              targetMl: today.effectiveTargetMl,
              goalCompleted: today.goalCompleted,
              reduceMotion: reduceMotion,
            ),
            const SizedBox(height: FlowSpacing.md),
            Text(
              totalText,
              style: typography.numericHero.copyWith(color: colors.textPrimary),
            ),
            Text(
              loc.hydrationOfTarget(targetText),
              style: typography.bodyM.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: FlowSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  percentText,
                  style: typography.numericL.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(width: FlowSpacing.lg),
                Text(
                  today.goalCompleted
                      ? loc.hydrationGoalComplete
                      : loc.hydrationRemainingToGo(remainingText),
                  style: typography.bodyM.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            if (isEmpty) ...[
              const SizedBox(height: FlowSpacing.sm),
              Text(
                loc.hydrationEmptyHint,
                textAlign: TextAlign.center,
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
            if (lastLogged != null) ...[
              const SizedBox(height: FlowSpacing.sm),
              Text(
                loc.hydrationJustLogged(formatVolumeMl(lastLogged!.amountMl)),
                style: typography.label.copyWith(color: colors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
