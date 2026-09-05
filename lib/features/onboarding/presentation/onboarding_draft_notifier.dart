import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../hydration/domain/models/profile_enums.dart';
import '../domain/models/onboarding_draft.dart';
import '../domain/models/reminder_preferences.dart';

part 'onboarding_draft_notifier.g.dart';

/// The shared, `keepAlive` draft that survives Back and Forward across
/// all six answer screens (`FR-018`) — see the workplan's Decisions #3.
/// State **is** the domain [OnboardingDraft]; there is no separate
/// `onboarding_draft_state.dart` because the domain model already is the
/// state. Every screen writes through exactly one mutator here rather
/// than keeping its own copy of an answer.
///
/// `keepAlive` is load-bearing, not a convenience: an `autoDispose`
/// provider is torn down while no screen watches it during a route
/// transition, which would silently drop the draft on the first Back
/// and fail `FR-018` in a way that only shows up on a real device.
@Riverpod(keepAlive: true)
class OnboardingDraftNotifier extends _$OnboardingDraftNotifier {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  /// `ONB-03`. `null`/empty is the valid "no name given" answer
  /// (`FR-003`) — this writes through whatever the field currently
  /// holds, untrimmed; trimming happens only inside
  /// `OnboardingRules.validateDisplayName`.
  void setDisplayName(String? value) {
    state = state.copyWith(displayName: value);
  }

  /// `ONB-03`.
  void setAge(int value) {
    state = state.copyWith(age: value);
  }

  /// `ONB-03`.
  void setSex(Sex value) {
    state = state.copyWith(sex: value);
  }

  /// `ONB-04`.
  void setWeightKg(double value) {
    state = state.copyWith(weightKg: value);
  }

  /// `ONB-05`.
  void setActivityLevel(ActivityLevel value) {
    state = state.copyWith(activityLevel: value);
  }

  /// `ONB-06`.
  void setEnvironment(Environment value) {
    state = state.copyWith(environment: value);
  }

  /// `ONB-06`. Toggling a checkbox is a plain state assignment, not a
  /// business rule, so it lives here rather than requiring a dedicated
  /// screen notifier for `environment_page.dart` (Decisions #3: that
  /// screen gets none).
  void toggleSpecialCircumstance(SpecialCircumstance value) {
    final updated = Set<SpecialCircumstance>.from(state.specialCircumstances);
    if (!updated.remove(value)) {
      updated.add(value);
    }
    state = state.copyWith(specialCircumstances: updated);
  }

  /// `ONB-07`. `null` reverts to the suggested value
  /// (`targetSource == suggested` once `CompleteOnboarding` runs) — see
  /// `OnboardingDraft.manualTargetMl`'s own doc comment. Set only by
  /// `target_notifier.dart`'s confirmed-edit transition, never by
  /// Accept.
  void setManualTargetMl(int? value) {
    state = state.copyWith(manualTargetMl: value);
  }

  /// `ONB-08`.
  void setReminders(ReminderPreferences value) {
    state = state.copyWith(reminders: value);
  }

  /// Called once `reminders_notifier.dart`'s `submit()` commits
  /// successfully, so a future onboarding run (e.g. after a data reset)
  /// starts from a clean draft rather than the previous session's
  /// answers.
  void reset() {
    state = const OnboardingDraft();
  }
}
