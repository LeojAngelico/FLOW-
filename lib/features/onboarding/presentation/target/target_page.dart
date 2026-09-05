import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/flow_text_button.dart';
import '../../../../core/design/components/info_card.dart';
import '../../../../core/design/components/mascot_frame.dart';
import '../../../../core/design/components/step_header.dart';
import '../../../../core/design/components/target_hero.dart';
import '../../../../core/design/theme/reduce_motion_provider.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/onboarding_rules.dart';
import '../widgets/onboarding_scaffold.dart';
import 'target_notifier.dart';
import 'target_state.dart';
import 'widgets/calculation_method_sheet.dart';

/// `ONB-07`, step 5 of 5 — the suggested target, **the most important
/// screen in the flow.** `13 §14.1`'s forbidden-word list is binding
/// here: no *must*, *need to*, *required*, *minimum*, and no red — this
/// screen informs, it never pressures (`05`).
///
/// [TargetMode.suggested] shows `TargetHero` in its `viewing` mode with
/// Accept/Adjust; [TargetMode.editing]/[TargetMode.edited] swap it to
/// `editing` mode with Continue/"use suggested instead" — see
/// `target_notifier.dart`'s doc comment for why those two sub-modes are
/// kept distinct.
class TargetPage extends ConsumerWidget {
  const TargetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final reduceMotion = ref.watch(reduceMotionProvider);
    final state = ref.watch(targetProvider);
    final notifier = ref.read(targetProvider.notifier);

    final suggestion = state.suggestion;

    if (suggestion == null) {
      // Defensive only — the router never lets a user reach `ONB-07`
      // with an incomplete draft. Kept simple rather than a full error
      // page: there is nowhere useful to go except back.
      return OnboardingScaffold(
        header: StepHeader(
          stepLabel: loc.onboardingStepLabel(5, 5),
          currentStep: 5,
          onBack: () => context.pop(),
        ),
        body: InfoCard(
          message: loc.onboardingTargetIncompleteDraft,
          kind: InfoCardKind.caution,
        ),
      );
    }

    final isEditing = state.mode != TargetMode.suggested;
    final displayedMl = state.draftTargetMl ?? suggestion.amountMl;
    final glasses = (displayedMl / 250).round();

    return OnboardingScaffold(
      header: StepHeader(
        stepLabel: loc.onboardingStepLabel(5, 5),
        currentStep: 5,
        onBack: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // `CPY-070` must be visible without scrolling whenever a
          // special circumstance was checked (`FR-011`) — rendered first,
          // above the hero, so it is never pushed below the fold.
          if (suggestion.requiresProfessionalNotice) ...[
            Semantics(
              liveRegion: true,
              child: InfoCard(message: loc.onboardingTargetProfessionalNotice),
            ),
            const SizedBox(height: FlowSpacing.md),
          ],
          Text(
            loc.onboardingTargetHeadline,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Center(
            child: MascotFrame(
              pose: MascotPose.encouraging,
              reduceMotion: reduceMotion,
            ),
          ),
          const SizedBox(height: FlowSpacing.lg),
          if (isEditing)
            // In the editor, the stepper buttons and the slider must each
            // keep their own semantics (manual QA: the slider announces
            // "N kilograms"-style values and the steppers announce as
            // buttons) — no merged override here.
            TargetHero(
              eyebrow: loc.onboardingTargetEyebrow,
              valueMl: displayedMl,
              mode: TargetHeroMode.editing,
              minMl: OnboardingRules.minTargetMl,
              maxMl: OnboardingRules.maxTargetMl,
              rangeLabelBuilder: (value) => value.round().toString(),
              onDecrement: displayedMl > OnboardingRules.minTargetMl
                  ? () => notifier.adjustBy(-50)
                  : null,
              onIncrement: displayedMl < OnboardingRules.maxTargetMl
                  ? () => notifier.adjustBy(50)
                  : null,
              onSliderChanged: (value) =>
                  notifier.setDraftTargetMl(value.round()),
            )
          else
            // One accessible node for the read-only value, matching the
            // hydration summary precedent (`FR-030`/`FR-031`, manual QA
            // item 12: "Your suggested daily target: 2 litres, 2000
            // millilitres" as one node) rather than a screen reader
            // walking the eyebrow and the number separately.
            Semantics(
              label: loc.onboardingTargetHeroSemantics(displayedMl),
              child: ExcludeSemantics(
                child: TargetHero(
                  eyebrow: loc.onboardingTargetEyebrow,
                  valueMl: displayedMl,
                  rangeLabelBuilder: (value) => value.round().toString(),
                ),
              ),
            ),
          const SizedBox(height: FlowSpacing.md),
          if (!isEditing && OnboardingRules.isHighTarget(displayedMl)) ...[
            Semantics(
              liveRegion: true,
              child: InfoCard(
                message: loc.onboardingTargetHighCaution,
                kind: InfoCardKind.caution,
              ),
            ),
            const SizedBox(height: FlowSpacing.md),
          ],
          Text(
            loc.onboardingTargetGlassesAnchor(glasses),
            style: typography.bodyM.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          if (isEditing)
            Text(
              loc.onboardingTargetEditingInstruction,
              style: typography.bodyM.copyWith(color: colors.textSecondary),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FlowTextButton(
                label: loc.onboardingTargetSeeCalculation,
                showIcon: false,
                onPressed: () =>
                    showCalculationMethodSheet(context, suggestion),
              ),
            ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingCalcDisclaimer,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      cta: isEditing
          ? CtaSection(
              variant: CtaSectionVariant.primaryAndSecondary,
              primaryLabel: loc.continueButton,
              onPrimaryPressed: () => context.push('/onboarding/reminders'),
              secondaryLabel: loc.onboardingTargetRevertToSuggested,
              onSecondaryPressed: notifier.revertToSuggested,
            )
          : CtaSection(
              variant: CtaSectionVariant.primaryAndSecondary,
              primaryLabel: loc.onboardingTargetAccept,
              onPrimaryPressed: () => context.push('/onboarding/reminders'),
              secondaryLabel: loc.onboardingTargetAdjust,
              onSecondaryPressed: notifier.startAdjusting,
            ),
    );
  }
}
