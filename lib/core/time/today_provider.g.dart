// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's local-calendar-date (`'YYYY-MM-DD'`), reactive across local
/// midnight while the app stays foregrounded (`FR-034`).
///
/// Reads "now" from [clockProvider] (so the dev-flavor clock override
/// changes what "today" resolves to) but schedules its own `Timer`
/// against real wall-clock time to the next local midnight, at which
/// point it calls [Ref.invalidateSelf] so every watcher recomputes.
/// `Timer`s are not guaranteed to fire while the process is suspended,
/// so this alone does not cover the app being backgrounded across
/// midnight — see `today_refresh_listener.dart` for that half.

@ProviderFor(today)
final todayProvider = TodayProvider._();

/// Today's local-calendar-date (`'YYYY-MM-DD'`), reactive across local
/// midnight while the app stays foregrounded (`FR-034`).
///
/// Reads "now" from [clockProvider] (so the dev-flavor clock override
/// changes what "today" resolves to) but schedules its own `Timer`
/// against real wall-clock time to the next local midnight, at which
/// point it calls [Ref.invalidateSelf] so every watcher recomputes.
/// `Timer`s are not guaranteed to fire while the process is suspended,
/// so this alone does not cover the app being backgrounded across
/// midnight — see `today_refresh_listener.dart` for that half.

final class TodayProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Today's local-calendar-date (`'YYYY-MM-DD'`), reactive across local
  /// midnight while the app stays foregrounded (`FR-034`).
  ///
  /// Reads "now" from [clockProvider] (so the dev-flavor clock override
  /// changes what "today" resolves to) but schedules its own `Timer`
  /// against real wall-clock time to the next local midnight, at which
  /// point it calls [Ref.invalidateSelf] so every watcher recomputes.
  /// `Timer`s are not guaranteed to fire while the process is suspended,
  /// so this alone does not cover the app being backgrounded across
  /// midnight — see `today_refresh_listener.dart` for that half.
  TodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return today(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$todayHash() => r'60cb37a8c74d254580a244aefd7885367a0db82d';
