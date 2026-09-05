import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/onboarding/presentation/onboarding_draft_notifier.dart';

/// `FR-018` -- the shared, `keepAlive` draft every answer screen writes
/// through to. `keepAlive` is load-bearing: an `autoDispose` provider
/// would be torn down while no screen watches it during a route
/// transition, silently dropping the draft on the first Back.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('a value set at one step survives a later step\'s write (Back and '
      'Forward, FR-018)', () {
    final notifier = container.read(onboardingDraftProvider.notifier);

    notifier.setDisplayName('Alex');
    notifier.setAge(30);
    notifier.setSex(Sex.female);

    // Simulate reaching a later step and writing to it.
    notifier.setWeightKg(68.0);
    notifier.setActivityLevel(ActivityLevel.light);

    final draft = container.read(onboardingDraftProvider);
    expect(draft.displayName, 'Alex');
    expect(draft.age, 30);
    expect(draft.sex, Sex.female);
    expect(draft.weightKg, 68.0);
    expect(draft.activityLevel, ActivityLevel.light);
  });

  test('a partially-typed value written by a screen notifier survives a '
      'later step\'s write untouched', () {
    final notifier = container.read(onboardingDraftProvider.notifier);

    notifier.setDisplayName('Al'); // mid-keystroke
    notifier.setEnvironment(Environment.warm);

    expect(container.read(onboardingDraftProvider).displayName, 'Al');
  });

  test('toggleSpecialCircumstance adds then removes the same value', () {
    final notifier = container.read(onboardingDraftProvider.notifier);

    notifier.toggleSpecialCircumstance(SpecialCircumstance.pregnancy);
    expect(container.read(onboardingDraftProvider).specialCircumstances, {
      SpecialCircumstance.pregnancy,
    });

    notifier.toggleSpecialCircumstance(SpecialCircumstance.pregnancy);
    expect(
      container.read(onboardingDraftProvider).specialCircumstances,
      isEmpty,
    );
  });

  test('setManualTargetMl(null) reverts to the suggested value', () {
    final notifier = container.read(onboardingDraftProvider.notifier);

    notifier.setManualTargetMl(2800);
    expect(container.read(onboardingDraftProvider).manualTargetMl, 2800);

    notifier.setManualTargetMl(null);
    expect(container.read(onboardingDraftProvider).manualTargetMl, isNull);
  });

  test('reset() clears every answer back to a brand-new draft', () {
    final notifier = container.read(onboardingDraftProvider.notifier);

    notifier.setDisplayName('Alex');
    notifier.setAge(30);
    notifier.setSex(Sex.female);
    notifier.setWeightKg(68.0);
    notifier.setActivityLevel(ActivityLevel.light);
    notifier.setEnvironment(Environment.warm);
    notifier.toggleSpecialCircumstance(SpecialCircumstance.pregnancy);
    notifier.setManualTargetMl(2800);

    notifier.reset();

    final draft = container.read(onboardingDraftProvider);
    expect(draft.displayName, isNull);
    expect(draft.age, isNull);
    expect(draft.sex, isNull);
    expect(draft.weightKg, isNull);
    expect(draft.activityLevel, isNull);
    expect(draft.environment, isNull);
    expect(draft.specialCircumstances, isEmpty);
    expect(draft.manualTargetMl, isNull);
  });
}
