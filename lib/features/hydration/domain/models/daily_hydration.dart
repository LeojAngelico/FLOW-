/// The daily aggregate — the domain shape of a `daily_hydration` row.
///
/// Only exists once a day has its first entry (`BR-17`); before that,
/// there is no row to read, which is why `TodayHydration` (the read
/// model the dashboard actually watches) falls back to the profile's
/// target rather than assuming a `DailyHydration` always exists for
/// today. See `data/models/daily_hydration_mapper.dart` for the db <->
/// domain conversion.
class DailyHydration {
  const DailyHydration({
    required this.localDate,
    required this.totalMl,
    required this.targetMl,
    required this.goalCompleted,
    required this.goalCompletedAt,
    required this.entryCount,
    required this.status,
  });

  /// `'YYYY-MM-DD'`, primary key.
  final String localDate;

  final int totalMl;

  /// Snapshotted from `user_profiles.daily_target_ml` on this day's
  /// first entry and never rewritten afterwards (`BR-17`) — changing the
  /// profile target later does not change a past day's target.
  final int targetMl;

  final bool goalCompleted;

  /// The instant `totalMl` first reached `targetMl`. `null` until then;
  /// never cleared once set, even if a future edit/undo pass reduces
  /// `totalMl` back below target (out of scope this pass).
  final DateTime? goalCompletedAt;

  final int entryCount;

  final DayStatus status;

  DailyHydration copyWith({
    String? localDate,
    int? totalMl,
    int? targetMl,
    bool? goalCompleted,
    DateTime? goalCompletedAt,
    int? entryCount,
    DayStatus? status,
  }) {
    return DailyHydration(
      localDate: localDate ?? this.localDate,
      totalMl: totalMl ?? this.totalMl,
      targetMl: targetMl ?? this.targetMl,
      goalCompleted: goalCompleted ?? this.goalCompleted,
      goalCompletedAt: goalCompletedAt ?? this.goalCompletedAt,
      entryCount: entryCount ?? this.entryCount,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DailyHydration &&
        other.localDate == localDate &&
        other.totalMl == totalMl &&
        other.targetMl == targetMl &&
        other.goalCompleted == goalCompleted &&
        other.goalCompletedAt == goalCompletedAt &&
        other.entryCount == entryCount &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    localDate,
    totalMl,
    targetMl,
    goalCompleted,
    goalCompletedAt,
    entryCount,
    status,
  );

  @override
  String toString() =>
      'DailyHydration(localDate: $localDate, totalMl: $totalMl, '
      'targetMl: $targetMl, status: $status)';
}

/// `daily_hydration.status`. The column defaults to `'noData'`
/// (`08-data-model.md §4` disagrees and defaults it to `'inProgress'`,
/// but every write in this feature sets `status` explicitly, so the
/// default is never actually read back — see the workplan's Decisions
/// log #9).
enum DayStatus { noData, inProgress, complete }
