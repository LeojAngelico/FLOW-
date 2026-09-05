import 'hydration_entry.dart';

/// The composite read model the dashboard actually needs — one shape
/// combining today's `DailyHydration` aggregate (when it exists), the
/// day's entries, and the profile-target fallback for a zero-entry day.
///
/// It exists because a day with zero entries has no `daily_hydration`
/// row to read a target from (`BR-17`); the effective target then comes
/// from `user_profiles.daily_target_ml` instead. `GetTodayHydration`
/// composes both sources so the presentation layer never has to know
/// which one the target came from.
class TodayHydration {
  const TodayHydration({
    required this.effectiveTargetMl,
    required this.totalMl,
    required this.entryCount,
    required this.goalCompleted,
    required this.entries,
  });

  /// The day's `targetMl` snapshot once a `daily_hydration` row exists;
  /// otherwise the profile's current target.
  final int effectiveTargetMl;

  final int totalMl;

  final int entryCount;

  final bool goalCompleted;

  /// Newest first (`FR-036`), unbounded — the presentation layer caps
  /// the visible list at 5 rows; this model carries every entry logged
  /// today.
  final List<HydrationEntry> entries;

  /// How much is left to reach the target, floored at 0 — going over
  /// target must never render as a negative "remaining" figure.
  int get remainingMl {
    final remaining = effectiveTargetMl - totalMl;
    return remaining < 0 ? 0 : remaining;
  }

  /// `totalMl / effectiveTargetMl`, uncapped — can exceed `1.0` once the
  /// goal is passed. Used for the *textual* readout (`FR-033` requires
  /// the text to show the true total even past 100%).
  ///
  /// Guards against a zero/negative target rather than dividing by zero;
  /// the schema's own `CHECK` constraint keeps a real `targetMl` between
  /// 500 and 4,000, so this branch only guards a corrupt read.
  double get progressFraction {
    if (effectiveTargetMl <= 0) return 0;
    return totalMl / effectiveTargetMl;
  }

  /// [progressFraction] capped at `1.0` — used for the *graphic* (the
  /// `HydrationGlass` fill), which must not overflow past a full glass
  /// (`FR-033`).
  double get displayFraction {
    final fraction = progressFraction;
    if (fraction > 1.0) return 1.0;
    if (fraction < 0.0) return 0.0;
    return fraction;
  }

  TodayHydration copyWith({
    int? effectiveTargetMl,
    int? totalMl,
    int? entryCount,
    bool? goalCompleted,
    List<HydrationEntry>? entries,
  }) {
    return TodayHydration(
      effectiveTargetMl: effectiveTargetMl ?? this.effectiveTargetMl,
      totalMl: totalMl ?? this.totalMl,
      entryCount: entryCount ?? this.entryCount,
      goalCompleted: goalCompleted ?? this.goalCompleted,
      entries: entries ?? this.entries,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! TodayHydration) return false;
    if (other.effectiveTargetMl != effectiveTargetMl) return false;
    if (other.totalMl != totalMl) return false;
    if (other.entryCount != entryCount) return false;
    if (other.goalCompleted != goalCompleted) return false;
    if (other.entries.length != entries.length) return false;
    for (var i = 0; i < entries.length; i++) {
      if (other.entries[i] != entries[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    effectiveTargetMl,
    totalMl,
    entryCount,
    goalCompleted,
    Object.hashAll(entries),
  );

  @override
  String toString() =>
      'TodayHydration(totalMl: $totalMl, effectiveTargetMl: '
      '$effectiveTargetMl, entryCount: $entryCount, goalCompleted: '
      '$goalCompleted)';
}
