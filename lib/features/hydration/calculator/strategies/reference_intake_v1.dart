import '../../domain/models/profile_enums.dart';
import '../hydration_calculator.dart';
import '../hydration_result.dart';

/// `08 §6.2`'s algorithm, verbatim. Pure Dart — no Flutter, Riverpod,
/// Drift, clock, I/O or randomness (`07 §5`). Every constant is a named
/// `static const` so each row of `08 §6.4`'s boundary table can be
/// traced back to a single source line.
///
/// `07 §5` calls this *"the single most important architectural
/// decision in the product"*: if this method is ever replaced, only this
/// file and `hydrationCalculatorProvider`'s override change — no screen,
/// repository or table (`08 §6.6`).
class ReferenceIntakeV1 implements HydrationCalculator {
  const ReferenceIntakeV1();

  @override
  String get methodId => 'reference_intake_v1';

  /// `08 §6.2` step 5's `FOOD_WATER_FRACTION`. Named lowerCamelCase to
  /// satisfy this project's `constant_identifier_names` lint rather than
  /// the spec's literal SCREAMING_SNAKE_CASE — the value and its
  /// single-source-of-truth placement are what the spec actually
  /// requires. The one value most likely to change after validation
  /// (`01 §12` A1), which is exactly why it lives in one named place
  /// instead of being inlined at its one call site.
  static const foodWaterFraction = 0.25;

  /// `08 §6.2` step 6 — the floor below age 14.
  static const _minTargetMlUnder14 = 1000;

  /// `08 §6.2` step 6 — the floor at 14 and above.
  static const _minTargetMlAtLeast14 = 1200;

  /// `08 §6.2` step 6 — the ceiling. No realistic input reaches it; it
  /// is a defensive guard for a future methodology change (`08 §6.4`
  /// note).
  static const _maxTargetMl = 4000;

  /// `08 §6.2` step 2 — ml per kg of weight above/below the reference.
  static const _weightDeltaPerKg = 20;

  /// `08 §6.2` step 2 — the weight adjustment is clamped to +/- this
  /// many ml before it is added to the baseline.
  static const _weightDeltaClampMl = 600;

  /// `08 §6.2` step 3.
  static const Map<ActivityLevel, int> _activityDeltaMl = {
    ActivityLevel.sedentary: 0,
    ActivityLevel.light: 250,
    ActivityLevel.moderate: 500,
    ActivityLevel.high: 750,
    ActivityLevel.athlete: 1000,
  };

  /// `08 §6.2` step 4.
  static const Map<Environment, int> _environmentDeltaMl = {
    Environment.temperate: 0,
    Environment.warm: 300,
    Environment.hot: 500,
    Environment.veryHot: 700,
  };

  @override
  SuggestedHydrationTarget calculate(HydrationInputs inputs) {
    // `BR-42`: `preferNotToSay` resolves to the female baseline and
    // reference weight — a privacy choice, not a third biological
    // category the tables below need their own column for.
    final effectiveSex = inputs.sex == Sex.male ? Sex.male : Sex.female;

    // Step 1 — baseline total water, by age band and sex.
    final baselineMl = _baselineMl(inputs.age, effectiveSex);

    // Step 2 — weight adjustment, clamped to +/- 600 ml.
    final referenceWeightKg = _referenceWeightKg(inputs.age, effectiveSex);
    final rawWeightDeltaMl =
        (inputs.weightKg - referenceWeightKg) * _weightDeltaPerKg;
    final clampedWeightDeltaMl = rawWeightDeltaMl.clamp(
      -_weightDeltaClampMl,
      _weightDeltaClampMl,
    );
    final weightDeltaClamped = clampedWeightDeltaMl != rawWeightDeltaMl;
    final weightDeltaMl = clampedWeightDeltaMl.round();

    // Step 3 — activity adjustment.
    final activityDeltaMl = _activityDeltaMl[inputs.activityLevel]!;

    // Step 4 — environment adjustment.
    final environmentDeltaMl = _environmentDeltaMl[inputs.environment]!;

    // Step 5 — total water -> drinking water.
    final totalWaterMl =
        baselineMl + weightDeltaMl + activityDeltaMl + environmentDeltaMl;
    final foodWaterMl = (totalWaterMl * foodWaterFraction).round();
    final drinkingWaterMl = totalWaterMl - foodWaterMl;

    // Step 6 — round half-up to the nearest 100 ml, then clamp.
    // Dart's `.round()` already rounds half away from zero, which for a
    // positive value is exactly "half-up" — `1050 -> 1100`, not the
    // banker's-rounding `1000` a naive port from another language might
    // produce. Stated explicitly because that difference produces
    // off-by-100 failures that are tedious to diagnose (`08 §6.2`).
    final roundedMl = (drinkingWaterMl / 100).round() * 100;
    final minTargetMl = inputs.age < 14
        ? _minTargetMlUnder14
        : _minTargetMlAtLeast14;
    final clampedMl = roundedMl.clamp(minTargetMl, _maxTargetMl);
    final resultClamped = clampedMl != roundedMl;

    // Step 7 — special circumstances never change the number; they only
    // flag that a professional should be consulted (`FR-011`).
    final requiresProfessionalNotice = inputs.specialCircumstances.isNotEmpty;

    final breakdown = <BreakdownLine>[
      BreakdownLine(labelId: 'baseline', deltaMl: baselineMl),
      BreakdownLine(labelId: 'weightAdjustment', deltaMl: weightDeltaMl),
      BreakdownLine(
        labelId: 'activity',
        labelArg: inputs.activityLevel.name,
        deltaMl: activityDeltaMl,
      ),
      BreakdownLine(
        labelId: 'environment',
        labelArg: inputs.environment.name,
        deltaMl: environmentDeltaMl,
      ),
      BreakdownLine(
        labelId: 'totalWaterSubtotal',
        deltaMl: totalWaterMl,
        isSubtotal: true,
      ),
      BreakdownLine(labelId: 'foodWaterDeduction', deltaMl: -foodWaterMl),
      BreakdownLine(
        labelId: 'drinkingTargetSubtotal',
        deltaMl: drinkingWaterMl,
        isSubtotal: true,
      ),
    ];

    final assumptions = <String>[
      'foodWaterFraction',
      if (weightDeltaClamped) 'weightAdjustmentClamped',
      if (resultClamped) 'resultClamped',
    ];

    return SuggestedHydrationTarget(
      amountMl: clampedMl,
      amountLiters: clampedMl / 1000,
      calculationMethodId: methodId,
      methodId: methodId,
      breakdown: breakdown,
      assumptions: assumptions,
      disclaimer: 'referenceIntakeDisclaimer',
      requiresProfessionalNotice: requiresProfessionalNotice,
    );
  }

  /// `08 §6.2` step 1's baseline table. Age bands here (9–13, 14–64,
  /// 65+) are **not** the same bands [_referenceWeightKg] uses — the
  /// spec defines the two tables independently.
  int _baselineMl(int age, Sex sex) {
    if (age <= 13) {
      return sex == Sex.male ? 2100 : 1900;
    }
    // 14-64 and 65+ share the same baseline.
    return sex == Sex.male ? 2500 : 2000;
  }

  /// `08 §6.2` step 2's reference-weight table (9–13, 14–17, 18+) — a
  /// different age banding from [_baselineMl], by spec.
  double _referenceWeightKg(int age, Sex sex) {
    if (age <= 13) {
      return sex == Sex.male ? 42 : 40;
    }
    if (age <= 17) {
      return sex == Sex.male ? 62 : 55;
    }
    return sex == Sex.male ? 70 : 60;
  }
}
