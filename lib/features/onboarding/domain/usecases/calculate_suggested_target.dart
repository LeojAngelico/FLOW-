import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../hydration/calculator/hydration_calculator.dart';
import '../../../hydration/calculator/hydration_result.dart';
import '../models/onboarding_draft.dart';

/// Turns the draft's answers into a suggested hydration target
/// (`ONB-07`, `08 §6`).
///
/// Not a pointless wrapper around [HydrationCalculator.calculate]: an
/// incomplete draft becomes a typed [ValidationFailure] here instead of
/// a null-check crash inside the calculator, and this is the seam that
/// keeps `target_notifier.dart` from knowing the calculator exists at
/// all — only this usecase and `CompleteOnboarding` do.
class CalculateSuggestedTarget {
  CalculateSuggestedTarget(this._calculator);

  final HydrationCalculator _calculator;

  Result<SuggestedHydrationTarget> call(OnboardingDraft draft) {
    if (!draft.isReadyForTarget) {
      return Result.err(
        ValidationFailure(
          'draft',
          'Basics, weight, activity and environment must all be answered '
              'before a target can be suggested.',
        ),
      );
    }

    final inputs = HydrationInputs(
      age: draft.age!,
      sex: draft.sex!,
      weightKg: draft.weightKg!,
      activityLevel: draft.activityLevel!,
      environment: draft.environment!,
      specialCircumstances: draft.specialCircumstances,
    );

    return Result.ok(_calculator.calculate(inputs));
  }
}
