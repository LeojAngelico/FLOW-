import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('opening a fresh database creates all 8 tables', () async {
    final tableNames = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tableNames.map((row) => row.data['name'] as String).toSet();

    expect(
      names,
      containsAll([
        'user_profiles',
        'hydration_entries',
        'daily_hydration',
        'xp_events',
        'achievements',
        'trivia_progress',
        'reminder_settings',
        'progress_meta',
      ]),
    );
  });

  test('a fresh database seeds the achievement catalogue', () async {
    final rows = await db.select(db.achievements).get();

    expect(rows.map((r) => r.key), containsAll(['streak_7', 'level_99']));
  });

  test('a fresh database seeds reminder defaults', () async {
    final row = await (db.select(
      db.reminderSettings,
    )..where((t) => t.id.equals(1))).getSingle();

    expect(row.enabled, isTrue);
    expect(row.startMinuteOfDay, 480);
    expect(row.endMinuteOfDay, 1320);
    expect(row.intervalMinutes, 120);
  });

  test('a fresh database seeds progress_meta with bestStreak 0', () async {
    final row = await (db.select(
      db.progressMeta,
    )..where((t) => t.id.equals(1))).getSingle();

    expect(row.bestStreak, 0);
  });

  test('inserting a user profile round-trips correctly', () async {
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: const Value(1),
            age: 30,
            sex: 'male',
            weightKg: 70.5,
            activityLevel: 'moderate',
            environment: 'temperate',
            dailyTargetMl: 2000,
            targetSource: 'suggested',
            calculatorMethodId: 'reference_intake_v1',
            profileCreatedAt: 1000,
            updatedAt: 1000,
          ),
        );

    final row = await (db.select(
      db.userProfiles,
    )..where((t) => t.id.equals(1))).getSingle();

    expect(row.weightKg, 70.5);
    expect(row.dailyTargetMl, 2000);
  });
}
