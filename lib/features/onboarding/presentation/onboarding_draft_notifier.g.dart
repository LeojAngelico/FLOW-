// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The shared, `keepAlive` draft that survives Back and Forward across
/// all six answer screens (`FR-018`) — see the workplan's Decisions #3.
/// State **is** the domain [OnboardingDraft]; there is no separate
/// `onboarding_draft_state.dart` because the domain model already is the
/// state. Every screen writes through exactly one mutator here rather
/// than keeping its own copy of an answer.
///
/// `keepAlive` is load-bearing, not a convenience: an `autoDispose`
/// provider is torn down while no screen watches it during a route
/// transition, which would silently drop the draft on the first Back
/// and fail `FR-018` in a way that only shows up on a real device.

@ProviderFor(OnboardingDraftNotifier)
final onboardingDraftProvider = OnboardingDraftNotifierProvider._();

/// The shared, `keepAlive` draft that survives Back and Forward across
/// all six answer screens (`FR-018`) — see the workplan's Decisions #3.
/// State **is** the domain [OnboardingDraft]; there is no separate
/// `onboarding_draft_state.dart` because the domain model already is the
/// state. Every screen writes through exactly one mutator here rather
/// than keeping its own copy of an answer.
///
/// `keepAlive` is load-bearing, not a convenience: an `autoDispose`
/// provider is torn down while no screen watches it during a route
/// transition, which would silently drop the draft on the first Back
/// and fail `FR-018` in a way that only shows up on a real device.
final class OnboardingDraftNotifierProvider
    extends $NotifierProvider<OnboardingDraftNotifier, OnboardingDraft> {
  /// The shared, `keepAlive` draft that survives Back and Forward across
  /// all six answer screens (`FR-018`) — see the workplan's Decisions #3.
  /// State **is** the domain [OnboardingDraft]; there is no separate
  /// `onboarding_draft_state.dart` because the domain model already is the
  /// state. Every screen writes through exactly one mutator here rather
  /// than keeping its own copy of an answer.
  ///
  /// `keepAlive` is load-bearing, not a convenience: an `autoDispose`
  /// provider is torn down while no screen watches it during a route
  /// transition, which would silently drop the draft on the first Back
  /// and fail `FR-018` in a way that only shows up on a real device.
  OnboardingDraftNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingDraftNotifierHash();

  @$internal
  @override
  OnboardingDraftNotifier create() => OnboardingDraftNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingDraft>(value),
    );
  }
}

String _$onboardingDraftNotifierHash() =>
    r'd6dfdb312053867515647de61008a15c00f05a9a';

/// The shared, `keepAlive` draft that survives Back and Forward across
/// all six answer screens (`FR-018`) — see the workplan's Decisions #3.
/// State **is** the domain [OnboardingDraft]; there is no separate
/// `onboarding_draft_state.dart` because the domain model already is the
/// state. Every screen writes through exactly one mutator here rather
/// than keeping its own copy of an answer.
///
/// `keepAlive` is load-bearing, not a convenience: an `autoDispose`
/// provider is torn down while no screen watches it during a route
/// transition, which would silently drop the draft on the first Back
/// and fail `FR-018` in a way that only shows up on a real device.

abstract class _$OnboardingDraftNotifier extends $Notifier<OnboardingDraft> {
  OnboardingDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingDraft, OnboardingDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingDraft, OnboardingDraft>,
              OnboardingDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
