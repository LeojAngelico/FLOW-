import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../domain/models/onboarding_rules.dart';
import '../../domain/providers/onboarding_usecase_providers.dart';
import '../onboarding_draft_notifier.dart';
import 'target_state.dart';

part 'target_notifier.g.dart';

/// `ONB-07`'s screen-owned state: the suggested/editing/edited
/// transition (`TargetMode`), the ±50ml stepper and slider, and the
/// revert-to-suggested action.
///
/// Calls `CalculateSuggestedTarget` exactly once, in [build] — not on
/// every rebuild — matching the file plan's "calls it once when the
/// screen is first reached." If [OnboardingDraft.manualTargetMl] is
/// already set (the user adjusted it, went back, and returned),
/// [build] restores [TargetMode.edited] rather than resetting to the
/// suggestion, so Back/Forward preserves the edit (`FR-018`).
@riverpod
class TargetNotifier extends _$TargetNotifier {
  @override
  TargetState build() {
    final draft = ref.read(onboardingDraftProvider);
    final result = ref.read(calculateSuggestedTargetProvider).call(draft);

    return switch (result) {
      Ok(:final value) => TargetState(
        mode: draft.manualTargetMl != null
            ? TargetMode.edited
            : TargetMode.suggested,
        suggestion: value,
        draftTargetMl: draft.manualTargetMl,
      ),
      Err(:final failure) => TargetState(failure: failure),
    };
  }

  /// `CPY-078` — switches the hero to its editor variant. Does **not**
  /// write `manualTargetMl` yet: entering the editor is not itself an
  /// edit (see `TargetMode`'s doc comment) — only [_applyEdit] is.
  void startAdjusting() {
    final suggestion = state.suggestion;
    if (suggestion == null) return;
    state = state.copyWith(
      mode: TargetMode.editing,
      draftTargetMl: state.draftTargetMl ?? suggestion.amountMl,
    );
  }

  /// A single ±50ml stepper tap.
  void adjustBy(int deltaMl) {
    final current = state.draftTargetMl ?? state.suggestion?.amountMl;
    if (current == null) return;
    _applyEdit(current + deltaMl);
  }

  /// A slider drag/commit, already rounded to a 50ml step by
  /// `FlowSlider`'s `step: 50` (`TargetHero`).
  void setDraftTargetMl(int valueMl) => _applyEdit(valueMl);

  void _applyEdit(int rawValueMl) {
    final clamped = rawValueMl.clamp(
      OnboardingRules.minTargetMl,
      OnboardingRules.maxTargetMl,
    );
    state = state.copyWith(mode: TargetMode.edited, draftTargetMl: clamped);
    ref.read(onboardingDraftProvider.notifier).setManualTargetMl(clamped);
  }

  /// `CPY-080` — discards any edit and returns to the calculator's
  /// suggestion. Available from both [TargetMode.editing] and
  /// [TargetMode.edited].
  void revertToSuggested() {
    state = state.copyWith(mode: TargetMode.suggested, draftTargetMl: null);
    ref.read(onboardingDraftProvider.notifier).setManualTargetMl(null);
  }
}
