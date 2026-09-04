// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Only meaningful in the `dev` flavor — lets a future debug UI move
/// the app's clock forward/backward to test streaks, reminders, and
/// day-rollover logic without waiting in real time.

@ProviderFor(ClockOverride)
final clockOverrideProvider = ClockOverrideProvider._();

/// Only meaningful in the `dev` flavor — lets a future debug UI move
/// the app's clock forward/backward to test streaks, reminders, and
/// day-rollover logic without waiting in real time.
final class ClockOverrideProvider
    extends $NotifierProvider<ClockOverride, DateTime?> {
  /// Only meaningful in the `dev` flavor — lets a future debug UI move
  /// the app's clock forward/backward to test streaks, reminders, and
  /// day-rollover logic without waiting in real time.
  ClockOverrideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockOverrideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockOverrideHash();

  @$internal
  @override
  ClockOverride create() => ClockOverride();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$clockOverrideHash() => r'4ec29ab49581b90956407eb3216e7e6d783b3510';

/// Only meaningful in the `dev` flavor — lets a future debug UI move
/// the app's clock forward/backward to test streaks, reminders, and
/// day-rollover logic without waiting in real time.

abstract class _$ClockOverride extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'2cf25f7e7a50c45986c0cd2504029d5e4ac1dbe9';
