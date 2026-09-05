import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/failure.dart';
import '../../../hydration/domain/models/profile_enums.dart';
import '../../domain/models/onboarding_rules.dart';
import '../onboarding_draft_notifier.dart';
import 'basics_state.dart';

part 'basics_notifier.g.dart';

/// `ONB-03`'s screen-owned state: which fields have been blurred and
/// the currently-shown error for each (`05 ONB-03`: validate on blur,
/// not per keystroke). Writes every change straight through to the
/// shared [OnboardingDraftNotifier] — the bounds themselves live in
/// [OnboardingRules], never here.
@riverpod
class BasicsNotifier extends _$BasicsNotifier {
  @override
  BasicsState build() => const BasicsState();

  void onNameChanged(String value) {
    ref.read(onboardingDraftProvider.notifier).setDisplayName(value);
    if (state.nameTouched) {
      state = state.copyWith(
        nameError: OnboardingRules.validateDisplayName(value),
      );
    }
  }

  void onNameBlurred() {
    final name = ref.read(onboardingDraftProvider).displayName;
    state = state.copyWith(
      nameTouched: true,
      nameError: OnboardingRules.validateDisplayName(name),
    );
  }

  /// Only writes through to the draft when [value] parses to a whole
  /// number — the field is digits-only
  /// (`FilteringTextInputFormatter.digitsOnly`), so the only unparsable
  /// case is an emptied field. That case is left as the draft's last
  /// value rather than attempting to clear `OnboardingDraft.age` back to
  /// `null`, which its `copyWith` does not support (only `displayName`
  /// and `manualTargetMl` are clearable, per the domain layer's design).
  void onAgeChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      ref.read(onboardingDraftProvider.notifier).setAge(parsed);
    }
    if (state.ageTouched) {
      state = state.copyWith(ageError: _validateAgeText(value));
    }
  }

  void onAgeBlurred() {
    final currentText = ref.read(onboardingDraftProvider).age?.toString() ?? '';
    state = state.copyWith(
      ageTouched: true,
      ageError: _validateAgeText(currentText),
    );
  }

  ValidationFailure? _validateAgeText(String text) {
    final parsed = int.tryParse(text);
    // An empty/unparsable field is not a valid age either — reuses
    // `OnboardingRules.validateAge`'s own `CPY-031` message rather than
    // inventing a second "required" string for the same field.
    return OnboardingRules.validateAge(parsed ?? OnboardingRules.minAge - 1);
  }

  void onSexChanged(Sex value) {
    ref.read(onboardingDraftProvider.notifier).setSex(value);
  }
}
