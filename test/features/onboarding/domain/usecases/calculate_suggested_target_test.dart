import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/hydration/calculator/hydration_calculator.dart';
import 'package:flow/features/hydration/calculator/hydration_result.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/onboarding/domain/models/onboarding_draft.dart';
import 'package:flow/features/onboarding/domain/usecases/calculate_suggested_target.dart';

/// Stands in for `ReferenceIntakeV1` (or any `HydrationCalculator`).
/// Captures the [HydrationInputs] it was called with so a test can assert
/// the draft -> inputs mapping directly, without depending on the real
/// algorithm's arithmetic.
class _CapturingCalculator implements HydrationCalculator {
  HydrationInputs? lastInputs;
  int callCount = 0;

  @override
  String get methodId => 'capturing_test_method';

  @override
  SuggestedHydrationTarget calculate(HydrationInputs inputs) {
    callCount++;
    lastInputs = inputs;
    return const SuggestedHydrationTarget(
      amountMl: 2000,
      amountLiters: 2.0,
      calculationMethodId: 'capturing_test_method',
      methodId: 'capturing_test_method',
      breakdown: [],
      assumptions: [],
      disclaimer: 'referenceIntakeDisclaimer',
      requiresProfessionalNotice: false,
    );
  }
}

void main() {
  late _CapturingCalculator calculator;
  late CalculateSuggestedTarget useCase;

  setUp(() {
    calculator = _CapturingCalculator();
    useCase = CalculateSuggestedTarget(calculator);
  });

  test('a fully-answered draft maps faithfully to HydrationInputs', () {
    const draft = OnboardingDraft(
      age: 24,
      sex: Sex.female,
      weightKg: 68,
      activityLevel: ActivityLevel.light,
      environment: Environment.warm,
      specialCircumstances: {SpecialCircumstance.pregnancy},
    );

    final result = useCase.call(draft);

    expect(result, isA<Ok<SuggestedHydrationTarget>>());
    expect(calculator.callCount, 1);
    expect(calculator.lastInputs, isNotNull);
    expect(calculator.lastInputs!.age, 24);
    expect(calculator.lastInputs!.sex, Sex.female);
    expect(calculator.lastInputs!.weightKg, 68);
    expect(calculator.lastInputs!.activityLevel, ActivityLevel.light);
    expect(calculator.lastInputs!.environment, Environment.warm);
    expect(calculator.lastInputs!.specialCircumstances, {
      SpecialCircumstance.pregnancy,
    });
  });

  test('an empty specialCircumstances set maps through as empty, not '
      'omitted', () {
    const draft = OnboardingDraft(
      age: 30,
      sex: Sex.male,
      weightKg: 70,
      activityLevel: ActivityLevel.sedentary,
      environment: Environment.temperate,
    );

    useCase.call(draft);

    expect(calculator.lastInputs!.specialCircumstances, isEmpty);
  });

  group('an incomplete draft', () {
    test('returns a ValidationFailure instead of throwing when age is '
        'missing', () {
      const draft = OnboardingDraft(
        sex: Sex.female,
        weightKg: 60,
        activityLevel: ActivityLevel.moderate,
        environment: Environment.temperate,
      );

      final result = useCase.call(draft);

      expect(result, isA<Err<SuggestedHydrationTarget>>());
      expect(
        (result as Err<SuggestedHydrationTarget>).failure,
        isA<ValidationFailure>(),
      );
      expect(calculator.callCount, 0);
    });

    test('a brand-new draft never reaches the calculator', () {
      const draft = OnboardingDraft();

      final result = useCase.call(draft);

      expect(result, isA<Err<SuggestedHydrationTarget>>());
      expect(calculator.callCount, 0);
    });
  });
}
