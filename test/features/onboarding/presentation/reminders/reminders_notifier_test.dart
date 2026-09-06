import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/core/preferences/shared_preferences_provider.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/hydration/domain/models/user_profile.dart';
import 'package:flow/features/onboarding/data/providers/onboarding_data_providers.dart';
import 'package:flow/features/onboarding/domain/models/reminder_preferences.dart';
import 'package:flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flow/features/onboarding/presentation/onboarding_draft_notifier.dart';
import 'package:flow/features/onboarding/presentation/reminders/reminders_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for `OnboardingRepositoryImpl`'s write path. [failWith] is a
/// deliberate failure switch so the write-failure path (a storage error
/// on the final CTA) is reachable without a real database. On success it
/// also flips the `onboardingComplete` flag on the given
/// [SharedPreferences] instance, mirroring the real repository's
/// observable contract (`FR-019`) -- a test asserting that the notifier's
/// `ref.invalidate(onboardingCompleteProvider)` call actually surfaces a
/// changed value needs a fake that changes the value the same way the
/// real one would.
class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  Failure? failWith;
  int callCount = 0;
  ReminderPreferences? lastReminders;

  @override
  Future<Result<void>> completeOnboarding({
    required UserProfile profile,
    required ReminderPreferences reminders,
  }) async {
    callCount++;
    lastReminders = reminders;
    final failure = failWith;
    if (failure != null) return Result.err(failure);
    await _prefs.setBool('onboardingComplete', true);
    return const Result.ok(null);
  }
}

void main() {
  late _FakeOnboardingRepository repository;
  late ProviderContainer container;

  void seedReadyDraft() {
    final draftNotifier = container.read(onboardingDraftProvider.notifier);
    draftNotifier.setAge(24);
    draftNotifier.setSex(Sex.female);
    draftNotifier.setWeightKg(68);
    draftNotifier.setActivityLevel(ActivityLevel.light);
    draftNotifier.setEnvironment(Environment.warm);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = _FakeOnboardingRepository(prefs);
    container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(FixedClock(DateTime.utc(2026, 5, 1))),
      ],
    );
    addTearDown(container.dispose);
    container.listen(remindersProvider, (previous, next) {});
  });

  test(
    'Skip (enabled: false) still completes onboarding successfully',
    () async {
      seedReadyDraft();
      final notifier = container.read(remindersProvider.notifier);

      final result = await notifier.submit(enabled: false);

      expect(result, isTrue);
      expect(repository.callCount, 1);
      expect(repository.lastReminders!.enabled, isFalse);
    },
  );

  test(
    'the CTA (enabled: true) completes onboarding with reminders on',
    () async {
      seedReadyDraft();
      final notifier = container.read(remindersProvider.notifier);

      final result = await notifier.submit(enabled: true);

      expect(result, isTrue);
      expect(repository.lastReminders!.enabled, isTrue);
    },
  );

  test('submit invalidates onboardingCompleteProvider on success -- '
      'without this the router\'s redirect gate would keep bouncing to '
      '/onboarding/welcome (Decisions #5)', () async {
    seedReadyDraft();
    // onboardingCompleteProvider is autoDispose -- hold a listener so its
    // cached value survives the awaited submit() below, the same way the
    // router's redirect gate keeps it alive by watching continuously.
    container.listen(onboardingCompleteProvider, (previous, next) {});
    expect(container.read(onboardingCompleteProvider), isFalse);

    await container.read(remindersProvider.notifier).submit(enabled: true);

    expect(container.read(onboardingCompleteProvider), isTrue);
  });

  test('submit resets the shared draft once the write commits', () async {
    seedReadyDraft();

    await container.read(remindersProvider.notifier).submit(enabled: true);

    expect(container.read(onboardingDraftProvider).age, isNull);
  });

  test(
    'a double-tapped CTA (two concurrent submits) produces exactly '
    'one completeOnboarding call -- the isSubmitting re-entry guard',
    () async {
      seedReadyDraft();
      final notifier = container.read(remindersProvider.notifier);

      final first = notifier.submit(enabled: true);
      final second = notifier.submit(enabled: true);
      final results = await Future.wait([first, second]);

      expect(repository.callCount, 1);
      expect(results, [true, false]);
    },
  );

  test('a StorageFailure leaves isSubmitting false, the draft intact, and '
      'submit() returning false', () async {
    seedReadyDraft();
    repository.failWith = const StorageFailure('disk full');
    final notifier = container.read(remindersProvider.notifier);

    final result = await notifier.submit(enabled: true);

    expect(result, isFalse);
    final state = container.read(remindersProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.submitFailure, isA<StorageFailure>());
    // The draft is untouched -- the user can retry without redoing the
    // flow.
    expect(container.read(onboardingDraftProvider).age, 24);
    expect(container.read(onboardingCompleteProvider), isFalse);
  });

  test('a failed submit followed by a retry (once the failure is '
      'resolved) is not swallowed by the re-entry guard', () async {
    seedReadyDraft();
    repository.failWith = const StorageFailure('disk full');
    final notifier = container.read(remindersProvider.notifier);
    expect(await notifier.submit(enabled: true), isFalse);

    repository.failWith = null;
    expect(await notifier.submit(enabled: true), isTrue);

    expect(repository.callCount, 2);
  });

  group('the window/interval/weekday mutators write straight through to '
      'the shared draft\'s ReminderPreferences', () {
    test('setStartMinuteOfDay / setEndMinuteOfDay update the draft and '
        'revalidate the window', () {
      final notifier = container.read(remindersProvider.notifier);

      notifier.setStartMinuteOfDay(600);
      notifier.setEndMinuteOfDay(600);

      expect(
        container.read(onboardingDraftProvider).reminders.startMinuteOfDay,
        600,
      );
      expect(container.read(remindersProvider).windowError, isNotNull);
    });

    test('a subsequent valid window clears the error', () {
      final notifier = container.read(remindersProvider.notifier);

      notifier.setStartMinuteOfDay(600);
      notifier.setEndMinuteOfDay(600);
      expect(container.read(remindersProvider).windowError, isNotNull);

      notifier.setEndMinuteOfDay(900);

      expect(container.read(remindersProvider).windowError, isNull);
    });

    test('an invalid window (end <= start) blocks submit()', () async {
      seedReadyDraft();
      final notifier = container.read(remindersProvider.notifier);
      notifier.setStartMinuteOfDay(600);
      notifier.setEndMinuteOfDay(600);

      final result = await notifier.submit(enabled: true);

      expect(result, isFalse);
      expect(repository.callCount, 0);
    });

    test('toggleWeekday removes an already-active day (FR-015\'s default '
        'has all seven active) and adds it back on a second toggle', () {
      final notifier = container.read(remindersProvider.notifier);
      expect(
        container.read(onboardingDraftProvider).reminders.activeWeekdays,
        contains(3),
      );

      notifier.toggleWeekday(3);
      expect(
        container.read(onboardingDraftProvider).reminders.activeWeekdays,
        isNot(contains(3)),
      );

      notifier.toggleWeekday(3);
      expect(
        container.read(onboardingDraftProvider).reminders.activeWeekdays,
        contains(3),
      );
    });

    test('setIntervalMinutes writes through without touching the window', () {
      final notifier = container.read(remindersProvider.notifier);

      notifier.setIntervalMinutes(60);

      expect(
        container.read(onboardingDraftProvider).reminders.intervalMinutes,
        60,
      );
    });
  });
}
