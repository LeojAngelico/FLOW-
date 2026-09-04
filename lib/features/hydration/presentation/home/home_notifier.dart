import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../domain/models/hydration_entry.dart';
import '../../domain/providers/hydration_usecase_providers.dart';
import 'home_state.dart';

part 'home_notifier.g.dart';

/// Owns the *write* half of `/home`: quick-add logging, the debounce
/// that collapses a rapid double-tap into one entry (`FR-039`), the
/// in-flight submit flag, and the transient success/failure feedback
/// the page turns into UI. The *read* half (today's live totals) is
/// `todayHydrationProvider` — see the workplan's Decisions log #3 for
/// why this is split rather than one Notifier holding both.
@riverpod
class Home extends _$Home {
  @override
  HomeState build() => const HomeState();

  /// `FR-039`'s debounce window. Wide enough to collapse an accidental
  /// rapid double-tap on the same chip into one entry; narrow enough
  /// that two genuinely separate taps roughly a second apart both land
  /// (see the workplan's Manual QA item 2 — only a human can judge
  /// whether 300ms feels right).
  static const _debounceWindow = Duration(milliseconds: 300);

  DateTime? _lastQuickAddAt;

  /// Logs [amountMl] as a `HydrationSource.quickAdd` entry.
  ///
  /// Two independent guards prevent a duplicate write from one tap
  /// gesture: [HomeState.isSubmitting] blocks a second call while the
  /// first is still in flight (a real async race), and the debounce
  /// window above blocks a second call that *starts* too soon after the
  /// last one started (a UI-level double-tap, which could otherwise
  /// slip through between the first call's `await` points).
  Future<void> quickAdd(int amountMl) async {
    if (state.isSubmitting) return;

    final now = DateTime.now();
    final lastAt = _lastQuickAddAt;
    if (lastAt != null && now.difference(lastAt) < _debounceWindow) {
      return;
    }
    _lastQuickAddAt = now;

    state = state.copyWith(isSubmitting: true, writeFailure: null);

    final result = await ref
        .read(logWaterProvider)
        .call(amountMl: amountMl, source: HydrationSource.quickAdd);

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          isSubmitting: false,
          lastLogged: value,
          writeFailure: null,
        );
        break;
      case Err(:final failure):
        state = state.copyWith(isSubmitting: false, writeFailure: failure);
    }
  }
}
