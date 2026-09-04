// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `keepAlive` — this is a long-lived infra binding, not per-screen
/// state, mirroring `core/database/database_provider.dart`.

@ProviderFor(hydrationLocalDataSource)
final hydrationLocalDataSourceProvider = HydrationLocalDataSourceProvider._();

/// `keepAlive` — this is a long-lived infra binding, not per-screen
/// state, mirroring `core/database/database_provider.dart`.

final class HydrationLocalDataSourceProvider
    extends
        $FunctionalProvider<
          HydrationLocalDataSource,
          HydrationLocalDataSource,
          HydrationLocalDataSource
        >
    with $Provider<HydrationLocalDataSource> {
  /// `keepAlive` — this is a long-lived infra binding, not per-screen
  /// state, mirroring `core/database/database_provider.dart`.
  HydrationLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydrationLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydrationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<HydrationLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HydrationLocalDataSource create(Ref ref) {
    return hydrationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydrationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydrationLocalDataSource>(value),
    );
  }
}

String _$hydrationLocalDataSourceHash() =>
    r'4b6e751edad7c28b890e073db31be27e8a36d224';

/// Typed as the domain interface, not the implementation, so a test
/// can override this one provider and replace the whole data layer
/// with a fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `HydrationRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.

@ProviderFor(hydrationRepository)
final hydrationRepositoryProvider = HydrationRepositoryProvider._();

/// Typed as the domain interface, not the implementation, so a test
/// can override this one provider and replace the whole data layer
/// with a fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `HydrationRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.

final class HydrationRepositoryProvider
    extends
        $FunctionalProvider<
          HydrationRepository,
          HydrationRepository,
          HydrationRepository
        >
    with $Provider<HydrationRepository> {
  /// Typed as the domain interface, not the implementation, so a test
  /// can override this one provider and replace the whole data layer
  /// with a fake (`flutter-architecture-map` SKILL § Provider wiring).
  ///
  /// Forward reference: `HydrationRepository` (`domain/repositories/`)
  /// did not exist yet when this file was written — see the workplan's
  /// Decisions log.
  HydrationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydrationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydrationRepositoryHash();

  @$internal
  @override
  $ProviderElement<HydrationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HydrationRepository create(Ref ref) {
    return hydrationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydrationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydrationRepository>(value),
    );
  }
}

String _$hydrationRepositoryHash() =>
    r'c060ebf9cf9077820885cfc0c68cf31cac25fb9d';
