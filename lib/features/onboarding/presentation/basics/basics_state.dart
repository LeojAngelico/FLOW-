import '../../../../core/result/failure.dart';

/// `ONB-03`'s screen-owned state: which fields have been **blurred**
/// and the error currently shown for each, per `05 ONB-03`'s "validate
/// on blur, not per keystroke." The answers themselves live on the
/// shared `OnboardingDraft` (`onboarding_draft_notifier.dart`) — this
/// state owns nothing the draft already owns.
class BasicsState {
  const BasicsState({
    this.ageTouched = false,
    this.nameTouched = false,
    this.ageError,
    this.nameError,
  });

  final bool ageTouched;
  final bool nameTouched;
  final ValidationFailure? ageError;
  final ValidationFailure? nameError;

  static const _unset = Object();

  BasicsState copyWith({
    bool? ageTouched,
    bool? nameTouched,
    Object? ageError = _unset,
    Object? nameError = _unset,
  }) {
    return BasicsState(
      ageTouched: ageTouched ?? this.ageTouched,
      nameTouched: nameTouched ?? this.nameTouched,
      ageError: identical(ageError, _unset)
          ? this.ageError
          : ageError as ValidationFailure?,
      nameError: identical(nameError, _unset)
          ? this.nameError
          : nameError as ValidationFailure?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BasicsState &&
        other.ageTouched == ageTouched &&
        other.nameTouched == nameTouched &&
        other.ageError == ageError &&
        other.nameError == nameError;
  }

  @override
  int get hashCode => Object.hash(ageTouched, nameTouched, ageError, nameError);

  @override
  String toString() =>
      'BasicsState(ageTouched: $ageTouched, nameTouched: $nameTouched, '
      'ageError: $ageError, nameError: $nameError)';
}
