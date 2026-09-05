import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart' as db;
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/hydration/data/datasources/hydration_local_datasource.dart';
import 'package:flow/features/hydration/data/repositories/hydration_repository_impl.dart';
import 'package:flow/features/hydration/domain/models/daily_hydration.dart';
import 'package:flow/features/hydration/domain/models/hydration_entry.dart';
import 'package:flow/features/hydration/domain/models/logged_water.dart';

/// Exercises `HydrationRepositoryImpl` against a real in-memory
/// `AppDatabase` (mirrors `test/core/database/schema_constraints_test.dart`),
/// not a fake data source -- the behaviour under test (the deferred FK
/// transaction, the `BR-17` targetMl snapshot, the goalCompleted
/// transition) all live in the SQL `insertEntryAndRebuildDay` performs,
/// which a fake data source would have to reimplement rather than prove.
void main() {
  late db.AppDatabase database;
  late HydrationRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = HydrationRepositoryImpl(HydrationLocalDataSource(database));
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedProfile({int dailyTargetMl = 2000}) {
    return database
        .into(database.userProfiles)
        .insert(
          db.UserProfilesCompanion.insert(
            id: const Value(1),
            age: 30,
            sex: 'male',
            weightKg: 70.0,
            activityLevel: 'moderate',
            environment: 'temperate',
            dailyTargetMl: dailyTargetMl,
            targetSource: 'suggested',
            calculatorMethodId: 'reference_intake_v1',
            profileCreatedAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  group('readActiveTargetMl', () {
    test("returns the profile row's current target", () async {
      await seedProfile(dailyTargetMl: 2200);

      expect(await repository.readActiveTargetMl(), 2200);
    });

    test('throws a StorageFailure when no profile row exists (invariant '
        'violation, not a normal empty state)', () async {
      await expectLater(
        repository.readActiveTargetMl(),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('logWater', () {
    test("the day's first entry creates the daily_hydration row and "
        'snapshots targetMl from the profile', () async {
      await seedProfile(dailyTargetMl: 2000);

      final result = await repository.logWater(
        id: 'e1',
        amountMl: 500,
        occurredAt: DateTime.utc(2026, 1, 1, 8),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );

      expect(result, isA<Ok<LoggedWater>>());
      expect((result as Ok<LoggedWater>).value.newTotalMl, 500);

      final day = await repository.watchDailyHydration('2026-01-01').first;
      expect(day, isNotNull);
      expect(day!.targetMl, 2000);
      expect(day.totalMl, 500);
      expect(day.entryCount, 1);
    });

    test("a later profile-target change does not rewrite an existing "
        "day's targetMl snapshot (BR-17)", () async {
      await seedProfile(dailyTargetMl: 2000);
      await repository.logWater(
        id: 'e1',
        amountMl: 500,
        occurredAt: DateTime.utc(2026, 1, 1, 8),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );

      await (database.update(database.userProfiles)
            ..where((t) => t.id.equals(1)))
          .write(const db.UserProfilesCompanion(dailyTargetMl: Value(3000)));

      await repository.logWater(
        id: 'e2',
        amountMl: 200,
        occurredAt: DateTime.utc(2026, 1, 1, 9),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );

      final day = await repository.watchDailyHydration('2026-01-01').first;
      expect(day!.targetMl, 2000);
      expect(day.totalMl, 700);
      expect(day.entryCount, 2);
    });

    test('goalCompleted/goalCompletedAt/status transition exactly once, '
        'on the write that crosses the target', () async {
      await seedProfile(dailyTargetMl: 1000);

      final first = await repository.logWater(
        id: 'e1',
        amountMl: 600,
        occurredAt: DateTime.utc(2026, 1, 1, 8),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );
      expect((first as Ok<LoggedWater>).value.goalJustCompleted, isFalse);

      var day = await repository.watchDailyHydration('2026-01-01').first;
      expect(day!.goalCompleted, isFalse);
      expect(day.status, DayStatus.inProgress);
      expect(day.goalCompletedAt, isNull);

      final crossing = await repository.logWater(
        id: 'e2',
        amountMl: 500,
        occurredAt: DateTime.utc(2026, 1, 1, 9),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );
      expect((crossing as Ok<LoggedWater>).value.goalJustCompleted, isTrue);
      expect(crossing.value.newTotalMl, 1100);

      day = await repository.watchDailyHydration('2026-01-01').first;
      expect(day!.goalCompleted, isTrue);
      expect(day.status, DayStatus.complete);
      expect(day.goalCompletedAt, isNotNull);
      final firstCompletedAt = day.goalCompletedAt;

      // A further write past target must not re-flag goalJustCompleted
      // or move goalCompletedAt.
      final after = await repository.logWater(
        id: 'e3',
        amountMl: 100,
        occurredAt: DateTime.utc(2026, 1, 1, 10),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );
      expect((after as Ok<LoggedWater>).value.goalJustCompleted, isFalse);

      day = await repository.watchDailyHydration('2026-01-01').first;
      expect(day!.goalCompletedAt, firstCompletedAt);
    });

    test('the deferred FK commits: a brand-new day gets both its '
        'daily_hydration row and its entry row in the same write', () async {
      await seedProfile();

      final result = await repository.logWater(
        id: 'e1',
        amountMl: 300,
        occurredAt: DateTime.utc(2026, 2, 2, 7),
        localDate: '2026-02-02',
        source: HydrationSource.custom,
      );

      expect(result, isA<Ok<LoggedWater>>());
      final entries = await repository.watchEntries('2026-02-02').first;
      expect(entries, hasLength(1));
      expect(entries.single.amountMl, 300);
      expect(entries.single.source, HydrationSource.custom);
      final day = await repository.watchDailyHydration('2026-02-02').first;
      expect(day, isNotNull);
    });

    test('a schema CHECK-constraint violation (amountMl outside 50-2000, '
        'bypassing LogWater) maps to a StorageFailure instead of a raw '
        'SqliteException', () async {
      await seedProfile();

      final result = await repository.logWater(
        id: 'e1',
        amountMl: 1,
        occurredAt: DateTime.utc(2026, 1, 1),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );

      expect(result, isA<Err<LoggedWater>>());
      expect((result as Err<LoggedWater>).failure, isA<StorageFailure>());
    });
  });

  group('watchDailyHydration / watchEntries', () {
    test(
      'watchDailyHydration emits null for a date with no entries yet',
      () async {
        final day = await repository.watchDailyHydration('2099-01-01').first;

        expect(day, isNull);
      },
    );

    test(
      'watchEntries emits an empty list for a date with no entries yet',
      () async {
        final entries = await repository.watchEntries('2099-01-01').first;

        expect(entries, isEmpty);
      },
    );

    test('watchEntries returns newest first (FR-036)', () async {
      await seedProfile();
      await repository.logWater(
        id: 'older',
        amountMl: 250,
        occurredAt: DateTime.utc(2026, 1, 1, 8),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );
      await repository.logWater(
        id: 'newer',
        amountMl: 350,
        occurredAt: DateTime.utc(2026, 1, 1, 9),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
      );

      final entries = await repository.watchEntries('2026-01-01').first;

      expect(entries.map((e) => e.id).toList(), ['newer', 'older']);
    });
  });
}
