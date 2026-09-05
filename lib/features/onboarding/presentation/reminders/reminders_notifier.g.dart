// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `ONB-08`'s screen-owned state: the window/interval/weekday mutators
/// (all write straight through to the shared draft's
/// `ReminderPreferences`), the `end > start` validation (`CPY-122`), and
/// **the final write** — both Skip and the CTA call [submit].

@ProviderFor(RemindersNotifier)
final remindersProvider = RemindersNotifierProvider._();

/// `ONB-08`'s screen-owned state: the window/interval/weekday mutators
/// (all write straight through to the shared draft's
/// `ReminderPreferences`), the `end > start` validation (`CPY-122`), and
/// **the final write** — both Skip and the CTA call [submit].
final class RemindersNotifierProvider
    extends $NotifierProvider<RemindersNotifier, RemindersState> {
  /// `ONB-08`'s screen-owned state: the window/interval/weekday mutators
  /// (all write straight through to the shared draft's
  /// `ReminderPreferences`), the `end > start` validation (`CPY-122`), and
  /// **the final write** — both Skip and the CTA call [submit].
  RemindersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remindersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remindersNotifierHash();

  @$internal
  @override
  RemindersNotifier create() => RemindersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemindersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemindersState>(value),
    );
  }
}

String _$remindersNotifierHash() => r'81fee3ec1609a6c0f165852d88ac38c5d45c7aeb';

/// `ONB-08`'s screen-owned state: the window/interval/weekday mutators
/// (all write straight through to the shared draft's
/// `ReminderPreferences`), the `end > start` validation (`CPY-122`), and
/// **the final write** — both Skip and the CTA call [submit].

abstract class _$RemindersNotifier extends $Notifier<RemindersState> {
  RemindersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RemindersState, RemindersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RemindersState, RemindersState>,
              RemindersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
