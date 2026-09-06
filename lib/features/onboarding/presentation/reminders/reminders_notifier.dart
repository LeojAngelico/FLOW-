import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/preferences/onboarding_provider.dart';
import '../../../../core/result/result.dart';
import '../../domain/models/onboarding_rules.dart';
import '../../domain/providers/onboarding_usecase_providers.dart';
import '../onboarding_draft_notifier.dart';
import 'reminders_state.dart';

part 'reminders_notifier.g.dart';

/// `ONB-08`'s allowed reminder intervals (`FR-062`; § Open product
/// questions — no allowed set is pinned by any `05`/`09` spec, so this
/// implementer chose the documented default set). Rendered from this one
/// const list so the set is a one-line change, matching
/// `weight_notifier.dart`'s `weightPrefillKg` precedent for an
/// undocumented-but-necessary constant.
const remindersIntervalOptionsMinutes = [30, 60, 90, 120, 180, 240];

/// `ONB-08`'s screen-owned state: the window/interval/weekday mutators
/// (all write straight through to the shared draft's
/// `ReminderPreferences`), the `end > start` validation (`CPY-122`), and
/// **the final write** — both Skip and the CTA call [submit].
@riverpod
class RemindersNotifier extends _$RemindersNotifier {
  @override
  RemindersState build() => const RemindersState();

  void setStartMinuteOfDay(int minute) {
    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    final current = ref.read(onboardingDraftProvider).reminders;
    draftNotifier.setReminders(current.copyWith(startMinuteOfDay: minute));
    _revalidateWindow();
  }

  void setEndMinuteOfDay(int minute) {
    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    final current = ref.read(onboardingDraftProvider).reminders;
    draftNotifier.setReminders(current.copyWith(endMinuteOfDay: minute));
    _revalidateWindow();
  }

  void setIntervalMinutes(int minutes) {
    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    final current = ref.read(onboardingDraftProvider).reminders;
    draftNotifier.setReminders(current.copyWith(intervalMinutes: minutes));
  }

  void toggleWeekday(int isoWeekday) {
    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    final current = ref.read(onboardingDraftProvider).reminders;
    final updated = Set<int>.from(current.activeWeekdays);
    if (!updated.remove(isoWeekday)) {
      updated.add(isoWeekday);
    }
    draftNotifier.setReminders(current.copyWith(activeWeekdays: updated));
  }

  void _revalidateWindow() {
    final reminders = ref.read(onboardingDraftProvider).reminders;
    state = state.copyWith(
      windowError: OnboardingRules.validateReminderWindow(
        startMinuteOfDay: reminders.startMinuteOfDay,
        endMinuteOfDay: reminders.endMinuteOfDay,
      ),
    );
  }

  /// **The final write of the whole flow.** Reads the current draft's
  /// `reminders` and flips only `enabled` — never constructs a fresh
  /// `ReminderPreferences` (the domain layer's Decisions #18 flag for
  /// this file) — then calls `CompleteOnboarding` with the full draft.
  ///
  /// Guards re-entry: a second call while [RemindersState.isSubmitting]
  /// is already `true` returns `false` immediately, so a double-tapped
  /// CTA produces exactly one `completeOnboarding` call. Returns `true`
  /// only once the write actually commits; the page navigates on `true`
  /// itself (`flutter-architecture-map` SKILL § Placement decisions).
  Future<bool> submit({required bool enabled}) async {
    if (state.isSubmitting) return false;
    if (state.windowError != null) return false;

    final draftNotifier = ref.read(onboardingDraftProvider.notifier);
    final draft = ref.read(onboardingDraftProvider);
    draftNotifier.setReminders(draft.reminders.copyWith(enabled: enabled));

    state = state.copyWith(isSubmitting: true, submitFailure: null);

    final updatedDraft = ref.read(onboardingDraftProvider);
    final result = await ref
        .read(completeOnboardingProvider)
        .call(updatedDraft);

    switch (result) {
      case Ok():
        state = state.copyWith(isSubmitting: false);
        // The router's redirect gate reads a cached `bool` — without
        // this invalidation it keeps returning `false` and bounces
        // `context.go('/home')` straight back to `/onboarding/welcome`
        // (Decisions #5's "single most likely 'it compiles and still
        // doesn't work' failure").
        ref.invalidate(onboardingCompleteProvider);
        draftNotifier.reset();
        return true;
      case Err(:final failure):
        state = state.copyWith(isSubmitting: false, submitFailure: failure);
        return false;
    }
  }
}
