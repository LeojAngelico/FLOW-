import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/choice_card.dart';
import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/step_header.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../hydration/domain/models/profile_enums.dart';
import '../onboarding_draft_notifier.dart';
import '../widgets/onboarding_scaffold.dart';

/// `ONB-05`, step 3 of 5 — activity level. No notifier
/// (Decisions #3): a `ChoiceCard` selection is a plain draft write with
/// no screen-owned transient state, so a dedicated notifier would be an
/// empty layer.
///
/// Each `ChoiceCard`'s title/descriptor is one ARB string split at the
/// `·` separator (`CPY-050`–`CPY-054`), per the workplan's file plan.
/// Selection carries **radio** semantics (`inMutuallyExclusiveGroup`,
/// `selected:`) via `FlowTappable`'s `selected` trait, and is shown by
/// check icon + border + accessible state — never colour alone
/// (`06 §2.6` rule 1).
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final draft = ref.watch(onboardingDraftProvider);
    final notifier = ref.read(onboardingDraftProvider.notifier);

    final options = <ActivityLevel, String>{
      ActivityLevel.sedentary: loc.onboardingActivitySedentary,
      ActivityLevel.light: loc.onboardingActivityLight,
      ActivityLevel.moderate: loc.onboardingActivityModerate,
      ActivityLevel.high: loc.onboardingActivityHigh,
      ActivityLevel.athlete: loc.onboardingActivityAthlete,
    };

    return OnboardingScaffold(
      header: StepHeader(
        stepLabel: loc.onboardingStepLabel(3, 5),
        currentStep: 3,
        onBack: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.onboardingActivityHeadline,
              maxLines: 2,
              style: onboardingTitleStyle(
                context,
              ).copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingActivitySubhead,
            style: typography.bodyM.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          for (final level in ActivityLevel.values) ...[
            _ActivityChoiceCard(
              level: level,
              combinedLabel: options[level]!,
              selected: draft.activityLevel == level,
              onTap: () => notifier.setActivityLevel(level),
            ),
            if (level != ActivityLevel.values.last)
              const SizedBox(height: FlowSpacing.sm),
          ],
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.continueButton,
        onPrimaryPressed: draft.activityLevel != null
            ? () => context.push('/onboarding/environment')
            : null,
      ),
    );
  }
}

/// One activity `ChoiceCard`, wrapping selection in `Semantics.selected`
/// (radio-style, per `ONB-05`'s a11y requirement) and mapping the
/// activity's declaration order (`profile_enums.dart`) to the bar-meter
/// fill (1–5 bars).
class _ActivityChoiceCard extends StatelessWidget {
  const _ActivityChoiceCard({
    required this.level,
    required this.combinedLabel,
    required this.selected,
    required this.onTap,
  });

  final ActivityLevel level;
  final String combinedLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = combinedLabel.split('·');
    final title = parts.first.trim();
    final description = parts.length > 1 ? parts[1].trim() : '';

    // `ChoiceCard`/`FlowTappable` already exposes `selected:` on its own
    // semantics node; this outer node only adds the radio-group trait so
    // a screen reader announces "radio button, selected" rather than a
    // plain "button, selected" (`06 §2.6` rule 1).
    return Semantics(
      inMutuallyExclusiveGroup: true,
      child: ChoiceCard(
        title: title,
        description: description,
        barsFilled: level.index + 1,
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}
