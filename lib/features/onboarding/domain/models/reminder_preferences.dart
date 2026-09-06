/// `reminder_settings`'s onboarding-writable subset — the domain shape
/// `ONB-08` collects and `CompleteOnboarding` writes.
///
/// `messageStyle`/`soundId`/`stopWhenGoalMet` are deliberately absent:
/// this pass leaves the seeded defaults untouched (§ Open product
/// questions in the workplan) and `APP-09` owns them.
///
/// [activeWeekdays] is a `Set<int>` of ISO weekday numbers (`1` Monday –
/// `7` Sunday), matching `ENT-07`'s own typing rather than introducing a
/// parallel enum — see `docs/workplans/2026-09-05-onboarding.md`
/// Decisions #14, which the data layer was already built against.
///
/// `BR-30` (reminder times) lives on this model for now rather than in
/// `features/reminders/`, which has no domain layer yet — see the
/// workplan's Decisions #9. When that feature gets one, this file
/// (model and test) should *move*, not be reimplemented.
class ReminderPreferences {
  const ReminderPreferences({
    required this.enabled,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.intervalMinutes,
    required this.activeWeekdays,
  });

  /// `FR-015`'s seeded defaults — exactly what
  /// `AppDatabase._seedSingletonDefaults` already writes at `onCreate`
  /// (Decisions #11). A draft that constructs its `reminders` field from
  /// this factory and is never touched by `ONB-08` (e.g. Skip) still
  /// submits sane, already-valid values.
  const ReminderPreferences.defaults()
    : enabled = true,
      startMinuteOfDay = 480,
      endMinuteOfDay = 1320,
      intervalMinutes = 120,
      activeWeekdays = const {1, 2, 3, 4, 5, 6, 7};

  /// Master toggle. `false` after Skip (`FR-017`) — onboarding still
  /// completes either way.
  final bool enabled;

  /// Minute-of-day, `0`–`1439`. `480` = 08:00.
  final int startMinuteOfDay;

  /// Must be strictly greater than [startMinuteOfDay]
  /// (`OnboardingRules.validateReminderWindow`, `CPY-122`).
  final int endMinuteOfDay;

  /// One of 30/45/60/90/120/180/240 minutes (`FR-062`).
  final int intervalMinutes;

  /// ISO weekday numbers, `1` (Monday) – `7` (Sunday).
  final Set<int> activeWeekdays;

  /// `BR-30` — every reminder time in the window: `start, start+interval,
  /// …`, up to **and including** [endMinuteOfDay], dropping anything
  /// strictly after it. `ONB-08`'s live preview
  /// (`reminder_preview_card.dart`) reads this directly rather than
  /// re-deriving the rule, so there is exactly one implementation of
  /// `BR-30` to keep in sync.
  ///
  /// A non-positive [intervalMinutes] would loop forever, so it instead
  /// degrades to a single reminder at [startMinuteOfDay] — defensive
  /// only; `intervalMinutes` is always one of `FR-062`'s positive
  /// options in practice.
  List<int> reminderMinutes() {
    if (intervalMinutes <= 0) return [startMinuteOfDay];

    final minutes = <int>[];
    for (
      var minute = startMinuteOfDay;
      minute <= endMinuteOfDay;
      minute += intervalMinutes
    ) {
      minutes.add(minute);
    }
    return minutes;
  }

  ReminderPreferences copyWith({
    bool? enabled,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    int? intervalMinutes,
    Set<int>? activeWeekdays,
  }) {
    return ReminderPreferences(
      enabled: enabled ?? this.enabled,
      startMinuteOfDay: startMinuteOfDay ?? this.startMinuteOfDay,
      endMinuteOfDay: endMinuteOfDay ?? this.endMinuteOfDay,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderPreferences &&
        other.enabled == enabled &&
        other.startMinuteOfDay == startMinuteOfDay &&
        other.endMinuteOfDay == endMinuteOfDay &&
        other.intervalMinutes == intervalMinutes &&
        _setEquals(other.activeWeekdays, activeWeekdays);
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    startMinuteOfDay,
    endMinuteOfDay,
    intervalMinutes,
    Object.hashAllUnordered(activeWeekdays),
  );

  @override
  String toString() =>
      'ReminderPreferences(enabled: $enabled, startMinuteOfDay: '
      '$startMinuteOfDay, endMinuteOfDay: $endMinuteOfDay, '
      'intervalMinutes: $intervalMinutes)';
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (a.length != b.length) return false;
  return a.every(b.contains);
}
