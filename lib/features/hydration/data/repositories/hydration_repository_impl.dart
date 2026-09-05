import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/models/daily_hydration.dart';
import '../../domain/models/hydration_entry.dart';
import '../../domain/models/logged_water.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_local_datasource.dart';
import '../models/daily_hydration_mapper.dart';
import '../models/hydration_entry_mapper.dart';

/// Implements `HydrationRepository` (`domain/repositories/`) against
/// [HydrationLocalDataSource]. Two responsibilities live here rather
/// than in the data source: deciding *when* a `targetMl` snapshot is
/// needed — only a day's first entry reads the profile target, every
/// later entry keeps the day row's own value (`BR-17`) — and turning
/// Drift/SQLite exceptions (and the "no profile row" invariant
/// violation, see the workplan's Dependency note) into this project's
/// [Failure] vocabulary.
///
/// The read surface is three granular methods rather than one composed
/// `watchToday(localDate)`. That composition now lives in
/// `GetTodayHydration` (`domain/usecases/`) instead of here — revised
/// from this file's original shape by the domain-layer implementer; see
/// the workplan's Decisions log #17 for why.
class HydrationRepositoryImpl implements HydrationRepository {
  HydrationRepositoryImpl(this._dataSource);

  final HydrationLocalDataSource _dataSource;

  @override
  Stream<DailyHydration?> watchDailyHydration(String localDate) {
    return _dataSource
        .watchDay(localDate)
        .map((row) => row?.toDomain())
        .handleError((Object error, StackTrace stackTrace) {
          throw _mapException(error);
        });
  }

  @override
  Stream<List<HydrationEntry>> watchEntries(String localDate) {
    return _dataSource
        .watchEntriesForDate(localDate)
        .map((rows) => rows.map((row) => row.toDomain()).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw _mapException(error);
        });
  }

  @override
  Future<int> readActiveTargetMl() async {
    try {
      final targetMl = await _dataSource.readActiveTargetMl();
      if (targetMl == null) {
        throw const StorageFailure(
          'No profile found. Complete onboarding before logging water.',
        );
      }
      return targetMl;
    } catch (error) {
      throw _mapException(error);
    }
  }

  @override
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  }) async {
    try {
      final targetMl = await readActiveTargetMl();

      final result = await _dataSource.insertEntryAndRebuildDay(
        id: id,
        amountMl: amountMl,
        occurredAt: occurredAt.toUtc().millisecondsSinceEpoch,
        localDate: localDate,
        source: hydrationSourceToDb(source),
        targetMlIfFirstEntry: targetMl,
      );

      return Result.ok(
        LoggedWater(
          amountMl: amountMl,
          newTotalMl: result.day.totalMl,
          goalJustCompleted: result.goalJustCompleted,
        ),
      );
    } catch (error) {
      return Result.err(_mapException(error));
    }
  }

  /// Drift/SQLite exceptions (constraint violations, disk errors, the
  /// deferred FK check failing at commit) become a [StorageFailure]. A
  /// [Failure] thrown from within this repository (e.g. the missing
  /// profile row in [readActiveTargetMl]) passes through unchanged, so
  /// wrapping twice (once where it's thrown, once by a caller's `catch`)
  /// is harmless.
  Failure _mapException(Object error) {
    if (error is Failure) return error;
    return StorageFailure('Could not read or write hydration data: $error');
  }
}
