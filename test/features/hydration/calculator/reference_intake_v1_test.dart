import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/calculator/hydration_calculator.dart';
import 'package:flow/features/hydration/calculator/strategies/reference_intake_v1.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';

/// `08 §6.4`'s worked boundary table, hand-verified against the algorithm
/// in `08 §6.2` before writing a single assertion here (see the workplan's
/// own inline arithmetic). If the implementation disagrees with any of
/// these ten rows, the implementation is wrong, not the test.
void main() {
  const calculator = ReferenceIntakeV1();

  HydrationInputs inputs({
    required int age,
    required Sex sex,
    required double weightKg,
    required ActivityLevel activityLevel,
    required Environment environment,
    Set<SpecialCircumstance> specialCircumstances = const {},
  }) {
    return HydrationInputs(
      age: age,
      sex: sex,
      weightKg: weightKg,
      activityLevel: activityLevel,
      environment: environment,
      specialCircumstances: specialCircumstances,
    );
  }

  group('methodId', () {
    test('is reference_intake_v1, traced into every result', () {
      expect(calculator.methodId, 'reference_intake_v1');
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 70,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.methodId, 'reference_intake_v1');
      expect(result.calculationMethodId, 'reference_intake_v1');
    });
  });

  group('08 §6.4 boundary table (TC-100-TC-115)', () {
    test('youngest, smallest: 9F, 25kg, sedentary, temperate -> 1,200 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 9,
          sex: Sex.female,
          weightKg: 25,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1200);
      expect(result.amountLiters, 1.2);
    });

    test('small teen: 14F, 45kg, sedentary, temperate -> 1,400 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 14,
          sex: Sex.female,
          weightKg: 45,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1400);
    });

    test(
      'typical adult female: 24F, 60kg, sedentary, temperate -> 1,500 ml',
      () {
        final result = calculator.calculate(
          inputs(
            age: 24,
            sex: Sex.female,
            weightKg: 60,
            activityLevel: ActivityLevel.sedentary,
            environment: Environment.temperate,
          ),
        );
        expect(result.amountMl, 1500);
      },
    );

    test('typical adult male: 30M, 70kg, sedentary, temperate -> 1,900 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 70,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1900);
    });

    test('worked example (OVL-10): 24F, 68kg, light, warm -> 2,000 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 24,
          sex: Sex.female,
          weightKg: 68,
          activityLevel: ActivityLevel.light,
          environment: Environment.warm,
        ),
      );
      expect(result.amountMl, 2000);
      expect(result.amountLiters, 2.0);
    });

    test('active male, hot: 30M, 80kg, high, hot -> 3,000 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 80,
          activityLevel: ActivityLevel.high,
          environment: Environment.hot,
        ),
      );
      expect(result.amountMl, 3000);
    });

    test('athlete, very hot: 28M, 85kg, athlete, veryHot -> 3,400 ml', () {
      final result = calculator.calculate(
        inputs(
          age: 28,
          sex: Sex.male,
          weightKg: 85,
          activityLevel: ActivityLevel.athlete,
          environment: Environment.veryHot,
        ),
      );
      expect(result.amountMl, 3400);
    });

    test('very heavy, extreme: 40M, 250kg, athlete, veryHot -> 3,600 ml '
        '(weight delta clamped at +600)', () {
      final result = calculator.calculate(
        inputs(
          age: 40,
          sex: Sex.male,
          weightKg: 250,
          activityLevel: ActivityLevel.athlete,
          environment: Environment.veryHot,
        ),
      );
      expect(result.amountMl, 3600);
      expect(result.assumptions, contains('weightAdjustmentClamped'));
    });

    test('weight clamp low: 30F, 25kg, sedentary, temperate -> 1,200 ml '
        '(min clamp)', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.female,
          weightKg: 25,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1200);
      expect(result.assumptions, contains('weightAdjustmentClamped'));
      expect(result.assumptions, contains('resultClamped'));
    });

    test('preferNotToSay: 30X, 70kg, moderate, temperate -> 2,000 ml '
        '(female baseline, BR-42)', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.preferNotToSay,
          weightKg: 70,
          activityLevel: ActivityLevel.moderate,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 2000);
    });
  });

  group('BR-42: preferNotToSay resolves to the female result exactly', () {
    test(
      'identical amountMl/breakdown/assumptions to an explicit female input',
      () {
        final female = calculator.calculate(
          inputs(
            age: 45,
            sex: Sex.female,
            weightKg: 55,
            activityLevel: ActivityLevel.high,
            environment: Environment.hot,
          ),
        );
        final preferNotToSay = calculator.calculate(
          inputs(
            age: 45,
            sex: Sex.preferNotToSay,
            weightKg: 55,
            activityLevel: ActivityLevel.high,
            environment: Environment.hot,
          ),
        );

        expect(preferNotToSay.amountMl, female.amountMl);
        expect(preferNotToSay, female);
      },
    );
  });

  group('half-up rounding (not banker\'s rounding)', () {
    test('a drinking total ending exactly at x50 rounds up, not to even '
        '(2,200 total water -> 1,650 drinking -> 1,700 ml, mirroring the '
        'workplan\'s own 1,050 -> 1,100 example)', () {
      // baseline (female, 18+) 2000 + weightDelta (70-60)*20=200 = 2200
      // total water; food = round(2200*0.25)=550; drinking = 1650;
      // 1650/100 = 16.5 -> rounds up to 17*100 = 1700, comfortably clear
      // of both the floor and the ceiling so the rounding rule alone is
      // what determines the result.
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.female,
          weightKg: 70,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1700);
    });
  });

  group('the +/-600ml weight-delta clamp', () {
    test('an extreme underweight input clamps the delta at -600ml', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 1,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      // reference weight (male, 18+) is 70kg; an uncapped delta would be
      // (1-70)*20 = -1380ml, clamped to -600ml.
      expect(result.assumptions, contains('weightAdjustmentClamped'));
    });

    test('an extreme overweight input clamps the delta at +600ml', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 400,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.assumptions, contains('weightAdjustmentClamped'));
    });

    test('a weight within +/-30kg of the reference is never clamped', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.male,
          weightKg: 75, // (75-70)*20 = 100ml, well inside +/-600
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.assumptions, isNot(contains('weightAdjustmentClamped')));
    });
  });

  group('the age < 14 floor (1,000 ml) vs the age >= 14 floor (1,200 ml)', () {
    test('under 14: the algorithm\'s achievable minimum for this age band '
        'lands exactly on the 1,000ml floor (weight delta is clamped at '
        '-600ml regardless of how extreme the input weight is)', () {
      final result = calculator.calculate(
        inputs(
          age: 9,
          sex: Sex.female,
          weightKg: 0,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.amountMl, 1000);
    });

    test('14 and over: the equivalent extreme input is clamped up from a '
        'rounded 1,100ml to the higher 1,200ml floor', () {
      final result = calculator.calculate(
        inputs(
          age: 14,
          sex: Sex.female,
          weightKg: 0,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      // baseline (14-17, female) 2000 + weightDelta clamp(-600) = 1400;
      // food = round(1400*0.25) = 350; drinking = 1050; rounds to 1100
      // (the workplan's own "1,050 -> 1,100" example, made visible here
      // because it happens to also cross the age>=14 floor) -> clamped
      // up to 1200.
      expect(result.amountMl, 1200);
      expect(result.assumptions, contains('resultClamped'));
    });
  });

  group('requiresProfessionalNotice (FR-011) — informs, never blocks', () {
    test('false when no special circumstance is selected', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.female,
          weightKg: 60,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
        ),
      );
      expect(result.requiresProfessionalNotice, isFalse);
    });

    test('true when any special circumstance is selected, and the number '
        'is still produced', () {
      final result = calculator.calculate(
        inputs(
          age: 30,
          sex: Sex.female,
          weightKg: 60,
          activityLevel: ActivityLevel.sedentary,
          environment: Environment.temperate,
          specialCircumstances: {SpecialCircumstance.pregnancy},
        ),
      );
      expect(result.requiresProfessionalNotice, isTrue);
      expect(result.amountMl, 1500);
    });
  });

  group('breakdown[] integrity', () {
    test('non-subtotal deltas sum to the pre-rounding drinking total '
        '(worked example: 2,000 + 160 + 250 + 300 - 678 = 2,032)', () {
      final result = calculator.calculate(
        inputs(
          age: 24,
          sex: Sex.female,
          weightKg: 68,
          activityLevel: ActivityLevel.light,
          environment: Environment.warm,
        ),
      );

      final sumOfLines = result.breakdown
          .where((line) => !line.isSubtotal)
          .fold<int>(0, (total, line) => total + line.deltaMl);

      expect(sumOfLines, 2032);
    });

    test('the breakdown carries exactly one line per algorithm step, plus '
        'two subtotals', () {
      final result = calculator.calculate(
        inputs(
          age: 24,
          sex: Sex.female,
          weightKg: 68,
          activityLevel: ActivityLevel.light,
          environment: Environment.warm,
        ),
      );

      expect(result.breakdown.map((line) => line.labelId).toList(), [
        'baseline',
        'weightAdjustment',
        'activity',
        'environment',
        'totalWaterSubtotal',
        'foodWaterDeduction',
        'drinkingTargetSubtotal',
      ]);
      expect(result.breakdown.where((l) => l.isSubtotal).length, 2);
    });
  });
}
