import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/time/clock_provider.dart';
import '../../../hydration/domain/providers/hydration_calculator_provider.dart';
import '../../data/providers/onboarding_data_providers.dart';
import '../usecases/calculate_suggested_target.dart';
import '../usecases/complete_onboarding.dart';

part 'onboarding_usecase_providers.g.dart';

/// `07 §5`'s calculator swap point is `hydrationCalculatorProvider`;
/// this usecase just reads it — `target_notifier.dart` never has to
/// know the calculator exists.
@riverpod
CalculateSuggestedTarget calculateSuggestedTarget(Ref ref) {
  return CalculateSuggestedTarget(ref.watch(hydrationCalculatorProvider));
}

/// Reads all three of its collaborators from providers declared
/// elsewhere — `onboardingRepositoryProvider` (`data/providers/`),
/// `hydrationCalculatorProvider` (hydration's `domain/providers/`) and
/// `clockProvider` (`core/time/`) — so this file plus
/// `onboarding_data_providers.dart` form the SKILL § Provider wiring
/// two-file pattern.
@riverpod
CompleteOnboarding completeOnboarding(Ref ref) {
  return CompleteOnboarding(
    ref.watch(onboardingRepositoryProvider),
    ref.watch(hydrationCalculatorProvider),
    ref.watch(clockProvider),
  );
}
