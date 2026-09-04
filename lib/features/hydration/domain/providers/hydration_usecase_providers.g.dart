// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `occurredAt` is read from `clockProvider` here, at the usecase layer
/// — not in `hydrationRepositoryProvider` — because "now" is an
/// application-layer concern the caller supplies; the repository takes
/// `occurredAt` as a parameter and has no independent need for a clock.
/// Confirms the workplan's Decisions log #13.

@ProviderFor(logWater)
final logWaterProvider = LogWaterProvider._();

/// `occurredAt` is read from `clockProvider` here, at the usecase layer
/// — not in `hydrationRepositoryProvider` — because "now" is an
/// application-layer concern the caller supplies; the repository takes
/// `occurredAt` as a parameter and has no independent need for a clock.
/// Confirms the workplan's Decisions log #13.

final class LogWaterProvider
    extends $FunctionalProvider<LogWater, LogWater, LogWater>
    with $Provider<LogWater> {
  /// `occurredAt` is read from `clockProvider` here, at the usecase layer
  /// — not in `hydrationRepositoryProvider` — because "now" is an
  /// application-layer concern the caller supplies; the repository takes
  /// `occurredAt` as a parameter and has no independent need for a clock.
  /// Confirms the workplan's Decisions log #13.
  LogWaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logWaterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logWaterHash();

  @$internal
  @override
  $ProviderElement<LogWater> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogWater create(Ref ref) {
    return logWater(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogWater value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogWater>(value),
    );
  }
}

String _$logWaterHash() => r'cc67eb2779aa46bad4b98ca9857d0b86e8fb1e3f';

@ProviderFor(getTodayHydration)
final getTodayHydrationProvider = GetTodayHydrationProvider._();

final class GetTodayHydrationProvider
    extends
        $FunctionalProvider<
          GetTodayHydration,
          GetTodayHydration,
          GetTodayHydration
        >
    with $Provider<GetTodayHydration> {
  GetTodayHydrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getTodayHydrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getTodayHydrationHash();

  @$internal
  @override
  $ProviderElement<GetTodayHydration> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetTodayHydration create(Ref ref) {
    return getTodayHydration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTodayHydration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetTodayHydration>(value),
    );
  }
}

String _$getTodayHydrationHash() => r'252fd9b5e1486c4748143736577a4c05938e92c1';
