import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/onboarding/domain/models/onboarding_rules.dart';
import 'package:flow/features/onboarding/presentation/onboarding_draft_notifier.dart';
import 'package:flow/features/onboarding/presentation/target/target_notifier.dart';
import 'package:flow/features/onboarding/presentation/target/target_state.dart';

/// `TargetNotifier`'s `suggested -> editing -> edited` transition
/// (Decisions #34): tapping Adjust alone must not write `manualTargetMl`
/// -- only an actual stepper/slider change does, which is what keeps
/// "tap Adjust then Continue without changing anything" recorded as
/// `targetSource == suggested`.
void main() {
  late ProviderContainer container;

  // 24F, 68kg, light, warm -> the worked OVL-10 example, 2,000ml
  // (independently re-verified in reference_intake_v1_test.dart).
  void seedReadyDraft() {
    final draftNotifier = container.read(onboardingDraftProvider.notifier);
    draftNotifier.setAge(24);
    draftNotifier.setSex(Sex.female);
    draftNotifier.setWeightKg(68);
    draftNotifier.setActivityLevel(ActivityLevel.light);
    draftNotifier.setEnvironment(Environment.warm);
  }

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('build() computes the suggestion exactly once and starts in '
      'TargetMode.suggested', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});

    final state = container.read(targetProvider);

    expect(state.mode, TargetMode.suggested);
    expect(state.suggestion?.amountMl, 2000);
    expect(state.draftTargetMl, isNull);
    expect(state.failure, isNull);
  });

  test('an incomplete draft (router bypass) surfaces a failure instead of '
      'a suggestion', () {
    // Draft deliberately left incomplete.
    container.listen(targetProvider, (previous, next) {});

    final state = container.read(targetProvider);

    expect(state.suggestion, isNull);
    expect(state.failure, isNotNull);
  });

  test('startAdjusting moves to editing WITHOUT writing manualTargetMl -- '
      'entering the editor is not itself an edit', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();

    expect(container.read(targetProvider).mode, TargetMode.editing);
    expect(container.read(onboardingDraftProvider).manualTargetMl, isNull);
  });

  test('Adjust then Continue without changing anything: manualTargetMl '
      'stays null, so targetSource resolves to suggested downstream', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();
    // No stepper/slider interaction -- straight to "Continue".

    expect(container.read(onboardingDraftProvider).manualTargetMl, isNull);
  });

  test('an actual stepper tap moves to edited AND writes manualTargetMl '
      'to the shared draft', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();
    notifier.adjustBy(50);

    final state = container.read(targetProvider);
    expect(state.mode, TargetMode.edited);
    expect(state.draftTargetMl, 2050);
    expect(container.read(onboardingDraftProvider).manualTargetMl, 2050);
  });

  test('adjustBy clamps at the lower bound (500ml)', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();
    for (var i = 0; i < 60; i++) {
      notifier.adjustBy(-50);
    }

    expect(
      container.read(targetProvider).draftTargetMl,
      OnboardingRules.minTargetMl,
    );
  });

  test('adjustBy clamps at the upper bound (4,000ml)', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();
    for (var i = 0; i < 60; i++) {
      notifier.adjustBy(50);
    }

    expect(
      container.read(targetProvider).draftTargetMl,
      OnboardingRules.maxTargetMl,
    );
  });

  test('setDraftTargetMl (a slider commit) writes through the same as a '
      'stepper tap', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.setDraftTargetMl(3700);

    expect(container.read(targetProvider).mode, TargetMode.edited);
    expect(container.read(onboardingDraftProvider).manualTargetMl, 3700);
  });

  test('a value above 3,500ml (the non-blocking high-target caution, '
      'FR-014) is still accepted -- the notifier never blocks it', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.setDraftTargetMl(3600);

    final state = container.read(targetProvider);
    expect(state.failure, isNull);
    expect(state.draftTargetMl, 3600);
    expect(OnboardingRules.isHighTarget(3600), isTrue);
  });

  test('revertToSuggested clears manualTargetMl and returns to '
      'TargetMode.suggested from edited', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);
    notifier.startAdjusting();
    notifier.adjustBy(100);

    notifier.revertToSuggested();

    final state = container.read(targetProvider);
    expect(state.mode, TargetMode.suggested);
    expect(state.draftTargetMl, isNull);
    expect(container.read(onboardingDraftProvider).manualTargetMl, isNull);
  });

  test('a value above 3,500ml reached via the editor (Adjust) still '
      'reports isHighTarget true while TargetMode is editing/edited -- '
      'the state target_page.dart\'s caution-visibility condition reads '
      '(gate-4 finding 3: the caution was wrongly gated behind '
      '"!isEditing", so it could never appear on a manually-adjusted '
      'target -- the opposite of FR-014/Manual QA item 8)', () {
    seedReadyDraft();
    container.listen(targetProvider, (previous, next) {});
    final notifier = container.read(targetProvider.notifier);

    notifier.startAdjusting();
    notifier.setDraftTargetMl(3600);

    final state = container.read(targetProvider);
    expect(state.mode, TargetMode.edited);
    expect(OnboardingRules.isHighTarget(state.draftTargetMl!), isTrue);
    expect(state.failure, isNull); // the caution never blocks
  });

  test('a returning user whose draft already has a manualTargetMl set '
      '(Back/Forward, FR-018) restores TargetMode.edited from build(), '
      'not suggested', () {
    seedReadyDraft();
    container.read(onboardingDraftProvider.notifier).setManualTargetMl(2500);

    container.listen(targetProvider, (previous, next) {});
    final state = container.read(targetProvider);

    expect(state.mode, TargetMode.edited);
    expect(state.draftTargetMl, 2500);
  });
}
