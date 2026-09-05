/// The success value of `LogWater` — what just happened, for the
/// notifier to turn into transient feedback.
///
/// `goalJustCompleted` is what the future `OVL-01` goal-celebration
/// overlay will read to decide whether to fire. It is computed here,
/// inside the same write transaction that already knows the day's prior
/// total (see `data/datasources/hydration_local_datasource.dart`), so it
/// costs nothing to carry now and would be wrong to try to reconstruct
/// later from two separate reads.
class LoggedWater {
  const LoggedWater({
    required this.amountMl,
    required this.newTotalMl,
    required this.goalJustCompleted,
  });

  /// The amount just logged, echoed back so the notifier doesn't need to
  /// remember what it sent.
  final int amountMl;

  /// The day's total *after* this entry.
  final int newTotalMl;

  /// `true` only on the single write that crossed the target — not on
  /// every write once the goal is already complete.
  final bool goalJustCompleted;

  LoggedWater copyWith({
    int? amountMl,
    int? newTotalMl,
    bool? goalJustCompleted,
  }) {
    return LoggedWater(
      amountMl: amountMl ?? this.amountMl,
      newTotalMl: newTotalMl ?? this.newTotalMl,
      goalJustCompleted: goalJustCompleted ?? this.goalJustCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoggedWater &&
        other.amountMl == amountMl &&
        other.newTotalMl == newTotalMl &&
        other.goalJustCompleted == goalJustCompleted;
  }

  @override
  int get hashCode => Object.hash(amountMl, newTotalMl, goalJustCompleted);

  @override
  String toString() =>
      'LoggedWater(amountMl: $amountMl, newTotalMl: $newTotalMl, '
      'goalJustCompleted: $goalJustCompleted)';
}
