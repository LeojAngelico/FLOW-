// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basics_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `ONB-03`'s screen-owned state: which fields have been blurred and
/// the currently-shown error for each (`05 ONB-03`: validate on blur,
/// not per keystroke). Writes every change straight through to the
/// shared [OnboardingDraftNotifier] — the bounds themselves live in
/// [OnboardingRules], never here.

@ProviderFor(BasicsNotifier)
final basicsProvider = BasicsNotifierProvider._();

/// `ONB-03`'s screen-owned state: which fields have been blurred and
/// the currently-shown error for each (`05 ONB-03`: validate on blur,
/// not per keystroke). Writes every change straight through to the
/// shared [OnboardingDraftNotifier] — the bounds themselves live in
/// [OnboardingRules], never here.
final class BasicsNotifierProvider
    extends $NotifierProvider<BasicsNotifier, BasicsState> {
  /// `ONB-03`'s screen-owned state: which fields have been blurred and
  /// the currently-shown error for each (`05 ONB-03`: validate on blur,
  /// not per keystroke). Writes every change straight through to the
  /// shared [OnboardingDraftNotifier] — the bounds themselves live in
  /// [OnboardingRules], never here.
  BasicsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'basicsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$basicsNotifierHash();

  @$internal
  @override
  BasicsNotifier create() => BasicsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BasicsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BasicsState>(value),
    );
  }
}

String _$basicsNotifierHash() => r'e4e14d5e18a66c075ea68c4f5d8a37092862ff07';

/// `ONB-03`'s screen-owned state: which fields have been blurred and
/// the currently-shown error for each (`05 ONB-03`: validate on blur,
/// not per keystroke). Writes every change straight through to the
/// shared [OnboardingDraftNotifier] — the bounds themselves live in
/// [OnboardingRules], never here.

abstract class _$BasicsNotifier extends $Notifier<BasicsState> {
  BasicsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BasicsState, BasicsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BasicsState, BasicsState>,
              BasicsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
