import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/onboarding/presentation/onboarding_draft_notifier.dart';
import 'package:flow/features/onboarding/presentation/weight/weight_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(weightProvider, (previous, next) {});
  });

  test('builds prefilled at 65.0kg when the draft has no weight yet', () {
    final state = container.read(weightProvider);

    expect(state.weightKg, weightPrefillKg);
    expect(state.fieldText, '65');
  });

  test('a valid keystroke updates both the field text and the shared '
      'draft, and rounds to one decimal', () {
    final notifier = container.read(weightProvider.notifier);

    notifier.onTextChanged('68.05');

    final state = container.read(weightProvider);
    expect(state.weightKg, 68.1);
    expect(state.fieldText, '68.05'); // the field shows exactly what was typed
    expect(state.error, isNull);
    expect(container.read(onboardingDraftProvider).weightKg, 68.1);
  });

  test('an out-of-range keystroke shows an error and is not written '
      'through to the draft', () {
    final notifier = container.read(weightProvider.notifier);

    notifier.onTextChanged('10'); // below 25.0

    final state = container.read(weightProvider);
    expect(state.error, isNotNull);
    expect(container.read(onboardingDraftProvider).weightKg, isNull);
  });

  test('an unparsable keystroke (mid-edit, e.g. a lone decimal point) '
      'shows an error rather than crashing', () {
    final notifier = container.read(weightProvider.notifier);

    notifier.onTextChanged('.');

    expect(container.read(weightProvider).error, isNotNull);
  });

  test('a slider drag updates the field text to match, overriding any '
      'error the field previously showed', () {
    final notifier = container.read(weightProvider.notifier);
    notifier.onTextChanged('10'); // put the state into error first
    expect(container.read(weightProvider).error, isNotNull);

    notifier.onSliderChanged(80.0);

    final state = container.read(weightProvider);
    expect(state.weightKg, 80.0);
    expect(state.fieldText, '80');
    expect(state.error, isNull);
    expect(container.read(onboardingDraftProvider).weightKg, 80.0);
  });

  test('the slider clamps at the lower bound (25.0kg) even if given a '
      'lower value defensively', () {
    final notifier = container.read(weightProvider.notifier);

    notifier.onSliderChanged(10.0);

    expect(container.read(weightProvider).weightKg, 25.0);
  });

  test('the slider clamps at the upper bound (250.0kg) even if given a '
      'higher value defensively', () {
    final notifier = container.read(weightProvider.notifier);

    notifier.onSliderChanged(300.0);

    expect(container.read(weightProvider).weightKg, 250.0);
  });

  test('a slider commit after a mid-typed field does not fight the '
      'keystroke -- the field text reflects the slider\'s value, not the '
      'stale typed text', () {
    final notifier = container.read(weightProvider.notifier);
    notifier.onTextChanged(
      '7',
    ); // partial, on the way to typing "70" -- out of range

    notifier.onSliderChanged(72.5);

    expect(container.read(weightProvider).fieldText, '72.5');
  });
}
