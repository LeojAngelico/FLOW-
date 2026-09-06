import '../domain/models/profile_enums.dart';
import 'hydration_result.dart';

/// `08 §6.1`'s calculator contract — the seam that lets FLOW's hydration
/// methodology be replaced without touching any screen, repository or
/// table (`07 §5`, `08 §6.6`). Onboarding's `CalculateSuggestedTarget` /
/// `CompleteOnboarding` and `APP-08`'s target-settings usecase depend on
/// this interface only, never on a concrete strategy directly.
abstract interface class HydrationCalculator {
  /// e.g. `'reference_intake_v1'` — written verbatim to
  /// `user_profiles.calculator_method_id` (traceability, `07 §5`).
  /// Callers read this rather than hand-typing the string anywhere.
  String get methodId;

  /// A pure function of [inputs] — no clock, no I/O, no randomness
  /// (`07 §5`).
  SuggestedHydrationTarget calculate(HydrationInputs inputs);
}

/// Everything `08 §6.2`'s algorithm reads.
///
/// Deliberately a separate type from `UserProfile`, not a subset view of
/// it: `features/hydration/calculator/` may not import
/// `user_profile.dart` (`07 §5`'s "zero dependencies" claim would
/// otherwise be only approximately true), so it only ever sees the
/// shared vocabulary in `profile_enums.dart` plus these plain values.
class HydrationInputs {
  const HydrationInputs({
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.activityLevel,
    required this.environment,
    required this.specialCircumstances,
  });

  final int age;
  final Sex sex;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Environment environment;
  final Set<SpecialCircumstance> specialCircumstances;

  HydrationInputs copyWith({
    int? age,
    Sex? sex,
    double? weightKg,
    ActivityLevel? activityLevel,
    Environment? environment,
    Set<SpecialCircumstance>? specialCircumstances,
  }) {
    return HydrationInputs(
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      environment: environment ?? this.environment,
      specialCircumstances: specialCircumstances ?? this.specialCircumstances,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HydrationInputs &&
        other.age == age &&
        other.sex == sex &&
        other.weightKg == weightKg &&
        other.activityLevel == activityLevel &&
        other.environment == environment &&
        _setEquals(other.specialCircumstances, specialCircumstances);
  }

  @override
  int get hashCode => Object.hash(
    age,
    sex,
    weightKg,
    activityLevel,
    environment,
    Object.hashAllUnordered(specialCircumstances),
  );

  @override
  String toString() =>
      'HydrationInputs(age: $age, sex: $sex, weightKg: $weightKg, '
      'activityLevel: $activityLevel, environment: $environment)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.every(b.contains);
}
