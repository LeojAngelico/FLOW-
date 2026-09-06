import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow/core/database/app_database.dart' as db;
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/hydration/domain/models/user_profile.dart';
import 'package:flow/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:flow/features/onboarding/data/datasources/onboarding_preferences_datasource.dart';
import 'package:flow/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:flow/features/onboarding/domain/models/reminder_preferences.dart';

/// Exercises `OnboardingRepositoryImpl` against a real in-memory
/// `AppDatabase` (mirrors `hydration_repository_impl_test.dart`'s
/// precedent) plus a real, mock-backed `SharedPreferences` -- the
/// behaviour under test (the `FR-019` commit-then-flag ordering, the
/// singleton upsert, the enum/comma-joined/epoch-millis encoding) all
/// lives in the actual write path, which a fake data source would have
/// to reimplement rather than prove.
void main() {
  late db.AppDatabase database;
  late SharedPreferences prefs;
  late OnboardingRepositoryImpl repository;

  UserProfile buildProfile({
    int age = 24,
    Sex sex = Sex.female,
    double weightKg = 68.05,
    ActivityLevel activityLevel = ActivityLevel.light,
    Environment environment = Environment.warm,
    Set<SpecialCircumstance> specialCircumstances = const {},
    int dailyTargetMl = 2000,
    TargetSource targetSource = TargetSource.suggested,
    String calculatorMethodId = 'reference_intake_v1',
  }) {
    final now = DateTime.utc(2026, 5, 1, 12);
    return UserProfile(
      displayName: 'Alex',
      age: age,
      sex: sex,
      weightKg: weightKg,
      activityLevel: activityLevel,
      environment: environment,
      specialCircumstances: specialCircumstances,
      dailyTargetMl: dailyTargetMl,
      targetSource: targetSource,
      calculatorMethodId: calculatorMethodId,
      profileCreatedAt: now,
      updatedAt: now,
    );
  }

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = OnboardingRepositoryImpl(
      OnboardingLocalDataSource(database),
      OnboardingPreferencesDataSource(prefs),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('a full completion writes exactly one user_profiles row, with '
      'every column correctly encoded', () async {
    final result = await repository.completeOnboarding(
      profile: buildProfile(
        specialCircumstances: {
          SpecialCircumstance.other,
          SpecialCircumstance.pregnancy,
        },
      ),
      reminders: const ReminderPreferences.defaults().copyWith(
        activeWeekdays: {5, 1, 3},
      ),
    );

    expect(result, isA<Ok<void>>());

    final rows = await database.select(database.userProfiles).get();
    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.id, 1);
    expect(row.displayName, 'Alex');
    expect(row.age, 24);
    expect(row.sex, 'female');
    expect(row.weightKg, 68.1); // rounded to one decimal by the mapper
    expect(row.activityLevel, 'light');
    expect(row.environment, 'warm');
    // Stable declaration order, not tap/insertion order.
    expect(row.specialCircumstances, 'pregnancy,other');
    expect(row.dailyTargetMl, 2000);
    expect(row.targetSource, 'suggested');
    expect(row.calculatorMethodId, 'reference_intake_v1');
    expect(
      row.profileCreatedAt,
      DateTime.utc(2026, 5, 1, 12).millisecondsSinceEpoch,
    );
    expect(row.updatedAt, DateTime.utc(2026, 5, 1, 12).millisecondsSinceEpoch);
  });

  test('reminder_settings is updated, not inserted -- still exactly one '
      'row, with the weekdays comma-joined in ascending order', () async {
    await repository.completeOnboarding(
      profile: buildProfile(),
      reminders: const ReminderPreferences(
        enabled: false,
        startMinuteOfDay: 540,
        endMinuteOfDay: 1200,
        intervalMinutes: 90,
        activeWeekdays: {7, 2, 4},
      ),
    );

    final rows = await database.select(database.reminderSettings).get();
    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.id, 1);
    expect(row.enabled, isFalse);
    expect(row.startMinuteOfDay, 540);
    expect(row.endMinuteOfDay, 1200);
    expect(row.intervalMinutes, 90);
    expect(row.activeWeekdays, '2,4,7');
    // Untouched columns keep their seeded defaults -- APP-09 owns these.
    expect(row.messageStyle, 'friendly');
    expect(row.stopWhenGoalMet, isTrue);
  });

  test('onboardingComplete is set only after the transaction commits '
      '(FR-019)', () async {
    expect(prefs.getBool('onboardingComplete'), isNull);

    await repository.completeOnboarding(
      profile: buildProfile(),
      reminders: const ReminderPreferences.defaults(),
    );

    expect(prefs.getBool('onboardingComplete'), isTrue);
  });

  test('onboardingComplete is NOT set when the transaction throws -- the '
      'FR-019 ordering, asserted explicitly', () async {
    // age 200 violates the `age BETWEEN 9 AND 120` CHECK, so the Drift
    // transaction throws before the SharedPreferences write is ever
    // reached.
    final result = await repository.completeOnboarding(
      profile: buildProfile(age: 200),
      reminders: const ReminderPreferences.defaults(),
    );

    expect(result, isA<Err<void>>());
    expect(prefs.getBool('onboardingComplete'), isNull);
  });

  test('a CHECK-constraint violation surfaces as a StorageFailure, not a '
      'raw SqliteException', () async {
    final result = await repository.completeOnboarding(
      profile: buildProfile(weightKg: 300), // outside 25.0-250.0
      reminders: const ReminderPreferences.defaults(),
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<StorageFailure>());
  });

  test('running completion twice leaves exactly one user_profiles row '
      '(double-tap / crash-then-retry idempotence)', () async {
    await repository.completeOnboarding(
      profile: buildProfile(dailyTargetMl: 1800),
      reminders: const ReminderPreferences.defaults(),
    );
    await repository.completeOnboarding(
      profile: buildProfile(dailyTargetMl: 2200),
      reminders: const ReminderPreferences.defaults(),
    );

    final rows = await database.select(database.userProfiles).get();
    expect(rows, hasLength(1));
    // The second completion's values win -- insertOnConflictUpdate.
    expect(rows.single.dailyTargetMl, 2200);
  });

  test('a missing reminder_settings row (an invariant break, not a '
      'normal path) surfaces as a StorageFailure and leaves '
      'onboardingComplete unset', () async {
    // Simulate the invariant being broken: delete the seeded singleton
    // row before completing onboarding.
    await (database.delete(
      database.reminderSettings,
    )..where((t) => t.id.equals(1))).go();

    final result = await repository.completeOnboarding(
      profile: buildProfile(),
      reminders: const ReminderPreferences.defaults(),
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<StorageFailure>());
    expect(prefs.getBool('onboardingComplete'), isNull);
  });

  test('a SharedPreferences write failure after a successful transaction '
      'commit is caught and mapped to a StorageFailure, not left to '
      'escape the Future<Result<T>> contract uncaught (gate-4 finding 7: '
      'the setOnboardingComplete() call used to sit outside the try '
      'block)', () async {
    final throwingRepository = OnboardingRepositoryImpl(
      OnboardingLocalDataSource(database),
      _ThrowingPreferencesDataSource(prefs),
    );

    // If this call escapes uncaught, `await` re-throws it here and the
    // test fails with an exception rather than a clean assertion --
    // exactly the bug this test guards against.
    final result = await throwingRepository.completeOnboarding(
      profile: buildProfile(),
      reminders: const ReminderPreferences.defaults(),
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<StorageFailure>());
    // The profile write already committed and is idempotent
    // (insertOnConflictUpdate on id = 1), so a retry after this failure
    // is safe -- the FR-019 ordering is otherwise unchanged.
    final rows = await database.select(database.userProfiles).get();
    expect(rows, hasLength(1));
    expect(prefs.getBool('onboardingComplete'), isNull);
  });
}

/// Stands in for the real `SharedPreferences`-backed write, throwing
/// unconditionally, so the repository's error-handling around the pref
/// write is reachable without a way to make the real (mock-backed)
/// `SharedPreferences` plugin fail.
class _ThrowingPreferencesDataSource extends OnboardingPreferencesDataSource {
  _ThrowingPreferencesDataSource(super.prefs);

  @override
  Future<void> setOnboardingComplete() {
    throw Exception('simulated SharedPreferences write failure');
  }
}
