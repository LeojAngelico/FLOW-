import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/check_row.dart';
import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/icon_choice_tile.dart';
import '../../../../core/design/components/info_card.dart';
import '../../../../core/design/components/step_header.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../hydration/domain/models/profile_enums.dart';
import '../onboarding_draft_notifier.dart';
import '../widgets/onboarding_scaffold.dart';

/// `ONB-06`, step 4 of 5 — everyday environment plus special
/// circumstances. No notifier (Decisions #3): every control here writes
/// straight through to the shared draft with no screen-owned transient
/// state — `OnboardingDraftNotifier.toggleSpecialCircumstance` already
/// owns the only non-trivial piece (toggling a member of a `Set`).
class EnvironmentPage extends ConsumerWidget {
  const EnvironmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final draft = ref.watch(onboardingDraftProvider);
    final notifier = ref.read(onboardingDraftProvider.notifier);

    final environments = <Environment, String>{
      Environment.temperate: loc.onboardingEnvironmentTemperate,
      Environment.warm: loc.onboardingEnvironmentWarm,
      Environment.hot: loc.onboardingEnvironmentHot,
      Environment.veryHot: loc.onboardingEnvironmentVeryHot,
    };

    final circumstances = <SpecialCircumstance, String>{
      SpecialCircumstance.pregnancy: loc.onboardingCircumstancePregnancy,
      SpecialCircumstance.breastfeeding:
          loc.onboardingCircumstanceBreastfeeding,
      SpecialCircumstance.medicalCondition:
          loc.onboardingCircumstanceMedicalCondition,
      SpecialCircumstance.other: loc.onboardingCircumstanceOther,
    };

    final hasCircumstance = draft.specialCircumstances.isNotEmpty;

    return OnboardingScaffold(
      header: StepHeader(
        stepLabel: loc.onboardingStepLabel(4, 5),
        currentStep: 4,
        onBack: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.onboardingEnvironmentHeadline,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingEnvironmentSubhead,
            style: typography.bodyM.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: FlowSpacing.sm,
            crossAxisSpacing: FlowSpacing.sm,
            childAspectRatio: 1.9,
            children: [
              for (final environment in Environment.values)
                Semantics(
                  inMutuallyExclusiveGroup: true,
                  selected: draft.environment == environment,
                  child: IconChoiceTile(
                    label: environments[environment]!,
                    level: environment.index + 1,
                    selected: draft.environment == environment,
                    onTap: () => notifier.setEnvironment(environment),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FlowSpacing.lg),
          Divider(color: colors.border),
          const SizedBox(height: FlowSpacing.md),
          Text(
            loc.onboardingCircumstancesLabel,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          for (final circumstance in SpecialCircumstance.values)
            CheckRow(
              label: circumstances[circumstance]!,
              checked: draft.specialCircumstances.contains(circumstance),
              onChanged: (_) =>
                  notifier.toggleSpecialCircumstance(circumstance),
            ),
          if (hasCircumstance) ...[
            const SizedBox(height: FlowSpacing.md),
            Semantics(
              liveRegion: true,
              child: InfoCard(message: loc.onboardingCircumstanceNotice),
            ),
          ],
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.continueButton,
        onPrimaryPressed: draft.environment != null
            ? () => context.push('/onboarding/target')
            : null,
      ),
    );
  }
}
