import '../../../../core/result/result.dart';
import '../models/daily_hydration.dart';
import '../models/hydration_entry.dart';
import '../models/logged_water.dart';

/// Hydration's single write path and its granular read primitives.
///
/// Reads are plain `Stream`/`Future` whose *errors* are this project's
/// `Failure` instances (the implementation maps `SqliteException`/Drift
/// exceptions before they reach a caller) — see the workplan's
/// Decisions log #1 for why reads don't wrap in [Result]: `Stream<Result<T>>`
/// fights Riverpod's `AsyncValue`, which already models
/// loading/data/error.
///
/// The read surface is intentionally three granular methods rather than
/// one composed `watchToday(localDate) -> Stream<TodayHydration>` — that
/// composition (day row + entry list + profile-target fallback) is
/// `GetTodayHydration`'s job, so it is unit-testable against a fake
/// repository instead of only against a real database. See the
/// workplan's Decisions log #17 for the reasoning and what this revises.
abstract class HydrationRepository {
  /// Emits `null` while [localDate] has no `daily_hydration` row yet —
  /// a day's first entry is what creates it (`BR-17`), so "no row" is a
  /// normal state, not an error.
  Stream<DailyHydration?> watchDailyHydration(String localDate);

  /// Every entry logged for [localDate], newest first (`FR-036`),
  /// unbounded. Capping the visible list to 5 rows is a presentation
  /// concern.
  Stream<List<HydrationEntry>> watchEntries(String localDate);

  /// The profile's *current* daily target. A missing profile row is an
  /// invariant violation, not a normal empty state (the router keeps
  /// `/home` unreachable until onboarding writes one) — implementations
  /// throw a `StorageFailure` rather than returning a fallback.
  Future<int> readActiveTargetMl();

  /// Writes one entry and rebuilds that day's `DailyHydration` aggregate
  /// in a single transaction (`BR-17`) — the required shape given the
  /// `initiallyDeferred` foreign key from `hydration_entries.local_date`
  /// to `daily_hydration.local_date` (see the workplan's § API
  /// contract). This is also the seam the future gamification pass
  /// hooks into: the `log` XP event must eventually write inside this
  /// same transaction, so this stays the single transactional entry
  /// point rather than splitting into an insert call and a rebuild call.
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  });
}
