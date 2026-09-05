import 'profile_enums.dart';

/// The domain shape of a `user_profiles` row — ENT-01's thirteen fields.
///
/// Lives under `hydration/`, not `onboarding/`, even though onboarding is
/// its only *writer*: hydration, settings and `APP-08` are all
/// long-lived *readers*, and ownership should follow the readers rather
/// than the one-time writer (see
/// `docs/workplans/2026-09-05-onboarding.md` Decisions #2). Write-side
/// mapping lives in
/// `features/onboarding/data/models/user_profile_mapper.dart`;
/// nothing reads a row back into this shape yet — a `fromDb` reader
/// would be dead code this pass (hydration Decisions #15's precedent),
/// and settings/`APP-08` add it when they need it.
class UserProfile {
  const UserProfile({
    this.id = 1,
    this.displayName,
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.activityLevel,
    required this.environment,
    this.specialCircumstances = const {},
    required this.dailyTargetMl,
    required this.targetSource,
    required this.calculatorMethodId,
    required this.profileCreatedAt,
    required this.updatedAt,
  });

  /// Always `1` — `user_profiles` is a singleton table. Carried here for
  /// parity with ENT-01's full field list; the write path
  /// (`user_profile_mapper.dart`) hardcodes `id: 1` on the companion
  /// regardless of what this field holds, so it is never actually
  /// load-bearing on the way into storage — see the workplan's
  /// Decisions #14.
  final int id;

  /// `null` renders a neutral greeting (`FR-003`). Trimmed, at most 24
  /// characters — enforced by `OnboardingRules.validateDisplayName`
  /// before this model is ever constructed.
  final String? displayName;

  /// Age **at onboarding**, paired with [profileCreatedAt] so age can be
  /// recomputed as years pass (ENT-01). 9–120 inclusive.
  final int age;

  final Sex sex;

  /// Kilograms, 25.0–250.0, rounded to one decimal (`FR-006`).
  final double weightKg;

  final ActivityLevel activityLevel;

  final Environment environment;

  /// Empty means none selected — the column default is `''`.
  final Set<SpecialCircumstance> specialCircumstances;

  /// The **active** target, 500–4,000 ml.
  final int dailyTargetMl;

  /// Whether [dailyTargetMl] came from the calculator or a manual edit
  /// (`FR-101`).
  final TargetSource targetSource;

  /// e.g. `'reference_intake_v1'` — always read from the calculator's
  /// `methodId`, never a literal (`07 §5` traceability).
  final String calculatorMethodId;

  /// UTC. Days before this are `noData` (`BR-19`).
  final DateTime profileCreatedAt;

  /// UTC.
  final DateTime updatedAt;

  static const _unset = Object();

  UserProfile copyWith({
    int? id,
    Object? displayName = _unset,
    int? age,
    Sex? sex,
    double? weightKg,
    ActivityLevel? activityLevel,
    Environment? environment,
    Set<SpecialCircumstance>? specialCircumstances,
    int? dailyTargetMl,
    TargetSource? targetSource,
    String? calculatorMethodId,
    DateTime? profileCreatedAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: identical(displayName, _unset)
          ? this.displayName
          : displayName as String?,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      environment: environment ?? this.environment,
      specialCircumstances: specialCircumstances ?? this.specialCircumstances,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      targetSource: targetSource ?? this.targetSource,
      calculatorMethodId: calculatorMethodId ?? this.calculatorMethodId,
      profileCreatedAt: profileCreatedAt ?? this.profileCreatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.id == id &&
        other.displayName == displayName &&
        other.age == age &&
        other.sex == sex &&
        other.weightKg == weightKg &&
        other.activityLevel == activityLevel &&
        other.environment == environment &&
        _setEquals(other.specialCircumstances, specialCircumstances) &&
        other.dailyTargetMl == dailyTargetMl &&
        other.targetSource == targetSource &&
        other.calculatorMethodId == calculatorMethodId &&
        other.profileCreatedAt == profileCreatedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    age,
    sex,
    weightKg,
    activityLevel,
    environment,
    Object.hashAllUnordered(specialCircumstances),
    dailyTargetMl,
    targetSource,
    calculatorMethodId,
    profileCreatedAt,
    updatedAt,
  );

  @override
  String toString() =>
      'UserProfile(age: $age, sex: $sex, weightKg: $weightKg, '
      'dailyTargetMl: $dailyTargetMl, targetSource: $targetSource)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.every(b.contains);
}
