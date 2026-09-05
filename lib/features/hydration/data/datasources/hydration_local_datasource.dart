import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

/// Every Drift statement for the hydration feature lives here — no
/// other file issues SQL against `hydration_entries`, `daily_hydration`
/// or (read-only, for the active target) `user_profiles`.
///
/// See `docs/workplans/2026-09-04-hydration-logging.md` § API contract
/// for the schema realities this class works around: the deferred
/// foreign key from `hydration_entries.local_date` to
/// `daily_hydration.local_date` (forces a single `transaction()` for a
/// day's first entry) and the Drift-generated row class names
/// (`db.HydrationEntry`, `db.DailyHydrationData`) that collide with
/// this feature's domain model names of the same name — hence the
/// `db.` import prefix used throughout `data/`.
class HydrationLocalDataSource {
  HydrationLocalDataSource(this._database);

  final db.AppDatabase _database;

  /// Emits `null` while [localDate] has no entries yet — a
  /// `daily_hydration` row is only created on that day's first log
  /// (`BR-17`), so "no row" is a normal state, not an error.
  Stream<db.DailyHydrationData?> watchDay(String localDate) {
    return (_database.select(
      _database.dailyHydration,
    )..where((row) => row.localDate.equals(localDate))).watchSingleOrNull();
  }

  /// Newest first, matching `FR-036` ("today's entries, newest first").
  /// Capping the list to 5 rows is a presentation concern, not this
  /// data source's — it returns every entry for the date.
  Stream<List<db.HydrationEntry>> watchEntriesForDate(String localDate) {
    return (_database.select(_database.hydrationEntries)
          ..where((row) => row.localDate.equals(localDate))
          ..orderBy([(row) => OrderingTerm.desc(row.occurredAt)]))
        .watch();
  }

  /// The profile's *current* target, read directly from the singleton
  /// `user_profiles` row (id `1`). This is the hydration-domain read
  /// sanctioned by `07-technical-architecture.md §3` — see the
  /// workplan's "Dependency: where does targetMl come from?" note.
  /// Returns `null` when no profile row exists yet, which the
  /// repository treats as an invariant violation (`StorageFailure`),
  /// not a normal empty state — the router is supposed to keep
  /// `/home` unreachable until onboarding writes this row.
  Future<int?> readActiveTargetMl() async {
    final row = await (_database.select(
      _database.userProfiles,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    return row?.dailyTargetMl;
  }

  /// Inserts one entry and rebuilds that date's `daily_hydration`
  /// aggregate in a single `transaction()` (`BR-17`). This is required
  /// by the `initiallyDeferred` foreign key on
  /// `hydration_entries.local_date`: on a day's first entry, the new
  /// `daily_hydration` row and the new `hydration_entries` row must
  /// commit together, or SQLite raises the constraint at commit.
  ///
  /// [targetMlIfFirstEntry] is only consulted when [localDate] has no
  /// existing `daily_hydration` row. Once a day has a row, its
  /// `target_ml` is never rewritten (`BR-17`) — later entries keep the
  /// snapshotted value regardless of what is passed here.
  ///
  /// `created_at` mirrors [occurredAt]: this pass never backdates an
  /// entry (that is what the out-of-scope `imported` source will
  /// eventually do), so there is no independent "recorded at" instant
  /// to inject here.
  Future<HydrationLogWriteResult> insertEntryAndRebuildDay({
    required String id,
    required int amountMl,
    required int occurredAt,
    required String localDate,
    required String source,
    required int targetMlIfFirstEntry,
  }) {
    return _database.transaction(() async {
      final existing = await (_database.select(
        _database.dailyHydration,
      )..where((row) => row.localDate.equals(localDate))).getSingleOrNull();

      final targetMl = existing?.targetMl ?? targetMlIfFirstEntry;
      final newTotalMl = (existing?.totalMl ?? 0) + amountMl;
      final newEntryCount = (existing?.entryCount ?? 0) + 1;
      final wasGoalCompleted = existing?.goalCompleted ?? false;
      final isGoalCompleteNow = newTotalMl >= targetMl;
      final goalJustCompleted = !wasGoalCompleted && isGoalCompleteNow;
      final goalCompletedAt = wasGoalCompleted
          ? existing!.goalCompletedAt
          : (goalJustCompleted ? occurredAt : null);
      final status = isGoalCompleteNow ? 'complete' : 'inProgress';

      await _database
          .into(_database.dailyHydration)
          .insertOnConflictUpdate(
            db.DailyHydrationCompanion.insert(
              localDate: localDate,
              targetMl: targetMl,
              totalMl: Value(newTotalMl),
              entryCount: Value(newEntryCount),
              goalCompleted: Value(isGoalCompleteNow),
              goalCompletedAt: Value(goalCompletedAt),
              status: Value(status),
            ),
          );

      await _database
          .into(_database.hydrationEntries)
          .insert(
            db.HydrationEntriesCompanion.insert(
              id: id,
              amountMl: amountMl,
              occurredAt: occurredAt,
              localDate: localDate,
              source: source,
              createdAt: occurredAt,
            ),
          );

      final updatedDay = await (_database.select(
        _database.dailyHydration,
      )..where((row) => row.localDate.equals(localDate))).getSingle();

      return HydrationLogWriteResult(
        day: updatedDay,
        goalJustCompleted: goalJustCompleted,
      );
    });
  }
}

/// Bundles the rebuilt `daily_hydration` row with whether *this* write
/// is the one that crossed the target. Computing `goalJustCompleted`
/// here is cheaper and race-free compared to reconstructing it later
/// from two separate reads, because this method already reads the
/// day's prior state inside the same transaction that writes its new
/// state.
class HydrationLogWriteResult {
  const HydrationLogWriteResult({
    required this.day,
    required this.goalJustCompleted,
  });

  final db.DailyHydrationData day;
  final bool goalJustCompleted;
}
