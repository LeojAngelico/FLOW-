import '../../../../core/result/failure.dart';

/// `ONB-04`'s screen-owned state — [weightKg] is the last **valid**
/// value (used to position the slider and, once valid, written through
/// to the shared draft); [fieldText] is exactly what the text field
/// currently shows, which may be out of range or unparsable mid-edit.
/// Keeping the two separate is what lets a slider drag update the field
/// without a keystroke ever getting silently corrected back at the
/// consuming widget's next rebuild.
class WeightState {
  const WeightState({
    required this.weightKg,
    required this.fieldText,
    this.error,
  });

  final double weightKg;
  final String fieldText;
  final ValidationFailure? error;

  static const _unset = Object();

  WeightState copyWith({
    double? weightKg,
    String? fieldText,
    Object? error = _unset,
  }) {
    return WeightState(
      weightKg: weightKg ?? this.weightKg,
      fieldText: fieldText ?? this.fieldText,
      error: identical(error, _unset)
          ? this.error
          : error as ValidationFailure?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WeightState &&
        other.weightKg == weightKg &&
        other.fieldText == fieldText &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(weightKg, fieldText, error);

  @override
  String toString() =>
      'WeightState(weightKg: $weightKg, fieldText: $fieldText, error: $error)';
}
