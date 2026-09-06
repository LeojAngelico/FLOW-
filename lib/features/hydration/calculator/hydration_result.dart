/// `08 §6.1`'s output contract, returned by `HydrationCalculator.calculate`
/// (`hydration_calculator.dart`).
///
/// Every string field here — [SuggestedHydrationTarget.calculationMethodId],
/// [SuggestedHydrationTarget.methodId], [SuggestedHydrationTarget.assumptions],
/// [SuggestedHydrationTarget.disclaimer] and [BreakdownLine.labelId] — is an
/// **id**, never English prose. `07 §5` forbids this directory from
/// importing Flutter, and localized strings only exist behind
/// `AppLocalizations`; prose in a pure Dart class would bypass l10n
/// permanently. The (not-yet-built) `calculation_method_sheet.dart`
/// (`presentation/target/widgets/`) is the one place these ids are
/// mapped to ARB keys. See
/// `docs/workplans/2026-09-05-onboarding.md` Decisions #7.
class SuggestedHydrationTarget {
  const SuggestedHydrationTarget({
    required this.amountMl,
    required this.amountLiters,
    required this.calculationMethodId,
    required this.methodId,
    required this.breakdown,
    required this.assumptions,
    required this.disclaimer,
    required this.requiresProfessionalNotice,
  });

  /// The drinking-water target, rounded to the nearest 100 ml and
  /// clamped (`08 §6.2` step 6). This is what gets written to
  /// `user_profiles.daily_target_ml` when the suggestion is accepted
  /// verbatim.
  final int amountMl;

  /// [amountMl] / 1000 — `ONB-07`'s "2.0 L" readout.
  final double amountLiters;

  /// An id for the calculation method's **display name** (e.g. a
  /// localized "Reference daily intake" label rendered in `OVL-10`) —
  /// distinct from [methodId], the raw machine id persisted to storage.
  /// For `ReferenceIntakeV1` the two ids happen to share the same
  /// underlying string today; they are separate fields because a future
  /// method could localize a friendlier display name while keeping a
  /// stable storage id, or vice versa.
  final String calculationMethodId;

  /// e.g. `'reference_intake_v1'` — written verbatim to
  /// `user_profiles.calculator_method_id` (`07 §5` traceability). Always
  /// read from [HydrationCalculator.methodId], never hand-typed.
  final String methodId;

  /// Renders `OVL-10` (`FR-012`). See [BreakdownLine] for what each
  /// entry means.
  final List<BreakdownLine> breakdown;

  /// Ids mapped to `CPY-084`–`CPY-088` (Decisions #7) — e.g. the
  /// `FOOD_WATER_FRACTION` disclosure, and, only when applicable, a line
  /// stating that the weight adjustment or the final result was
  /// clamped.
  final List<String> assumptions;

  /// A single id mapped to the calculator's disclaimer copy, rendered on
  /// both `ONB-07` and `OVL-10`.
  final String disclaimer;

  /// `true` iff `specialCircumstances` was non-empty (`08 §6.2` step 7)
  /// — drives `CPY-070`'s professional-notice banner on `ONB-07`
  /// (`FR-011`). The number is still produced either way: FLOW informs,
  /// it does not block.
  final bool requiresProfessionalNotice;

  SuggestedHydrationTarget copyWith({
    int? amountMl,
    double? amountLiters,
    String? calculationMethodId,
    String? methodId,
    List<BreakdownLine>? breakdown,
    List<String>? assumptions,
    String? disclaimer,
    bool? requiresProfessionalNotice,
  }) {
    return SuggestedHydrationTarget(
      amountMl: amountMl ?? this.amountMl,
      amountLiters: amountLiters ?? this.amountLiters,
      calculationMethodId: calculationMethodId ?? this.calculationMethodId,
      methodId: methodId ?? this.methodId,
      breakdown: breakdown ?? this.breakdown,
      assumptions: assumptions ?? this.assumptions,
      disclaimer: disclaimer ?? this.disclaimer,
      requiresProfessionalNotice:
          requiresProfessionalNotice ?? this.requiresProfessionalNotice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! SuggestedHydrationTarget) return false;
    if (other.amountMl != amountMl) return false;
    if (other.amountLiters != amountLiters) return false;
    if (other.calculationMethodId != calculationMethodId) return false;
    if (other.methodId != methodId) return false;
    if (other.disclaimer != disclaimer) return false;
    if (other.requiresProfessionalNotice != requiresProfessionalNotice) {
      return false;
    }
    if (other.breakdown.length != breakdown.length) return false;
    for (var i = 0; i < breakdown.length; i++) {
      if (other.breakdown[i] != breakdown[i]) return false;
    }
    if (other.assumptions.length != assumptions.length) return false;
    for (var i = 0; i < assumptions.length; i++) {
      if (other.assumptions[i] != assumptions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    amountMl,
    amountLiters,
    calculationMethodId,
    methodId,
    Object.hashAll(breakdown),
    Object.hashAll(assumptions),
    disclaimer,
    requiresProfessionalNotice,
  );

  @override
  String toString() =>
      'SuggestedHydrationTarget(amountMl: $amountMl, methodId: $methodId, '
      'requiresProfessionalNotice: $requiresProfessionalNotice)';
}

/// One line of `OVL-10`'s breakdown.
///
/// [labelId] is an id, not prose — see [SuggestedHydrationTarget]'s doc
/// comment. [labelArg] carries a second id (an enum's `.name`, e.g.
/// `'light'`) for lines whose label interpolates a value, e.g.
/// "Activity (Lightly active)"; `null` for lines that don't.
///
/// [isSubtotal] lines (running totals like "Total water" or "Drinking
/// target") are for display only. A test asserting that the breakdown's
/// deltas sum to the pre-rounding drinking total must exclude them, or
/// the total gets counted twice.
class BreakdownLine {
  const BreakdownLine({
    required this.labelId,
    this.labelArg,
    required this.deltaMl,
    this.isSubtotal = false,
  });

  final String labelId;

  final String? labelArg;

  /// Signed — negative for the food-water deduction.
  final int deltaMl;

  final bool isSubtotal;

  static const _unset = Object();

  BreakdownLine copyWith({
    String? labelId,
    Object? labelArg = _unset,
    int? deltaMl,
    bool? isSubtotal,
  }) {
    return BreakdownLine(
      labelId: labelId ?? this.labelId,
      labelArg: identical(labelArg, _unset)
          ? this.labelArg
          : labelArg as String?,
      deltaMl: deltaMl ?? this.deltaMl,
      isSubtotal: isSubtotal ?? this.isSubtotal,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BreakdownLine &&
        other.labelId == labelId &&
        other.labelArg == labelArg &&
        other.deltaMl == deltaMl &&
        other.isSubtotal == isSubtotal;
  }

  @override
  int get hashCode => Object.hash(labelId, labelArg, deltaMl, isSubtotal);

  @override
  String toString() =>
      'BreakdownLine(labelId: $labelId, labelArg: $labelArg, '
      'deltaMl: $deltaMl, isSubtotal: $isSubtotal)';
}
