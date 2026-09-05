import 'package:flutter/material.dart';

import '../../../../../core/design/components/game_panel.dart';
import '../../../../../core/design/components/primary_button.dart';
import '../../../../../core/design/tokens/flow_colors.dart';
import '../../../../../core/design/tokens/flow_spacing.dart';
import '../../../../../core/design/tokens/flow_typography.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../hydration/calculator/hydration_result.dart';
import '../../../../hydration/domain/models/profile_enums.dart';

/// `OVL-10` — rendered **from** [target]'s `breakdown`/`assumptions`/
/// `disclaimer`, never from hardcoded copy (`FR-012`, `05 OVL-10`). Every
/// id this sheet switches on is the vocabulary
/// `ReferenceIntakeV1`/`hydration_result.dart` define — see the
/// workplan's Decisions #7 and #20. The "Sources" row `08`'s copy spec
/// describes is omitted: no source list exists anywhere in this repo's
/// docs, and a link to nowhere is a dead end (§ Out of scope).
Future<void> showCalculationMethodSheet(
  BuildContext context,
  SuggestedHydrationTarget target,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CalculationMethodSheet(target: target),
  );
}

class _CalculationMethodSheet extends StatelessWidget {
  const _CalculationMethodSheet({required this.target});

  final SuggestedHydrationTarget target;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlowSpacing.md,
          FlowSpacing.md,
          FlowSpacing.md,
          FlowSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.onboardingCalcSheetTitle,
                style: typography.titleL.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: FlowSpacing.xs),
              Text(
                _methodName(loc, target.calculationMethodId),
                style: typography.bodyM.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: FlowSpacing.md),
              GamePanel(
                variant: GamePanelVariant.flat,
                child: Column(
                  children: [
                    for (final line in target.breakdown)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: FlowSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _breakdownLabel(
                                  loc,
                                  line.labelId,
                                  line.labelArg,
                                ),
                                style:
                                    (line.isSubtotal
                                            ? typography.titleM
                                            : typography.bodyM)
                                        .copyWith(color: colors.textPrimary),
                              ),
                            ),
                            Text(
                              _formatDelta(line.deltaMl, line.isSubtotal),
                              style:
                                  (line.isSubtotal
                                          ? typography.titleM
                                          : typography.bodyM)
                                      .copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: FlowSpacing.md),
              for (final assumptionId in target.assumptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: FlowSpacing.xs),
                  child: Text(
                    '•  ${_assumptionText(loc, assumptionId)}',
                    style: typography.bodyM.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: FlowSpacing.sm),
              Text(
                _disclaimerText(loc, target.disclaimer),
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: FlowSpacing.lg),
              PrimaryButton(
                label: loc.onboardingCalcGotIt,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _methodName(AppLocalizations loc, String calculationMethodId) {
  return switch (calculationMethodId) {
    'reference_intake_v1' => loc.onboardingCalcMethodReferenceIntake,
    _ => calculationMethodId,
  };
}

String _breakdownLabel(AppLocalizations loc, String labelId, String? labelArg) {
  return switch (labelId) {
    'baseline' => loc.onboardingCalcBaseline,
    'weightAdjustment' => loc.onboardingCalcWeightAdjustment,
    'activity' => loc.onboardingCalcActivity(_activityName(loc, labelArg)),
    'environment' => loc.onboardingCalcEnvironment(
      _environmentName(loc, labelArg),
    ),
    'totalWaterSubtotal' => loc.onboardingCalcTotalWaterSubtotal,
    'foodWaterDeduction' => loc.onboardingCalcFoodWaterDeduction,
    'drinkingTargetSubtotal' => loc.onboardingCalcDrinkingTargetSubtotal,
    _ => labelId,
  };
}

/// [labelArg] is an [ActivityLevel]'s `.name` (`reference_intake_v1.dart`)
/// — reuses the same title strings `activity_page.dart` shows, split at
/// their `·` separator, so the sheet and `ONB-05` never disagree on an
/// activity level's display name.
String _activityName(AppLocalizations loc, String? labelArg) {
  final combined = switch (labelArg) {
    'sedentary' => loc.onboardingActivitySedentary,
    'light' => loc.onboardingActivityLight,
    'moderate' => loc.onboardingActivityModerate,
    'high' => loc.onboardingActivityHigh,
    'athlete' => loc.onboardingActivityAthlete,
    _ => labelArg ?? '',
  };
  return combined.split('·').first.trim();
}

/// [labelArg] is an [Environment]'s `.name`. `ONB-06`'s tile labels carry
/// no descriptor to split off, so they are reused verbatim.
String _environmentName(AppLocalizations loc, String? labelArg) {
  return switch (labelArg) {
    'temperate' => loc.onboardingEnvironmentTemperate,
    'warm' => loc.onboardingEnvironmentWarm,
    'hot' => loc.onboardingEnvironmentHot,
    'veryHot' => loc.onboardingEnvironmentVeryHot,
    _ => labelArg ?? '',
  };
}

String _assumptionText(AppLocalizations loc, String assumptionId) {
  return switch (assumptionId) {
    'foodWaterFraction' => loc.onboardingCalcAssumptionFoodWaterFraction,
    'weightAdjustmentClamped' =>
      loc.onboardingCalcAssumptionWeightAdjustmentClamped,
    'resultClamped' => loc.onboardingCalcAssumptionResultClamped,
    _ => assumptionId,
  };
}

String _disclaimerText(AppLocalizations loc, String disclaimerId) {
  return switch (disclaimerId) {
    'referenceIntakeDisclaimer' => loc.onboardingCalcDisclaimer,
    _ => disclaimerId,
  };
}

/// Subtotal lines show their running total plainly; every other line
/// shows a signed delta (`+250 ml` / `−500 ml`) — raw millilitres, not
/// `formatVolumeMl`'s litre switch, which would read oddly for a small
/// delta in this breakdown context.
String _formatDelta(int deltaMl, bool isSubtotal) {
  if (isSubtotal) return '$deltaMl ml';
  if (deltaMl > 0) return '+$deltaMl ml';
  if (deltaMl < 0) return '−${deltaMl.abs()} ml';
  return '0 ml';
}
