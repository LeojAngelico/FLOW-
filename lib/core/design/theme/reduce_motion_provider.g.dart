// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reduce_motion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
/// and consumed by every animated component, per 10-accessibility.md.
/// No animated component exists yet in this foundation pass, but the
/// provider is created now since it's a cross-cutting requirement every
/// future animation must plug into from day one.

@ProviderFor(ReduceMotion)
final reduceMotionProvider = ReduceMotionProvider._();

/// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
/// and consumed by every animated component, per 10-accessibility.md.
/// No animated component exists yet in this foundation pass, but the
/// provider is created now since it's a cross-cutting requirement every
/// future animation must plug into from day one.
final class ReduceMotionProvider extends $NotifierProvider<ReduceMotion, bool> {
  /// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
  /// and consumed by every animated component, per 10-accessibility.md.
  /// No animated component exists yet in this foundation pass, but the
  /// provider is created now since it's a cross-cutting requirement every
  /// future animation must plug into from day one.
  ReduceMotionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reduceMotionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reduceMotionHash();

  @$internal
  @override
  ReduceMotion create() => ReduceMotion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$reduceMotionHash() => r'620b88d03c1e8c4f6f58df572cfdffa03721afc1';

/// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
/// and consumed by every animated component, per 10-accessibility.md.
/// No animated component exists yet in this foundation pass, but the
/// provider is created now since it's a cross-cutting requirement every
/// future animation must plug into from day one.

abstract class _$ReduceMotion extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
