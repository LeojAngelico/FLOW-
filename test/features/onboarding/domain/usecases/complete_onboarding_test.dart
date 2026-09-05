import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/features/hydration/calculator/hydration_calculator.dart';
import 'package:flow/features/hydration/calculator/hydration_result.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/hydration/domain/models/user_profile.dart';
import 'package:flow/features/onboarding/domain/models/onboarding_draft.dart';
import 'package:flow/features/onboarding/domain/models/reminder_preferences.dart';
import 'package:flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flow/features/onboarding/domain/usecases/complete_onboarding.dart';

/// Stands in for `OnboardingRepositoryImpl`'s write path. Captures the
/// exact [UserProfile]/[ReminderPreferences] passed so a test can assert
/// on them directly, and exposes [failWith] as a deliberate failure
/// switch so the write-failure path is reachable without a real database.
class _FakeOnboardingRepository implements OnboardingRepository {
  Failure? failWith;
  int callCount = 0;
  UserProfile? lastProfile;
  ReminderPreferences? lastReminders;

  @override
  Future<Result<void>> completeOnboarding({
    required UserProfile profile,
    required ReminderPreferences reminders,
  }) async {
    callCount++;
    lastProfile = profile;
    lastReminders = reminders;

    final failure = failWith;
    if (failure != null) return Result.err(failure);
    return const Result.ok(null);
  }
}

/// A fixed-output calculator so a test can assert exactly what
/// `CompleteOnboarding` stores on the "Accept" (no manual override)
/// branch, without depending on `ReferenceIntakeV1`'s real arithmetic.
class _FixedCalculator implements HydrationCalculator {
  const _FixedCalculator(this.methodId, this.suggestedAmountMl);

  @override
  final String methodId;

  final int suggestedAmountMl;

  @override
  SuggestedHydrationTarget calculate(HydrationInputs inputs) {
    return SuggestedHydrationTarget(
      amountMl: suggestedAmountMl,
      amountLiters: suggestedAmountMl / 1000,
      calculationMethodId: methodId,
      methodId: methodId,
      breakdown: const [],
      assumptions: const [],
      disclaimer: 'referenceIntakeDisclaimer',
      requiresProfessionalNotice: false,
    );
  }
}

void main() {
  late _FakeOnboardingRepository repository;
  late _FixedCalculator calculator;
  late FixedClock clock;

  const readyDraft = OnboardingDraft(
    displayName: 'Alex',
    age: 24,
    sex: Sex.female,
    weightKg: 68,
    activityLevel: ActivityLevel.light,
    environment: Environment.warm,
  );

  setUp(() {
    repository = _FakeOnboardingRepository();
    calculator = const _FixedCalculator('reference_intake_v1', 2000);
    clock = FixedClock(DateTime.utc(2026, 5, 1, 12));
  });

  CompleteOnboarding buildUseCase() =>
      CompleteOnboarding(repository, calculator, clock);

  test('Accept (no manual override): targetSource is suggested and the '
      'suggested amount is stored', () async {
    final result = await buildUseCase().call(readyDraft);

    expect(result, isA<Ok<void>>());
    expect(repository.callCount, 1);
    expect(repository.lastProfile!.targetSource, TargetSource.suggested);
    expect(repository.lastProfile!.dailyTargetMl, 2000);
  });

  test('Adjust: targetSource is manual even when the adjusted value '
      'equals the suggestion exactly', () async {
    final draft = readyDraft.copyWith(manualTargetMl: 2000);

    final result = await buildUseCase().call(draft);

    expect(result, isA<Ok<void>>());
    expect(repository.lastProfile!.targetSource, TargetSource.manual);
    expect(repository.lastProfile!.dailyTargetMl, 2000);
  });

  test('Adjust to a different value: manual is stored verbatim', () async {
    final draft = readyDraft.copyWith(manualTargetMl: 2800);

    await buildUseCase().call(draft);

    expect(repository.lastProfile!.targetSource, TargetSource.manual);
    expect(repository.lastProfile!.dailyTargetMl, 2800);
  });

  test('calculatorMethodId always comes from the calculator\'s methodId, '
      'on both the suggested and the manual branch', () async {
    await buildUseCase().call(readyDraft);
    expect(repository.lastProfile!.calculatorMethodId, 'reference_intake_v1');

    await buildUseCase().call(readyDraft.copyWith(manualTargetMl: 3000));
    expect(repository.lastProfile!.calculatorMethodId, 'reference_intake_v1');
  });

  test('profileCreatedAt and updatedAt come from the injected Clock, not '
      'the wall clock', () async {
    await buildUseCase().call(readyDraft);

    expect(repository.lastProfile!.profileCreatedAt, clock.now());
    expect(repository.lastProfile!.updatedAt, clock.now());
  });

  test('reminders are forwarded from the draft unchanged', () async {
    final draft = readyDraft.copyWith(
      reminders: const ReminderPreferences.defaults().copyWith(enabled: false),
    );

    await buildUseCase().call(draft);

    expect(repository.lastReminders!.enabled, isFalse);
  });

  group('re-validation before the repository is touched', () {
    test('an incomplete draft (isReadyForTarget false) is rejected and '
        'never reaches the repository', () async {
      const draft = OnboardingDraft(
        sex: Sex.female,
        weightKg: 68,
        activityLevel: ActivityLevel.light,
        environment: Environment.warm,
      );

      final result = await buildUseCase().call(draft);

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(repository.callCount, 0);
    });

    test('an out-of-range age (bypassed UI) is rejected before the '
        'repository is touched', () async {
      final draft = readyDraft.copyWith(age: 8);

      final result = await buildUseCase().call(draft);

      expect(result, isA<Err<void>>());
      expect(repository.callCount, 0);
    });

    test('an out-of-range weight (bypassed UI) is rejected before the '
        'repository is touched', () async {
      final draft = readyDraft.copyWith(weightKg: 250.1);

      final result = await buildUseCase().call(draft);

      expect(result, isA<Err<void>>());
      expect(repository.callCount, 0);
    });

    test('an out-of-range manual target (bypassed UI) is rejected before '
        'the repository is touched', () async {
      final draft = readyDraft.copyWith(manualTargetMl: 4001);

      final result = await buildUseCase().call(draft);

      expect(result, isA<Err<void>>());
      expect(repository.callCount, 0);
    });

    test('an invalid reminder window (end <= start) is rejected before '
        'the repository is touched', () async {
      final draft = readyDraft.copyWith(
        reminders: const ReminderPreferences.defaults().copyWith(
          startMinuteOfDay: 600,
          endMinuteOfDay: 600,
        ),
      );

      final result = await buildUseCase().call(draft);

      expect(result, isA<Err<void>>());
      expect(repository.callCount, 0);
    });
  });

  test('a repository failure passes through unchanged', () async {
    repository.failWith = const StorageFailure('disk full');

    final result = await buildUseCase().call(readyDraft);

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<StorageFailure>());
  });
}
