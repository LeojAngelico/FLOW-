import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../calculator/hydration_calculator.dart';
import '../../calculator/strategies/reference_intake_v1.dart';

part 'hydration_calculator_provider.g.dart';

/// The single override point for swapping hydration methodologies
/// (`07 §5`, `08 §6.6`). Onboarding's `CalculateSuggestedTarget` /
/// `CompleteOnboarding` and `APP-08`'s target-settings usecase all read
/// this provider rather than constructing a strategy directly, so
/// replacing the method is a one-line override here — no screen,
/// repository or table changes.
///
/// Deliberately outside `calculator/`: that directory may not import
/// Riverpod (`07 §5`'s zero-dependency claim), so the provider that
/// binds a concrete strategy to it lives one level up, alongside
/// `user_profile.dart` and `profile_enums.dart`.
///
/// `keepAlive` — a stateless, pure strategy binding, mirroring
/// `core/time/clock_provider.dart`'s `clockProvider`.
@Riverpod(keepAlive: true)
HydrationCalculator hydrationCalculator(Ref ref) {
  return const ReferenceIntakeV1();
}
