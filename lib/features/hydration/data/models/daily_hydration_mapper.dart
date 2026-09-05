import '../../../../core/database/app_database.dart' as db;
import '../../domain/models/daily_hydration.dart';

/// The only place `daily_hydration.status` is parsed.
extension DailyHydrationMapper on db.DailyHydrationData {
  DailyHydration toDomain() {
    return DailyHydration(
      localDate: localDate,
      totalMl: totalMl,
      targetMl: targetMl,
      goalCompleted: goalCompleted,
      goalCompletedAt: goalCompletedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              goalCompletedAt!,
              isUtc: true,
            ),
      entryCount: entryCount,
      status: _parseStatus(status),
    );
  }
}

/// Explicit unknown-value branch, mirroring
/// `hydration_entry_mapper.dart`'s `_parseSource`: an unrecognised
/// `status` string is malformed data and should surface as a failure,
/// not silently become a default `DayStatus`.
///
/// Note (`Decisions log` #9 in the workplan): the schema's own column
/// default is `'noData'`, but every write in this feature sets
/// `status` explicitly to `'inProgress'` or `'complete'`, so that
/// default is never actually read back through this parser.
DayStatus _parseStatus(String raw) {
  return switch (raw) {
    'noData' => DayStatus.noData,
    'inProgress' => DayStatus.inProgress,
    'complete' => DayStatus.complete,
    _ => throw FormatException('Unknown daily_hydration.status: $raw'),
  };
}
