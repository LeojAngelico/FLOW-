import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'seed/achievement_catalogue.dart';
import 'tables/achievements.dart';
import 'tables/daily_hydration.dart';
import 'tables/hydration_entries.dart';
import 'tables/progress_meta.dart';
import 'tables/reminder_settings.dart';
import 'tables/trivia_progress.dart';
import 'tables/user_profiles.dart';
import 'tables/xp_events.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    HydrationEntries,
    DailyHydration,
    XpEvents,
    Achievements,
    TriviaProgress,
    ReminderSettings,
    ProgressMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_hydration_entries_local_date ON hydration_entries(local_date);',
      );
      await customStatement(
        'CREATE INDEX idx_hydration_entries_occurred_at ON hydration_entries(occurred_at);',
      );
      await customStatement(
        "CREATE UNIQUE INDEX idx_xp_events_one_goal_complete_per_day ON xp_events(local_date) WHERE type = 'goalComplete';",
      );
      await _seedAchievements();
      await _seedSingletonDefaults();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedAchievements() {
    return batch((batch) {
      batch.insertAll(
        achievements,
        kAchievementCatalogue
            .map((key) => AchievementsCompanion.insert(key: key))
            .toList(),
      );
    });
  }

  Future<void> _seedSingletonDefaults() async {
    await into(
      reminderSettings,
    ).insert(const ReminderSettingsCompanion(id: Value(1)));
    await into(progressMeta).insert(const ProgressMetaCompanion(id: Value(1)));
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flow.db'));
    return NativeDatabase.createInBackground(file);
  });
}
