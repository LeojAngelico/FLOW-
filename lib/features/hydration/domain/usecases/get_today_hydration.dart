import '../models/today_hydration.dart';
import '../repositories/hydration_repository.dart';

/// Builds the live `TodayHydration` read model for [localDate].
///
/// Not a pass-through: this is where the day aggregate, the entry list
/// and the profile-target fallback are composed into the one stream the
/// dashboard watches. `daily_hydration` only exists once a day has its
/// first entry (`BR-17`), so the day-row stream is the sole reactivity
/// driver — every entry write also writes `daily_hydration` in the same
/// transaction (see `data/datasources/hydration_local_datasource.dart`),
/// so a change there is a reliable signal to re-read the entry list. See
/// the workplan's Decisions log #17 for why this composition lives here
/// rather than in `HydrationRepositoryImpl`.
class GetTodayHydration {
  GetTodayHydration(this._repository);

  final HydrationRepository _repository;

  Stream<TodayHydration> call(String localDate) {
    return _repository.watchDailyHydration(localDate).asyncMap((day) async {
      final entries = await _repository.watchEntries(localDate).first;

      if (day != null) {
        return TodayHydration(
          effectiveTargetMl: day.targetMl,
          totalMl: day.totalMl,
          entryCount: day.entryCount,
          goalCompleted: day.goalCompleted,
          entries: entries,
        );
      }

      // No entries logged yet today — there is no `daily_hydration` row
      // to read a target from, so the effective target falls back to
      // the profile's current one (`BR-17`). This is also the known gap
      // in the workplan's Decisions log #16: a profile-target change on
      // a zero-entry day isn't observed live, because there is no row
      // to drive a re-emit until the first entry lands.
      final targetMl = await _repository.readActiveTargetMl();

      return TodayHydration(
        effectiveTargetMl: targetMl,
        totalMl: 0,
        entryCount: 0,
        goalCompleted: false,
        entries: entries,
      );
    });
  }
}
