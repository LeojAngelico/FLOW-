// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(hydrationCalculator)
final hydrationCalculatorProvider = HydrationCalculatorProvider._();

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

final class HydrationCalculatorProvider
    extends
        $FunctionalProvider<
          HydrationCalculator,
          HydrationCalculator,
          HydrationCalculator
        >
    with $Provider<HydrationCalculator> {
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
  HydrationCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydrationCalculatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydrationCalculatorHash();

  @$internal
  @override
  $ProviderElement<HydrationCalculator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HydrationCalculator create(Ref ref) {
    return hydrationCalculator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydrationCalculator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydrationCalculator>(value),
    );
  }
}

String _$hydrationCalculatorHash() =>
    r'9107d25dfc51111a65960d5f7a56218d3cd49bf5';
