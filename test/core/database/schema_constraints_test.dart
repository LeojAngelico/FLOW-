import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart';

/// Covers the final-review schema-hardening follow-up: CHECK constraints
/// were declared but never proven to actually reject bad data, and
/// `PRAGMA foreign_keys = ON` was set with no foreign key ever declared
/// to enforce (a no-op).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  UserProfilesCompanion validProfile({double? weightKg, int? age}) {
    return UserProfilesCompanion.insert(
      id: const Value(1),
      age: age ?? 30,
      sex: 'male',
      weightKg: weightKg ?? 70.5,
      activityLevel: 'moderate',
      environment: 'temperate',
      dailyTargetMl: 2000,
      targetSource: 'suggested',
      calculatorMethodId: 'reference_intake_v1',
      profileCreatedAt: 1000,
      updatedAt: 1000,
    );
  }

  group('CHECK constraints reject bad data', () {
    test('user_profiles.age outside 9-120 is rejected', () async {
      await expectLater(
        db.into(db.userProfiles).insert(validProfile(age: 8)),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db.into(db.userProfiles).insert(validProfile(age: 121)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('user_profiles.weight_kg outside 25.0-250.0 is rejected', () async {
      await expectLater(
        db.into(db.userProfiles).insert(validProfile(weightKg: 24.9)),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db.into(db.userProfiles).insert(validProfile(weightKg: 250.1)),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'user_profiles within the boundary (25.0/250.0, 9/120) is accepted',
      () async {
        await db.into(db.userProfiles).insert(validProfile());
        await db
            .into(db.userProfiles)
            .insertOnConflictUpdate(validProfile(age: 9, weightKg: 25.0));

        final row = await db.select(db.userProfiles).getSingle();
        expect(row.age, 9);
        expect(row.weightKg, 25.0);
      },
    );

    test('hydration_entries.amount_ml outside 50-2000 is rejected', () async {
      await db
          .into(db.dailyHydration)
          .insert(
            DailyHydrationCompanion.insert(
              localDate: '2026-01-01',
              targetMl: 2000,
            ),
          );

      await expectLater(
        db
            .into(db.hydrationEntries)
            .insert(
              HydrationEntriesCompanion.insert(
                id: 'e1',
                amountMl: 49,
                occurredAt: 1000,
                localDate: '2026-01-01',
                source: 'quickAdd',
                createdAt: 1000,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db
            .into(db.hydrationEntries)
            .insert(
              HydrationEntriesCompanion.insert(
                id: 'e2',
                amountMl: 2001,
                occurredAt: 1000,
                localDate: '2026-01-01',
                source: 'quickAdd',
                createdAt: 1000,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('daily_hydration.target_ml outside 500-4000 is rejected', () async {
      await expectLater(
        db
            .into(db.dailyHydration)
            .insert(
              DailyHydrationCompanion.insert(
                localDate: '2026-01-01',
                targetMl: 499,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db
            .into(db.dailyHydration)
            .insert(
              DailyHydrationCompanion.insert(
                localDate: '2026-01-02',
                targetMl: 4001,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('xp_events.amount negative is rejected', () async {
      await expectLater(
        db
            .into(db.xpEvents)
            .insert(
              XpEventsCompanion.insert(
                id: 'x1',
                type: 'log',
                amount: -1,
                localDate: '2026-01-01',
                occurredAt: 1000,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('hydration_entries.local_date foreign key', () {
    test(
      'inserting an entry for a local_date with no daily_hydration row is rejected',
      () async {
        await expectLater(
          db
              .into(db.hydrationEntries)
              .insert(
                HydrationEntriesCompanion.insert(
                  id: 'e1',
                  amountMl: 250,
                  occurredAt: 1000,
                  localDate: '2099-01-01',
                  source: 'quickAdd',
                  createdAt: 1000,
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test(
      'inserting an entry for a local_date with a matching daily_hydration row succeeds',
      () async {
        await db
            .into(db.dailyHydration)
            .insert(
              DailyHydrationCompanion.insert(
                localDate: '2026-01-01',
                targetMl: 2000,
              ),
            );

        await db
            .into(db.hydrationEntries)
            .insert(
              HydrationEntriesCompanion.insert(
                id: 'e1',
                amountMl: 250,
                occurredAt: 1000,
                localDate: '2026-01-01',
                source: 'quickAdd',
                createdAt: 1000,
              ),
            );

        final row = await db.select(db.hydrationEntries).getSingle();
        expect(row.localDate, '2026-01-01');
      },
    );

    test('deleting a daily_hydration row referenced by an entry is rejected '
        '(ON DELETE RESTRICT -- the aggregate is derived from entries, not '
        'the other way round)', () async {
      await db
          .into(db.dailyHydration)
          .insert(
            DailyHydrationCompanion.insert(
              localDate: '2026-01-01',
              targetMl: 2000,
            ),
          );
      await db
          .into(db.hydrationEntries)
          .insert(
            HydrationEntriesCompanion.insert(
              id: 'e1',
              amountMl: 250,
              occurredAt: 1000,
              localDate: '2026-01-01',
              source: 'quickAdd',
              createdAt: 1000,
            ),
          );

      await expectLater(
        (db.delete(
          db.dailyHydration,
        )..where((t) => t.localDate.equals('2026-01-01'))).go(),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
