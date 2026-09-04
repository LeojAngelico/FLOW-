import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../domain/models/hydration_entry.dart';
import '../../domain/providers/hydration_usecase_providers.dart';
import '../../domain/usecases/log_water.dart';
import 'add_water_state.dart';

part 'add_water_notifier.g.dart';

/// Owns `/home/add`'s custom-amount entry: the stepper/text-field/chip
/// amount, the >1,000ml confirm gate (`FR-024`), and the submit that
/// logs a `HydrationSource.custom` entry through the same [LogWater]
/// use case quick-add uses.
@riverpod
class AddWater extends _$AddWater {
  @override
  AddWaterState build() => const AddWaterState();

  /// Above this, [submit] requires a second confirmed call (`FR-024`'s
  /// large-amount confirm, `CPY-104`).
  static const _largeAmountThresholdMl = 1000;

  /// Steps the amount up by 50ml, clamped to [LogWater]'s own bound
  /// (`FR-024`). The initial unset `0` lands exactly on the floor
  /// anyway (`0 + 50 == LogWater.minAmountMl`), so no special case is
  /// needed for the first press.
  void increment() => _setAmount(_clampStepper(state.amountMl + 50));

  /// Steps the amount down by 50ml. The page is expected to disable the
  /// decrement `StepperButton` once `amountMl <= LogWater.minAmountMl`
  /// (matching the component's own "disabled at bounds" contract), so
  /// this floors defensively rather than assuming that's always true.
  void decrement() => _setAmount(_clampStepper(state.amountMl - 50));

  /// Direct numeric entry and the value-setting quick-amount chips both
  /// call this. Unlike the stepper, this allows the amount back down to
  /// `0` (e.g. clearing the text field mid-edit) — an out-of-range
  /// value here is a normal, submit-blocked in-between state, not an
  /// error; the domain still rejects anything below
  /// [LogWater.minAmountMl] if `submit()` were somehow reached with it.
  void setAmount(int value) {
    final clamped = value < 0
        ? 0
        : (value > LogWater.maxAmountMl ? LogWater.maxAmountMl : value);
    _setAmount(clamped);
  }

  void _setAmount(int amountMl) {
    state = state.copyWith(
      amountMl: amountMl,
      isDirty: amountMl != 0,
      // Changing the amount after a blocked large-amount confirm must
      // reset that gate — otherwise a second `submit()` call could
      // apply a stale confirmation to a *different*, unconfirmed
      // amount.
      needsLargeAmountConfirm: false,
      failure: null,
    );
  }

  int _clampStepper(int value) {
    if (value < LogWater.minAmountMl) return LogWater.minAmountMl;
    if (value > LogWater.maxAmountMl) return LogWater.maxAmountMl;
    return value;
  }

  /// Dismisses a pending large-amount confirm without submitting —
  /// called when the user cancels the `CPY-104` dialog.
  void dismissLargeAmountConfirm() {
    state = state.copyWith(needsLargeAmountConfirm: false);
  }

  /// Logs [AddWaterState.amountMl] as a `HydrationSource.custom` entry.
  ///
  /// Returns `true` only once the write actually succeeds. The page
  /// awaits this and pops on `true` itself — the notifier exposes
  /// state, the page navigates (`flutter-architecture-map` SKILL
  /// § Placement decisions).
  ///
  /// The first call past 1,000ml is intercepted: it flips
  /// [AddWaterState.needsLargeAmountConfirm] to `true` and returns
  /// `false` without writing anything, so the page can show the
  /// `CPY-104` confirm dialog. Calling [submit] again while that flag
  /// is already `true` — i.e. the user confirmed — proceeds with the
  /// write instead of blocking a second time.
  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final amountMl = state.amountMl;
    if (amountMl < LogWater.minAmountMl || amountMl > LogWater.maxAmountMl) {
      return false;
    }

    if (amountMl > _largeAmountThresholdMl && !state.needsLargeAmountConfirm) {
      state = state.copyWith(needsLargeAmountConfirm: true);
      return false;
    }

    state = state.copyWith(isSubmitting: true, failure: null);

    final result = await ref
        .read(logWaterProvider)
        .call(amountMl: amountMl, source: HydrationSource.custom);

    switch (result) {
      case Ok():
        state = state.copyWith(isSubmitting: false);
        return true;
      case Err(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          needsLargeAmountConfirm: false,
        );
        return false;
    }
  }
}
