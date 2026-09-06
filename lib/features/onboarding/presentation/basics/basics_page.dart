import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/flow_text_field.dart';
import '../../../../core/design/components/segmented_choice.dart';
import '../../../../core/design/components/step_header.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../hydration/domain/models/profile_enums.dart';
import '../../domain/models/onboarding_rules.dart';
import '../onboarding_draft_notifier.dart';
import '../widgets/onboarding_scaffold.dart';
import 'basics_notifier.dart';

/// `ONB-03`, step 1 of 5 — name (optional), age, sex.
///
/// A `ConsumerStatefulWidget` only because it owns the two
/// `TextEditingController`s' lifecycle (`flutter-ui-kit` SKILL: avoid
/// `StatefulWidget` unless genuinely required) — every value and every
/// validation rule lives in `basics_notifier.dart`/`onboarding_rules.dart`.
class BasicsPage extends ConsumerStatefulWidget {
  const BasicsPage({super.key});

  @override
  ConsumerState<BasicsPage> createState() => _BasicsPageState();
}

class _BasicsPageState extends ConsumerState<BasicsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    _nameController = TextEditingController(text: draft.displayName ?? '');
    _ageController = TextEditingController(text: draft.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final draft = ref.watch(onboardingDraftProvider);
    final basicsState = ref.watch(basicsProvider);
    final notifier = ref.read(basicsProvider.notifier);

    final ageErrorText = basicsState.ageTouched
        ? basicsState.ageError?.message
        : null;
    final nameErrorText = basicsState.nameTouched
        ? basicsState.nameError?.message
        : null;

    // Derived from the exact same field text `onAgeBlurred` validates
    // (not `draft.age`, which can go stale the moment the age field is
    // cleared — see `basics_notifier.dart`'s `validateAgeText` doc
    // comment) so Continue and the blur-shown error can never disagree.
    // `validateDisplayName` is included so a name over 24 characters
    // (shown inline as an error) also disables Continue, rather than
    // letting a name that will fail `user_profiles`' CHECK constraint
    // reach the completion write five screens later.
    final isValid =
        notifier.validateAgeText(_ageController.text) == null &&
        draft.sex != null &&
        OnboardingRules.validateDisplayName(draft.displayName) == null;

    return OnboardingScaffold(
      header: StepHeader(
        stepLabel: loc.onboardingStepLabel(1, 5),
        currentStep: 1,
        onBack: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.onboardingBasicsHeadline,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingBasicsSubhead,
            style: typography.bodyM.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingBasicsNameLabel,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) notifier.onNameBlurred();
            },
            child: FlowTextField(
              controller: _nameController,
              errorText: nameErrorText,
              inputFormatters: [LengthLimitingTextInputFormatter(48)],
              onChanged: notifier.onNameChanged,
            ),
          ),
          const SizedBox(height: FlowSpacing.xs),
          Text(
            loc.onboardingBasicsNameOptionalHelper,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingBasicsAgeLabel,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) notifier.onAgeBlurred(_ageController.text);
            },
            child: FlowTextField(
              controller: _ageController,
              errorText: ageErrorText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: notifier.onAgeChanged,
            ),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingBasicsSexLabel,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          SegmentedChoice<Sex?>(
            options: Sex.values,
            selected: draft.sex,
            segmentHeight: 56,
            labelBuilder: (option) => switch (option) {
              Sex.female => loc.onboardingBasicsSexFemale,
              Sex.male => loc.onboardingBasicsSexMale,
              Sex.preferNotToSay => loc.onboardingBasicsSexPreferNotToSay,
              null => '',
            },
            onChanged: (option) {
              if (option != null) notifier.onSexChanged(option);
            },
          ),
          const SizedBox(height: FlowSpacing.xs),
          Text(
            loc.onboardingBasicsSexHelper,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.continueButton,
        onPrimaryPressed: isValid
            ? () => context.push('/onboarding/weight')
            : null,
      ),
    );
  }
}
