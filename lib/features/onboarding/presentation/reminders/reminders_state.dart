import '../../../../core/result/failure.dart';

/// `ONB-08`'s screen-owned state. The window/interval/weekday values
/// themselves live on the shared draft's `ReminderPreferences`
/// (`onboarding_draft_notifier.dart`) — this state owns only the
/// submission lifecycle and the window's validity.
class RemindersState {
  const RemindersState({
    this.isSubmitting = false,
    this.windowError,
    this.submitFailure,
  });

  final bool isSubmitting;

  /// Set whenever `end <= start` (`CPY-122`) — disables the CTA. `null`
  /// once the window is valid again.
  final ValidationFailure? windowError;

  /// Set when `CompleteOnboarding` returns an `Err` — rendered inline;
  /// the draft and every answer stay intact so the user can retry
  /// without redoing the flow.
  final Failure? submitFailure;

  static const _unset = Object();

  RemindersState copyWith({
    bool? isSubmitting,
    Object? windowError = _unset,
    Object? submitFailure = _unset,
  }) {
    return RemindersState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      windowError: identical(windowError, _unset)
          ? this.windowError
          : windowError as ValidationFailure?,
      submitFailure: identical(submitFailure, _unset)
          ? this.submitFailure
          : submitFailure as Failure?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemindersState &&
        other.isSubmitting == isSubmitting &&
        other.windowError == windowError &&
        other.submitFailure == submitFailure;
  }

  @override
  int get hashCode => Object.hash(isSubmitting, windowError, submitFailure);

  @override
  String toString() =>
      'RemindersState(isSubmitting: $isSubmitting, windowError: '
      '$windowError, submitFailure: $submitFailure)';
}
