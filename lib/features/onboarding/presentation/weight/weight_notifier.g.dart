// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `ONB-04`'s screen-owned state: keeps the typed text and the slider
/// in sync. The hard part this notifier solves: a slider drag must not
/// fight a partially-typed field. [WeightState.fieldText] only ever
/// changes from an explicit slider commit or an explicit keystroke —
/// never recomputed from [WeightState.weightKg] on every rebuild — so a
/// keystroke is never silently overwritten mid-edit.

@ProviderFor(WeightNotifier)
final weightProvider = WeightNotifierProvider._();

/// `ONB-04`'s screen-owned state: keeps the typed text and the slider
/// in sync. The hard part this notifier solves: a slider drag must not
/// fight a partially-typed field. [WeightState.fieldText] only ever
/// changes from an explicit slider commit or an explicit keystroke —
/// never recomputed from [WeightState.weightKg] on every rebuild — so a
/// keystroke is never silently overwritten mid-edit.
final class WeightNotifierProvider
    extends $NotifierProvider<WeightNotifier, WeightState> {
  /// `ONB-04`'s screen-owned state: keeps the typed text and the slider
  /// in sync. The hard part this notifier solves: a slider drag must not
  /// fight a partially-typed field. [WeightState.fieldText] only ever
  /// changes from an explicit slider commit or an explicit keystroke —
  /// never recomputed from [WeightState.weightKg] on every rebuild — so a
  /// keystroke is never silently overwritten mid-edit.
  WeightNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightNotifierHash();

  @$internal
  @override
  WeightNotifier create() => WeightNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightState>(value),
    );
  }
}

String _$weightNotifierHash() => r'baeacf5eecfba4168920f1685891e89466b8f1b5';

/// `ONB-04`'s screen-owned state: keeps the typed text and the slider
/// in sync. The hard part this notifier solves: a slider drag must not
/// fight a partially-typed field. [WeightState.fieldText] only ever
/// changes from an explicit slider commit or an explicit keystroke —
/// never recomputed from [WeightState.weightKg] on every rebuild — so a
/// keystroke is never silently overwritten mid-edit.

abstract class _$WeightNotifier extends $Notifier<WeightState> {
  WeightState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WeightState, WeightState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeightState, WeightState>,
              WeightState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
