import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/onboarding/domain/models/onboarding_draft.dart';
import 'package:flow/features/onboarding/domain/models/reminder_preferences.dart';

void main() {
  group('copyWith sentinel-clearing (displayName, manualTargetMl)', () {
    test('copyWith(displayName: null) clears a previously-set name back '
        'to null', () {
      const draft = OnboardingDraft(displayName: 'Alex');
      final cleared = draft.copyWith(displayName: null);

      expect(cleared.displayName, isNull);
    });

    test('omitting displayName from copyWith leaves it untouched', () {
      const draft = OnboardingDraft(displayName: 'Alex');
      final untouched = draft.copyWith(age: 30);

      expect(untouched.displayName, 'Alex');
      expect(untouched.age, 30);
    });

    test('copyWith(manualTargetMl: null) clears a previously-set manual '
        'target back to null (the Adjust -> revert-to-suggested path)', () {
      const draft = OnboardingDraft(manualTargetMl: 2500);
      final reverted = draft.copyWith(manualTargetMl: null);

      expect(reverted.manualTargetMl, isNull);
    });

    test('omitting manualTargetMl from copyWith leaves it untouched', () {
      const draft = OnboardingDraft(manualTargetMl: 2500);
      final untouched = draft.copyWith(age: 40);

      expect(untouched.manualTargetMl, 2500);
    });
  });

  group('reminders defaults to FR-015 seeded values, not null', () {
    test('a freshly-constructed draft already carries valid reminders', () {
      const draft = OnboardingDraft();
      expect(draft.reminders, const ReminderPreferences.defaults());
    });
  });

  group('isReadyForTarget / isComplete', () {
    const readyFields = OnboardingDraft(
      age: 30,
      sex: Sex.female,
      weightKg: 60,
      activityLevel: ActivityLevel.moderate,
      environment: Environment.temperate,
    );

    test(
      'true once age, sex, weight, activity and environment are all set',
      () {
        expect(readyFields.isReadyForTarget, isTrue);
        expect(readyFields.isComplete, isTrue);
      },
    );

    test('an empty specialCircumstances set does not block readiness — '
        'it is itself a valid answer', () {
      expect(readyFields.specialCircumstances, isEmpty);
      expect(readyFields.isReadyForTarget, isTrue);
    });

    test('false with age missing', () {
      expect(
        const OnboardingDraft(
          sex: Sex.female,
          weightKg: 60,
          activityLevel: ActivityLevel.moderate,
          environment: Environment.temperate,
        ).isReadyForTarget,
        isFalse,
      );
    });

    test('false with sex missing', () {
      expect(
        const OnboardingDraft(
          age: 30,
          weightKg: 60,
          activityLevel: ActivityLevel.moderate,
          environment: Environment.temperate,
        ).isReadyForTarget,
        isFalse,
      );
    });

    test('false with weightKg missing', () {
      expect(
        const OnboardingDraft(
          age: 30,
          sex: Sex.female,
          activityLevel: ActivityLevel.moderate,
          environment: Environment.temperate,
        ).isReadyForTarget,
        isFalse,
      );
    });

    test('false with activityLevel missing', () {
      expect(
        const OnboardingDraft(
          age: 30,
          sex: Sex.female,
          weightKg: 60,
          environment: Environment.temperate,
        ).isReadyForTarget,
        isFalse,
      );
    });

    test('false with environment missing', () {
      expect(
        const OnboardingDraft(
          age: 30,
          sex: Sex.female,
          weightKg: 60,
          activityLevel: ActivityLevel.moderate,
        ).isReadyForTarget,
        isFalse,
      );
    });

    test('a brand-new draft is neither ready nor complete', () {
      const draft = OnboardingDraft();
      expect(draft.isReadyForTarget, isFalse);
      expect(draft.isComplete, isFalse);
    });
  });

  group('toggling specialCircumstances via a fresh copyWith', () {
    test('replacing the set is additive/subtractive at the caller, not '
        'merged by copyWith itself', () {
      const draft = OnboardingDraft(
        specialCircumstances: {SpecialCircumstance.pregnancy},
      );
      final updated = draft.copyWith(
        specialCircumstances: {
          SpecialCircumstance.pregnancy,
          SpecialCircumstance.other,
        },
      );

      expect(updated.specialCircumstances, {
        SpecialCircumstance.pregnancy,
        SpecialCircumstance.other,
      });
    });
  });
}
