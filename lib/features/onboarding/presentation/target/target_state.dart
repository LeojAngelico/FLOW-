import '../../../../core/result/failure.dart';
import '../../../hydration/calculator/hydration_result.dart';

/// Whether `target_page.dart`'s `TargetHero` shows the read-only
/// suggestion, an editor the user hasn't touched yet, or one they have
/// actually adjusted. Distinct from `TargetHeroMode` (`core/design`),
/// which only knows "viewing" vs "editing" — this notifier's three
/// states additionally distinguish [editing] (Adjust tapped, nothing
/// changed yet) from [edited] (an actual stepper/slider interaction
/// happened), because only [edited] writes `manualTargetMl` to the
/// shared draft. That distinction is what keeps a user who taps Adjust
/// and immediately taps Continue — without changing anything — recorded
/// as `targetSource == suggested`, not `manual`.
enum TargetMode { suggested, editing, edited }

/// `ONB-07`'s screen-owned state.
class TargetState {
  const TargetState({
    this.mode = TargetMode.suggested,
    this.suggestion,
    this.draftTargetMl,
    this.failure,
  });

  final TargetMode mode;

  /// The calculator's output, computed once when this screen is first
  /// reached (`CalculateSuggestedTarget`, called from this notifier's
  /// `build()`). `null` only if [failure] is set.
  final SuggestedHydrationTarget? suggestion;

  /// The value currently shown by `TargetHero` while [mode] is
  /// [TargetMode.editing] or [TargetMode.edited]. `null` while
  /// [TargetMode.suggested].
  final int? draftTargetMl;

  /// Set only if the draft was incomplete when this screen was reached
  /// (a defensive case — the router should never allow it) or the write
  /// path fails; not the ordinary "please enter a value" path this
  /// screen has none of.
  final Failure? failure;

  static const _unset = Object();

  TargetState copyWith({
    TargetMode? mode,
    Object? suggestion = _unset,
    Object? draftTargetMl = _unset,
    Object? failure = _unset,
  }) {
    return TargetState(
      mode: mode ?? this.mode,
      suggestion: identical(suggestion, _unset)
          ? this.suggestion
          : suggestion as SuggestedHydrationTarget?,
      draftTargetMl: identical(draftTargetMl, _unset)
          ? this.draftTargetMl
          : draftTargetMl as int?,
      failure: identical(failure, _unset) ? this.failure : failure as Failure?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TargetState &&
        other.mode == mode &&
        other.suggestion == suggestion &&
        other.draftTargetMl == draftTargetMl &&
        other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(mode, suggestion, draftTargetMl, failure);

  @override
  String toString() =>
      'TargetState(mode: $mode, draftTargetMl: $draftTargetMl, '
      'failure: $failure)';
}
