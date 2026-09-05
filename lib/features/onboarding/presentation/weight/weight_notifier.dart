import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/onboarding_rules.dart';
import '../onboarding_draft_notifier.dart';
import 'weight_state.dart';

part 'weight_notifier.g.dart';

/// `ONB-04`'s prefilled estimate (`05 ONB-04`, § Open product questions
/// — "prefilled 65 kg, marked as an estimate"). Written to the draft by
/// `weight_page.dart`'s `initState` the first time this screen is
/// reached, so a user who never touches the field still submits a
/// valid, already-clamped value.
const weightPrefillKg = 65.0;

/// `ONB-04`'s screen-owned state: keeps the typed text and the slider
/// in sync. The hard part this notifier solves: a slider drag must not
/// fight a partially-typed field. [WeightState.fieldText] only ever
/// changes from an explicit slider commit or an explicit keystroke —
/// never recomputed from [WeightState.weightKg] on every rebuild — so a
/// keystroke is never silently overwritten mid-edit.
@riverpod
class WeightNotifier extends _$WeightNotifier {
  @override
  WeightState build() {
    final weightKg =
        ref.read(onboardingDraftProvider).weightKg ?? weightPrefillKg;
    return WeightState(weightKg: weightKg, fieldText: _formatWeight(weightKg));
  }

  /// Called on every keystroke. Only writes through to the shared draft
  /// once [text] parses to a value inside
  /// [OnboardingRules.minWeightKg]/[OnboardingRules.maxWeightKg] — an
  /// out-of-range or unparsable intermediate value (e.g. typing "3" on
  /// the way to "30") is left as a visible error instead of being
  /// silently clamped, which would fight the keystroke that produced it.
  void onTextChanged(String text) {
    final parsed = double.tryParse(text);
    final error = parsed == null
        ? OnboardingRules.validateWeightKg(OnboardingRules.minWeightKg - 1)
        : OnboardingRules.validateWeightKg(parsed);

    state = state.copyWith(fieldText: text, error: error);

    if (parsed != null && error == null) {
      final rounded = _roundToOneDecimal(parsed);
      state = state.copyWith(weightKg: rounded);
      ref.read(onboardingDraftProvider.notifier).setWeightKg(rounded);
    }
  }

  /// A slider drag always commits an in-range value, clamped defensively
  /// even though [FlowSlider] itself never emits outside `min`/`max`.
  void onSliderChanged(double value) {
    final clamped = value.clamp(
      OnboardingRules.minWeightKg,
      OnboardingRules.maxWeightKg,
    );
    final rounded = _roundToOneDecimal(clamped);
    state = state.copyWith(
      weightKg: rounded,
      fieldText: _formatWeight(rounded),
      error: null,
    );
    ref.read(onboardingDraftProvider.notifier).setWeightKg(rounded);
  }
}

double _roundToOneDecimal(double value) => (value * 10).round() / 10;

String _formatWeight(double kg) {
  return kg % 1 == 0 ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
}
