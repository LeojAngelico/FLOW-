// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `07 §5`'s calculator swap point is `hydrationCalculatorProvider`;
/// this usecase just reads it — `target_notifier.dart` never has to
/// know the calculator exists.

@ProviderFor(calculateSuggestedTarget)
final calculateSuggestedTargetProvider = CalculateSuggestedTargetProvider._();

/// `07 §5`'s calculator swap point is `hydrationCalculatorProvider`;
/// this usecase just reads it — `target_notifier.dart` never has to
/// know the calculator exists.

final class CalculateSuggestedTargetProvider
    extends
        $FunctionalProvider<
          CalculateSuggestedTarget,
          CalculateSuggestedTarget,
          CalculateSuggestedTarget
        >
    with $Provider<CalculateSuggestedTarget> {
  /// `07 §5`'s calculator swap point is `hydrationCalculatorProvider`;
  /// this usecase just reads it — `target_notifier.dart` never has to
  /// know the calculator exists.
  CalculateSuggestedTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calculateSuggestedTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calculateSuggestedTargetHash();

  @$internal
  @override
  $ProviderElement<CalculateSuggestedTarget> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalculateSuggestedTarget create(Ref ref) {
    return calculateSuggestedTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalculateSuggestedTarget value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalculateSuggestedTarget>(value),
    );
  }
}

String _$calculateSuggestedTargetHash() =>
    r'180e0101daad736ee0fb148843a8ca5c98f4bfc5';

/// Reads all three of its collaborators from providers declared
/// elsewhere — `onboardingRepositoryProvider` (`data/providers/`),
/// `hydrationCalculatorProvider` (hydration's `domain/providers/`) and
/// `clockProvider` (`core/time/`) — so this file plus
/// `onboarding_data_providers.dart` form the SKILL § Provider wiring
/// two-file pattern.

@ProviderFor(completeOnboarding)
final completeOnboardingProvider = CompleteOnboardingProvider._();

/// Reads all three of its collaborators from providers declared
/// elsewhere — `onboardingRepositoryProvider` (`data/providers/`),
/// `hydrationCalculatorProvider` (hydration's `domain/providers/`) and
/// `clockProvider` (`core/time/`) — so this file plus
/// `onboarding_data_providers.dart` form the SKILL § Provider wiring
/// two-file pattern.

final class CompleteOnboardingProvider
    extends
        $FunctionalProvider<
          CompleteOnboarding,
          CompleteOnboarding,
          CompleteOnboarding
        >
    with $Provider<CompleteOnboarding> {
  /// Reads all three of its collaborators from providers declared
  /// elsewhere — `onboardingRepositoryProvider` (`data/providers/`),
  /// `hydrationCalculatorProvider` (hydration's `domain/providers/`) and
  /// `clockProvider` (`core/time/`) — so this file plus
  /// `onboarding_data_providers.dart` form the SKILL § Provider wiring
  /// two-file pattern.
  CompleteOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeOnboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeOnboardingHash();

  @$internal
  @override
  $ProviderElement<CompleteOnboarding> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompleteOnboarding create(Ref ref) {
    return completeOnboarding(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteOnboarding value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteOnboarding>(value),
    );
  }
}

String _$completeOnboardingHash() =>
    r'364426483059ffb087c5dc285d3bf53a77dbc640';
