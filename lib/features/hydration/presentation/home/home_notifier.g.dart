// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the *write* half of `/home`: quick-add logging, the debounce
/// that collapses a rapid double-tap into one entry (`FR-039`), the
/// in-flight submit flag, and the transient success/failure feedback
/// the page turns into UI. The *read* half (today's live totals) is
/// `todayHydrationProvider` — see the workplan's Decisions log #3 for
/// why this is split rather than one Notifier holding both.

@ProviderFor(Home)
final homeProvider = HomeProvider._();

/// Owns the *write* half of `/home`: quick-add logging, the debounce
/// that collapses a rapid double-tap into one entry (`FR-039`), the
/// in-flight submit flag, and the transient success/failure feedback
/// the page turns into UI. The *read* half (today's live totals) is
/// `todayHydrationProvider` — see the workplan's Decisions log #3 for
/// why this is split rather than one Notifier holding both.
final class HomeProvider extends $NotifierProvider<Home, HomeState> {
  /// Owns the *write* half of `/home`: quick-add logging, the debounce
  /// that collapses a rapid double-tap into one entry (`FR-039`), the
  /// in-flight submit flag, and the transient success/failure feedback
  /// the page turns into UI. The *read* half (today's live totals) is
  /// `todayHydrationProvider` — see the workplan's Decisions log #3 for
  /// why this is split rather than one Notifier holding both.
  HomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeHash();

  @$internal
  @override
  Home create() => Home();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeHash() => r'eefd2af2ae0efff533789dbff4307248c3985c99';

/// Owns the *write* half of `/home`: quick-add logging, the debounce
/// that collapses a rapid double-tap into one entry (`FR-039`), the
/// in-flight submit flag, and the transient success/failure feedback
/// the page turns into UI. The *read* half (today's live totals) is
/// `todayHydrationProvider` — see the workplan's Decisions log #3 for
/// why this is split rather than one Notifier holding both.

abstract class _$Home extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
