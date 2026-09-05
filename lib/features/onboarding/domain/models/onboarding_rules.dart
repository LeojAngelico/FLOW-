import '../../../../core/result/failure.dart';

/// The bounds and boundary validators for every onboarding answer
/// (`FR-003`–`FR-010`, `FR-014`, `FR-015`). Pure functions returning a
/// typed [ValidationFailure] rather than throwing, so a bypassed UI is
/// rejected the same way a properly-guarded one would be — see
/// `docs/workplans/2026-09-05-onboarding.md` § Acceptance criteria
/// ("rejected again by the domain if the UI is bypassed").
///
/// Bounds are public `static const`s — `basics_notifier.dart`,
/// `weight_notifier.dart`, `target_notifier.dart` and
/// `reminders_notifier.dart` clamp to these same numbers rather than
/// re-typing them, the `LogWater.minAmountMl` precedent.
class OnboardingRules {
  OnboardingRules._();

  /// `FR-003` — trimmed, optional.
  static const maxDisplayNameLength = 24;

  /// `FR-004`.
  static const minAge = 9;

  /// `FR-004`.
  static const maxAge = 120;

  /// `FR-006`, kilograms.
  static const minWeightKg = 25.0;

  /// `FR-006`, kilograms.
  static const maxWeightKg = 250.0;

  /// `FR-014` manual-target lower bound, ml.
  static const minTargetMl = 500;

  /// `FR-014` manual-target upper bound, ml.
  static const maxTargetMl = 4000;

  /// `FR-014` — above this, `CPY-074`'s caution shows. This never
  /// blocks; see [isHighTarget].
  static const highTargetThresholdMl = 3500;

  /// Trims [value] first, so whitespace-only input is treated as the
  /// empty, valid answer `FR-003` allows. Counts **runes**, not UTF-16
  /// code units — a name made of two 4-byte emoji is 2 runes, not 4, and
  /// counting code units would reject it before the real 24-character
  /// limit.
  static ValidationFailure? validateDisplayName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.runes.length > maxDisplayNameLength) {
      return ValidationFailure(
        'displayName',
        'Name must be $maxDisplayNameLength characters or fewer.',
      );
    }
    return null;
  }

  /// `FR-004` — 9 to 120 inclusive.
  static ValidationFailure? validateAge(int age) {
    if (age < minAge || age > maxAge) {
      return ValidationFailure(
        'age',
        'Enter an age between $minAge and $maxAge.',
      );
    }
    return null;
  }

  /// `FR-006` — 25.0 to 250.0 kg inclusive. Range only: rounding to one
  /// decimal is a formatting concern owned by `weight_notifier.dart` and,
  /// defensively, `user_profile_mapper.dart` — not re-checked here,
  /// because a value like `68.05` is already within bounds and simply
  /// gets rounded before it is ever persisted.
  static ValidationFailure? validateWeightKg(double weightKg) {
    if (weightKg < minWeightKg || weightKg > maxWeightKg) {
      return ValidationFailure(
        'weightKg',
        'Enter a weight between $minWeightKg and $maxWeightKg kg.',
      );
    }
    return null;
  }

  /// `FR-014` — 500 to 4,000 ml inclusive. Applies only to a *manual*
  /// target; a calculator suggestion is already clamped into this range
  /// by `08 §6.2` step 6, so this only ever rejects a hand-typed value.
  static ValidationFailure? validateTargetMl(int targetMl) {
    if (targetMl < minTargetMl || targetMl > maxTargetMl) {
      return ValidationFailure(
        'targetMl',
        'Enter a target between $minTargetMl and $maxTargetMl ml.',
      );
    }
    return null;
  }

  /// `> 3,500 ml` shows `CPY-074` — a caution, never a block (`FR-014`).
  static bool isHighTarget(int targetMl) => targetMl > highTargetThresholdMl;

  /// `end` must be strictly after `start` (`CPY-122`). Both are
  /// minute-of-day offsets, `0`–`1439`.
  static ValidationFailure? validateReminderWindow({
    required int startMinuteOfDay,
    required int endMinuteOfDay,
  }) {
    if (endMinuteOfDay <= startMinuteOfDay) {
      return ValidationFailure(
        'reminderWindow',
        'End time must be after the start time.',
      );
    }
    return null;
  }
}
