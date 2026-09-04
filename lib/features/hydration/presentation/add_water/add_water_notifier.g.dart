// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_water_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns `/home/add`'s custom-amount entry: the stepper/text-field/chip
/// amount, the >1,000ml confirm gate (`FR-024`), and the submit that
/// logs a `HydrationSource.custom` entry through the same [LogWater]
/// use case quick-add uses.

@ProviderFor(AddWater)
final addWaterProvider = AddWaterProvider._();

/// Owns `/home/add`'s custom-amount entry: the stepper/text-field/chip
/// amount, the >1,000ml confirm gate (`FR-024`), and the submit that
/// logs a `HydrationSource.custom` entry through the same [LogWater]
/// use case quick-add uses.
final class AddWaterProvider
    extends $NotifierProvider<AddWater, AddWaterState> {
  /// Owns `/home/add`'s custom-amount entry: the stepper/text-field/chip
  /// amount, the >1,000ml confirm gate (`FR-024`), and the submit that
  /// logs a `HydrationSource.custom` entry through the same [LogWater]
  /// use case quick-add uses.
  AddWaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addWaterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addWaterHash();

  @$internal
  @override
  AddWater create() => AddWater();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddWaterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddWaterState>(value),
    );
  }
}

String _$addWaterHash() => r'0b54a0f0012c08c45b82934be5bfadb775526412';

/// Owns `/home/add`'s custom-amount entry: the stepper/text-field/chip
/// amount, the >1,000ml confirm gate (`FR-024`), and the submit that
/// logs a `HydrationSource.custom` entry through the same [LogWater]
/// use case quick-add uses.

abstract class _$AddWater extends $Notifier<AddWaterState> {
  AddWaterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddWaterState, AddWaterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddWaterState, AddWaterState>,
              AddWaterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
