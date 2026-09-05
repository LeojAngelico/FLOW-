import '../../../../core/result/failure.dart';
import '../../domain/models/logged_water.dart';

/// State for `/home`'s *write* half, owned by `home_notifier.dart`. The
/// live totals shown on the page come from `todayHydrationProvider`
/// instead — this state only covers the transient, in-flight-write
/// concerns a stream can't represent.
class HomeState {
  const HomeState({this.isSubmitting = false, this.lastLogged, this.writeFailure});

  /// True while a quick-add write is in flight — guards against a
  /// duplicate submission (alongside the notifier's own debounce).
  final bool isSubmitting;

  /// The most recent successful write. The page reads this for
  /// transient success feedback (`CPY-106`'s "+{amount}" and the
  /// summary's live-region announcement) — never cleared back to
  /// `null`, since there is nothing meaningful to revert it to; the
  /// page reacts to it *changing*, not to it being non-null.
  final LoggedWater? lastLogged;

  /// Set when the most recent write failed (APP-01 `writeError` state).
  /// The *displayed total* must stay unchanged when this is set — that
  /// invariant lives entirely in `todayHydrationProvider`, which this
  /// state has no effect on.
  final Failure? writeFailure;

  static const _unset = Object();

  HomeState copyWith({
    bool? isSubmitting,
    LoggedWater? lastLogged,
    Object? writeFailure = _unset,
  }) {
    return HomeState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastLogged: lastLogged ?? this.lastLogged,
      writeFailure: identical(writeFailure, _unset)
          ? this.writeFailure
          : writeFailure as Failure?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeState &&
        other.isSubmitting == isSubmitting &&
        other.lastLogged == lastLogged &&
        other.writeFailure == writeFailure;
  }

  @override
  int get hashCode => Object.hash(isSubmitting, lastLogged, writeFailure);

  @override
  String toString() =>
      'HomeState(isSubmitting: $isSubmitting, lastLogged: $lastLogged, '
      'writeFailure: $writeFailure)';
}
