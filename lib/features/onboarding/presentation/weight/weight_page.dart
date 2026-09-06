import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/flow_slider.dart';
import '../../../../core/design/components/flow_text_field.dart';
import '../../../../core/design/components/game_panel.dart';
import '../../../../core/design/components/mascot_frame.dart';
import '../../../../core/design/components/stat_display.dart';
import '../../../../core/design/components/step_header.dart';
import '../../../../core/design/theme/reduce_motion_provider.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/onboarding_rules.dart';
import '../onboarding_draft_notifier.dart';
import '../widgets/onboarding_scaffold.dart';
import 'weight_notifier.dart';

/// `ONB-04`, step 2 of 5 — weight, prefilled as an estimate
/// ([weightPrefillKg]). Bloop **Steady** on the `sprite-scale-platform`
/// plinth. A `ConsumerStatefulWidget` only for the tap-to-type
/// controller/focus lifecycle and the local "is the hero currently in
/// text-edit mode" view state — every value lives in
/// `weight_notifier.dart`.
class WeightPage extends ConsumerStatefulWidget {
  const WeightPage({super.key});

  @override
  ConsumerState<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends ConsumerState<WeightPage> {
  late final TextEditingController _controller;
  bool _isEditingText = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(onboardingDraftProvider).weightKg == null) {
      ref.read(onboardingDraftProvider.notifier).setWeightKg(weightPrefillKg);
    }
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final reduceMotion = ref.watch(reduceMotionProvider);
    final state = ref.watch(weightProvider);
    final notifier = ref.read(weightProvider.notifier);

    if (_controller.text != state.fieldText) {
      _controller.text = state.fieldText;
      _controller.selection = TextSelection.collapsed(
        offset: state.fieldText.length,
      );
    }

    return OnboardingScaffold(
      header: StepHeader(
        stepLabel: loc.onboardingStepLabel(2, 5),
        currentStep: 2,
        onBack: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.onboardingWeightHeadline,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingWeightReassurance,
            style: typography.bodyM.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Center(
            child: MascotFrame(
              pose: MascotPose.steady,
              reduceMotion: reduceMotion,
            ),
          ),
          const SizedBox(height: FlowSpacing.lg),
          if (_isEditingText)
            GamePanel(
              variant: GamePanelVariant.deep,
              child: FlowTextField(
                controller: _controller,
                numericHero: true,
                errorText: state.error?.message,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: notifier.onTextChanged,
              ),
            )
          else
            StatDisplay(
              value: state.fieldText,
              unit: loc.onboardingWeightUnitLabel,
              onTap: () => setState(() => _isEditingText = true),
            ),
          const SizedBox(height: FlowSpacing.lg),
          FlowSlider(
            value: state.weightKg,
            min: OnboardingRules.minWeightKg,
            max: OnboardingRules.maxWeightKg,
            step: 0.5,
            unitLabel: loc.onboardingWeightUnitLabelSpoken,
            rangeLabelBuilder: (value) => value.round().toString(),
            onChanged: notifier.onSliderChanged,
          ),
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.continueButton,
        onPrimaryPressed: state.error == null
            ? () {
                setState(() => _isEditingText = false);
                context.push('/onboarding/activity');
              }
            : null,
      ),
    );
  }
}
