import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/time/clock.dart';
import '../../../hydration/calculator/hydration_calculator.dart';
import '../../../hydration/domain/models/profile_enums.dart';
import '../../../hydration/domain/models/user_profile.dart';
import '../models/onboarding_draft.dart';
import '../models/onboarding_rules.dart';
import '../repositories/onboarding_repository.dart';

/// Writes the `user_profiles` row and the `reminder_settings` update
/// (`FR-019`, ENT-01). **The only place a [UserProfile] is constructed**
/// — every field is either copied from [OnboardingDraft], recomputed
/// from [Clock]/[HydrationCalculator], or derived; nothing is invented
/// here.
///
/// Re-validates the whole draft rather than trusting
/// [OnboardingDraft.isComplete] alone: every field should already have
/// been rejected at its own screen, so a [ValidationFailure] surfacing
/// from *this* usecase means the UI let something through — a bug to
/// catch in testing, not a normal user-facing path (see the workplan's
/// acceptance criteria: "rejected again by the domain if the UI is
/// bypassed").
class CompleteOnboarding {
  CompleteOnboarding(this._repository, this._calculator, this._clock);

  final OnboardingRepository _repository;
  final HydrationCalculator _calculator;
  final Clock _clock;

  Future<Result<void>> call(OnboardingDraft draft) async {
    final validationFailure = _validate(draft);
    if (validationFailure != null) {
      return Result.err(validationFailure);
    }

    final now = _clock.now();

    final int dailyTargetMl;
    final TargetSource targetSource;
    final manualTargetMl = draft.manualTargetMl;
    if (manualTargetMl != null) {
      // Adjust was used — store exactly what was typed, even if it
      // happens to equal the suggestion (the acceptance criterion this
      // branch exists to satisfy).
      dailyTargetMl = manualTargetMl;
      targetSource = TargetSource.manual;
    } else {
      // Accept was used (or the target step was never touched to
      // deviate from it) — recompute the suggestion rather than
      // trusting a value the presentation layer might have cached, so
      // this usecase's output is reproducible from the draft alone.
      final suggestion = _calculator.calculate(
        HydrationInputs(
          age: draft.age!,
          sex: draft.sex!,
          weightKg: draft.weightKg!,
          activityLevel: draft.activityLevel!,
          environment: draft.environment!,
          specialCircumstances: draft.specialCircumstances,
        ),
      );
      dailyTargetMl = suggestion.amountMl;
      targetSource = TargetSource.suggested;
    }

    final profile = UserProfile(
      displayName: _normalizedDisplayName(draft.displayName),
      age: draft.age!,
      sex: draft.sex!,
      weightKg: draft.weightKg!,
      activityLevel: draft.activityLevel!,
      environment: draft.environment!,
      specialCircumstances: draft.specialCircumstances,
      dailyTargetMl: dailyTargetMl,
      targetSource: targetSource,
      // Never a literal — traceability (`07 §5`) means the stored
      // method id always comes from whichever calculator is currently
      // bound, on both branches above.
      calculatorMethodId: _calculator.methodId,
      profileCreatedAt: now,
      updatedAt: now,
    );

    return _repository.completeOnboarding(
      profile: profile,
      reminders: draft.reminders,
    );
  }

  /// Trims [displayName] and maps an empty-after-trim result to `null`
  /// — `FR-003`'s own "no name" answer. `OnboardingRules.validateDisplayName`
  /// counts trimmed runes, but `user_profiles.display_name`'s `CHECK
  /// (length(display_name) <= 24)` counts the raw stored string. A
  /// 24-rune name with one trailing space — which mobile autocorrect
  /// inserts routinely — passes domain validation untrimmed and then
  /// fails that CHECK, an unrecoverable dead end five screens after the
  /// user typed it. Trimming here, not in a notifier, holds regardless of
  /// which UI ever calls this usecase — the same reasoning as the
  /// weight-rounding precedent in `user_profile_mapper.dart` (Decisions
  /// #15).
  String? _normalizedDisplayName(String? displayName) {
    final trimmed = displayName?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Failure? _validate(OnboardingDraft draft) {
    if (!draft.isReadyForTarget) {
      return ValidationFailure(
        'draft',
        'Basics, weight, activity and environment must all be answered.',
      );
    }

    final nameFailure = OnboardingRules.validateDisplayName(draft.displayName);
    if (nameFailure != null) return nameFailure;

    final ageFailure = OnboardingRules.validateAge(draft.age!);
    if (ageFailure != null) return ageFailure;

    final weightFailure = OnboardingRules.validateWeightKg(draft.weightKg!);
    if (weightFailure != null) return weightFailure;

    final manualTargetMl = draft.manualTargetMl;
    if (manualTargetMl != null) {
      final targetFailure = OnboardingRules.validateTargetMl(manualTargetMl);
      if (targetFailure != null) return targetFailure;
    }

    final reminderFailure = OnboardingRules.validateReminderWindow(
      startMinuteOfDay: draft.reminders.startMinuteOfDay,
      endMinuteOfDay: draft.reminders.endMinuteOfDay,
    );
    if (reminderFailure != null) return reminderFailure;

    return null;
  }
}
