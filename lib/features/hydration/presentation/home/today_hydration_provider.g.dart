// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_hydration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The *read* half of `/home` — see `home_notifier.dart` for the write
/// half and the workplan's Decisions log #3 for why they're split
/// rather than one Notifier holding both.
///
/// Re-subscribes to [GetTodayHydration] whenever [todayProvider] changes
/// (local midnight rollover, `FR-034`, and the app resuming across a
/// suspended midnight via `TodayRefreshListener`), since
/// `GetTodayHydration.call` takes the local-calendar-date as a plain
/// parameter rather than tracking "today" itself.

@ProviderFor(todayHydration)
final todayHydrationProvider = TodayHydrationProvider._();

/// The *read* half of `/home` — see `home_notifier.dart` for the write
/// half and the workplan's Decisions log #3 for why they're split
/// rather than one Notifier holding both.
///
/// Re-subscribes to [GetTodayHydration] whenever [todayProvider] changes
/// (local midnight rollover, `FR-034`, and the app resuming across a
/// suspended midnight via `TodayRefreshListener`), since
/// `GetTodayHydration.call` takes the local-calendar-date as a plain
/// parameter rather than tracking "today" itself.

final class TodayHydrationProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayHydration>,
          TodayHydration,
          Stream<TodayHydration>
        >
    with $FutureModifier<TodayHydration>, $StreamProvider<TodayHydration> {
  /// The *read* half of `/home` — see `home_notifier.dart` for the write
  /// half and the workplan's Decisions log #3 for why they're split
  /// rather than one Notifier holding both.
  ///
  /// Re-subscribes to [GetTodayHydration] whenever [todayProvider] changes
  /// (local midnight rollover, `FR-034`, and the app resuming across a
  /// suspended midnight via `TodayRefreshListener`), since
  /// `GetTodayHydration.call` takes the local-calendar-date as a plain
  /// parameter rather than tracking "today" itself.
  TodayHydrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayHydrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHydrationHash();

  @$internal
  @override
  $StreamProviderElement<TodayHydration> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TodayHydration> create(Ref ref) {
    return todayHydration(ref);
  }
}

String _$todayHydrationHash() => r'9e000870bb30fdc4f6d5e532ee7905e10afe88d0';
