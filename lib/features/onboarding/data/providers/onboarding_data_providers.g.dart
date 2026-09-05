// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `keepAlive` — long-lived infra bindings, mirroring
/// `hydration_data_providers.dart` and `core/database/database_provider.dart`.

@ProviderFor(onboardingLocalDataSource)
final onboardingLocalDataSourceProvider = OnboardingLocalDataSourceProvider._();

/// `keepAlive` — long-lived infra bindings, mirroring
/// `hydration_data_providers.dart` and `core/database/database_provider.dart`.

final class OnboardingLocalDataSourceProvider
    extends
        $FunctionalProvider<
          OnboardingLocalDataSource,
          OnboardingLocalDataSource,
          OnboardingLocalDataSource
        >
    with $Provider<OnboardingLocalDataSource> {
  /// `keepAlive` — long-lived infra bindings, mirroring
  /// `hydration_data_providers.dart` and `core/database/database_provider.dart`.
  OnboardingLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<OnboardingLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingLocalDataSource create(Ref ref) {
    return onboardingLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingLocalDataSource>(value),
    );
  }
}

String _$onboardingLocalDataSourceHash() =>
    r'7073303441f253173e7ee308f92e00b495641e2b';

@ProviderFor(onboardingPreferencesDataSource)
final onboardingPreferencesDataSourceProvider =
    OnboardingPreferencesDataSourceProvider._();

final class OnboardingPreferencesDataSourceProvider
    extends
        $FunctionalProvider<
          OnboardingPreferencesDataSource,
          OnboardingPreferencesDataSource,
          OnboardingPreferencesDataSource
        >
    with $Provider<OnboardingPreferencesDataSource> {
  OnboardingPreferencesDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingPreferencesDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingPreferencesDataSourceHash();

  @$internal
  @override
  $ProviderElement<OnboardingPreferencesDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingPreferencesDataSource create(Ref ref) {
    return onboardingPreferencesDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingPreferencesDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingPreferencesDataSource>(
        value,
      ),
    );
  }
}

String _$onboardingPreferencesDataSourceHash() =>
    r'f6b6ec3ad4a9b423be5a2227ff0051a09b34100d';

/// Typed as the domain interface, not the implementation, so a test can
/// override this one provider and replace the whole data layer with a
/// fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `OnboardingRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

/// Typed as the domain interface, not the implementation, so a test can
/// override this one provider and replace the whole data layer with a
/// fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `OnboardingRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  /// Typed as the domain interface, not the implementation, so a test can
  /// override this one provider and replace the whole data layer with a
  /// fake (`flutter-architecture-map` SKILL § Provider wiring).
  ///
  /// Forward reference: `OnboardingRepository` (`domain/repositories/`)
  /// did not exist yet when this file was written — see the workplan's
  /// Decisions log.
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'db736a55ba103ed3d63d07f01d255bed6d7fcddb';
