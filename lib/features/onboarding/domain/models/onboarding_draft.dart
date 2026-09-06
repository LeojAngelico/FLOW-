import '../../../hydration/domain/models/profile_enums.dart';
import 'reminder_preferences.dart';

/// Every onboarding answer given so far, surviving Back and Forward
/// across all six answer screens (`FR-018`). Owned by
/// `OnboardingDraftNotifier`
/// (`presentation/onboarding_draft_notifier.dart`) — every screen writes
/// through to this model rather than keeping its own copy of an answer.
///
/// [specialCircumstances] and [reminders] are the only fields with a
/// spec'd default (`{}`, and `FR-015`'s seeded values respectively);
/// every other field starts `null` and is filled in as its screen is
/// completed. Defaulting [reminders] rather than leaving it nullable
/// keeps a Skip on `ONB-08` — which may never touch the window, interval
/// or weekday fields — a simple flip of `enabled` on already-valid data,
/// instead of a null-handling branch inside `CompleteOnboarding`.
class OnboardingDraft {
  const OnboardingDraft({
    this.displayName,
    this.age,
    this.sex,
    this.weightKg,
    this.activityLevel,
    this.environment,
    this.specialCircumstances = const {},
    this.manualTargetMl,
    this.reminders = const ReminderPreferences.defaults(),
  });

  /// `ONB-03`. Trimmed, ≤ 24 runes, optional (`FR-003`).
  final String? displayName;

  /// `ONB-03`. 9–120 (`FR-004`).
  final int? age;

  /// `ONB-03`.
  final Sex? sex;

  /// `ONB-04`, kilograms, 25.0–250.0 (`FR-006`).
  final double? weightKg;

  /// `ONB-05`.
  final ActivityLevel? activityLevel;

  /// `ONB-06`.
  final Environment? environment;

  /// `ONB-06`. Empty means none selected — the only one of the six
  /// answer screens' fields with a genuinely empty *valid* answer, so it
  /// defaults to `{}` rather than starting `null`.
  final Set<SpecialCircumstance> specialCircumstances;

  /// `ONB-07`. `null` means the suggested value is still in force
  /// (`targetSource == suggested`); set only by Adjust, and cleared by a
  /// revert back to the suggestion — **never** set by Accept. That is
  /// what lets `CompleteOnboarding` resolve `targetSource` from this
  /// field alone, even when the adjusted value happens to equal the
  /// suggestion.
  final int? manualTargetMl;

  /// `ONB-08`. Defaults to `FR-015`'s seeded values so the draft is
  /// always submittable, even before `ONB-08` is reached.
  final ReminderPreferences reminders;

  /// Everything `CalculateSuggestedTarget` needs.
  /// [specialCircumstances] is not required here — an empty set is
  /// itself a valid, meaningful answer (`ONB-06`'s "none of these").
  bool get isReadyForTarget =>
      age != null &&
      sex != null &&
      weightKg != null &&
      activityLevel != null &&
      environment != null;

  /// Everything `CompleteOnboarding` needs to build a `UserProfile`.
  /// Identical to [isReadyForTarget] today: [manualTargetMl] staying
  /// `null` is the valid Accept case, not an incomplete one, and
  /// [reminders] always carries a value (its own default, if `ONB-08`
  /// was skipped or never reached). If a future field has no sensible
  /// default, extend this getter rather than [isReadyForTarget].
  bool get isComplete => isReadyForTarget;

  static const _unset = Object();

  OnboardingDraft copyWith({
    Object? displayName = _unset,
    int? age,
    Sex? sex,
    double? weightKg,
    ActivityLevel? activityLevel,
    Environment? environment,
    Set<SpecialCircumstance>? specialCircumstances,
    Object? manualTargetMl = _unset,
    ReminderPreferences? reminders,
  }) {
    return OnboardingDraft(
      displayName: identical(displayName, _unset)
          ? this.displayName
          : displayName as String?,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      environment: environment ?? this.environment,
      specialCircumstances: specialCircumstances ?? this.specialCircumstances,
      manualTargetMl: identical(manualTargetMl, _unset)
          ? this.manualTargetMl
          : manualTargetMl as int?,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingDraft &&
        other.displayName == displayName &&
        other.age == age &&
        other.sex == sex &&
        other.weightKg == weightKg &&
        other.activityLevel == activityLevel &&
        other.environment == environment &&
        _setEquals(other.specialCircumstances, specialCircumstances) &&
        other.manualTargetMl == manualTargetMl &&
        other.reminders == reminders;
  }

  @override
  int get hashCode => Object.hash(
    displayName,
    age,
    sex,
    weightKg,
    activityLevel,
    environment,
    Object.hashAllUnordered(specialCircumstances),
    manualTargetMl,
    reminders,
  );

  @override
  String toString() =>
      'OnboardingDraft(age: $age, sex: $sex, weightKg: $weightKg, '
      'activityLevel: $activityLevel, environment: $environment, '
      'manualTargetMl: $manualTargetMl)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.every(b.contains);
}
