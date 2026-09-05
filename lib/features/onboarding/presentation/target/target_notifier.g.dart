// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `ONB-07`'s screen-owned state: the suggested/editing/edited
/// transition (`TargetMode`), the ±50ml stepper and slider, and the
/// revert-to-suggested action.
///
/// Calls `CalculateSuggestedTarget` exactly once, in [build] — not on
/// every rebuild — matching the file plan's "calls it once when the
/// screen is first reached." If [OnboardingDraft.manualTargetMl] is
/// already set (the user adjusted it, went back, and returned),
/// [build] restores [TargetMode.edited] rather than resetting to the
/// suggestion, so Back/Forward preserves the edit (`FR-018`).

@ProviderFor(TargetNotifier)
final targetProvider = TargetNotifierProvider._();

/// `ONB-07`'s screen-owned state: the suggested/editing/edited
/// transition (`TargetMode`), the ±50ml stepper and slider, and the
/// revert-to-suggested action.
///
/// Calls `CalculateSuggestedTarget` exactly once, in [build] — not on
/// every rebuild — matching the file plan's "calls it once when the
/// screen is first reached." If [OnboardingDraft.manualTargetMl] is
/// already set (the user adjusted it, went back, and returned),
/// [build] restores [TargetMode.edited] rather than resetting to the
/// suggestion, so Back/Forward preserves the edit (`FR-018`).
final class TargetNotifierProvider
    extends $NotifierProvider<TargetNotifier, TargetState> {
  /// `ONB-07`'s screen-owned state: the suggested/editing/edited
  /// transition (`TargetMode`), the ±50ml stepper and slider, and the
  /// revert-to-suggested action.
  ///
  /// Calls `CalculateSuggestedTarget` exactly once, in [build] — not on
  /// every rebuild — matching the file plan's "calls it once when the
  /// screen is first reached." If [OnboardingDraft.manualTargetMl] is
  /// already set (the user adjusted it, went back, and returned),
  /// [build] restores [TargetMode.edited] rather than resetting to the
  /// suggestion, so Back/Forward preserves the edit (`FR-018`).
  TargetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'targetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$targetNotifierHash();

  @$internal
  @override
  TargetNotifier create() => TargetNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TargetState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TargetState>(value),
    );
  }
}

String _$targetNotifierHash() => r'7a8b45a422abc0400231855238a076f7551cec4c';

/// `ONB-07`'s screen-owned state: the suggested/editing/edited
/// transition (`TargetMode`), the ±50ml stepper and slider, and the
/// revert-to-suggested action.
///
/// Calls `CalculateSuggestedTarget` exactly once, in [build] — not on
/// every rebuild — matching the file plan's "calls it once when the
/// screen is first reached." If [OnboardingDraft.manualTargetMl] is
/// already set (the user adjusted it, went back, and returned),
/// [build] restores [TargetMode.edited] rather than resetting to the
/// suggestion, so Back/Forward preserves the edit (`FR-018`).

abstract class _$TargetNotifier extends $Notifier<TargetState> {
  TargetState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TargetState, TargetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TargetState, TargetState>,
              TargetState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
