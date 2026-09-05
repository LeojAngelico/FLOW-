import '../../../../core/result/failure.dart';

/// State for `/home/add`'s custom-amount entry, owned by
/// `add_water_notifier.dart`.
class AddWaterState {
  const AddWaterState({
    this.amountMl = 0,
    this.needsLargeAmountConfirm = false,
    this.isSubmitting = false,
    this.failure,
    this.isDirty = false,
  });

  /// The amount currently entered. `0` means nothing has been chosen
  /// yet — the `Log Water` CTA stays disabled below
  /// `LogWater.minAmountMl` (`FR-024`), which includes but is not
  /// limited to exactly `0`.
  final int amountMl;

  /// `true` once [amountMl] exceeded 1,000ml and a call to `submit()`
  /// was blocked pending confirmation (`FR-024`'s large-amount confirm,
  /// `CPY-104`). A second `submit()` call while this is already `true`
  /// proceeds instead of blocking again — see `add_water_notifier.dart`.
  final bool needsLargeAmountConfirm;

  final bool isSubmitting;

  /// Set when the most recent submit attempt failed.
  final Failure? failure;

  /// `true` once [amountMl] has changed from its initial `0` — drives
  /// the discard-on-back confirm (`CPY-108`).
  final bool isDirty;

  static const _unset = Object();

  AddWaterState copyWith({
    int? amountMl,
    bool? needsLargeAmountConfirm,
    bool? isSubmitting,
    Object? failure = _unset,
    bool? isDirty,
  }) {
    return AddWaterState(
      amountMl: amountMl ?? this.amountMl,
      needsLargeAmountConfirm:
          needsLargeAmountConfirm ?? this.needsLargeAmountConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: identical(failure, _unset) ? this.failure : failure as Failure?,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddWaterState &&
        other.amountMl == amountMl &&
        other.needsLargeAmountConfirm == needsLargeAmountConfirm &&
        other.isSubmitting == isSubmitting &&
        other.failure == failure &&
        other.isDirty == isDirty;
  }

  @override
  int get hashCode => Object.hash(
    amountMl,
    needsLargeAmountConfirm,
    isSubmitting,
    failure,
    isDirty,
  );

  @override
  String toString() =>
      'AddWaterState(amountMl: $amountMl, needsLargeAmountConfirm: '
      '$needsLargeAmountConfirm, isSubmitting: $isSubmitting, failure: '
      '$failure, isDirty: $isDirty)';
}
