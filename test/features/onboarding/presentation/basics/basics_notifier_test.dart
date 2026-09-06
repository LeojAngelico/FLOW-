import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/domain/models/profile_enums.dart';
import 'package:flow/features/onboarding/presentation/basics/basics_notifier.dart';
import 'package:flow/features/onboarding/presentation/onboarding_draft_notifier.dart';

/// `05 ONB-03`: validate on blur, not per keystroke.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    // basicsProvider is autoDispose; keep it alive across this
    // test's calls the same way the presentation page would by watching
    // it continuously (hydration Decisions #37 precedent).
    container.listen(basicsProvider, (previous, next) {});
  });

  group('age', () {
    test('no error is shown before the field has been blurred, even for '
        'an out-of-range value', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onAgeChanged('5'); // below the 9-120 range

      expect(container.read(basicsProvider).ageError, isNull);
      expect(container.read(basicsProvider).ageTouched, isFalse);
    });

    test('an error appears once the field is blurred with an invalid '
        'value', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onAgeChanged('5');
      notifier.onAgeBlurred('5');

      final state = container.read(basicsProvider);
      expect(state.ageTouched, isTrue);
      expect(state.ageError, isNotNull);
    });

    test('the error clears once the value becomes valid after a blur', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onAgeChanged('5');
      notifier.onAgeBlurred('5');
      expect(container.read(basicsProvider).ageError, isNotNull);

      notifier.onAgeChanged('30');

      expect(container.read(basicsProvider).ageError, isNull);
    });

    test('blurring an emptied field validates the current (empty) field '
        'text, not the stale draft value left behind by the last '
        'successful parse (gate-4 finding: onAgeBlurred used to read '
        'OnboardingDraft.age, which onAgeChanged never clears back to '
        'null)', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onAgeChanged('30'); // draft.age becomes 30
      notifier.onAgeChanged(''); // unparsable -- draft.age stays 30
      expect(container.read(onboardingDraftProvider).age, 30);

      notifier.onAgeBlurred(''); // must validate '', not the stale '30'

      final state = container.read(basicsProvider);
      expect(state.ageTouched, isTrue);
      expect(state.ageError, isNotNull);
    });

    test('validateAgeText is the single source both onAgeBlurred and '
        "BasicsPage's Continue-button isValid computation read, so they "
        'can never disagree', () {
      final notifier = container.read(basicsProvider.notifier);

      expect(notifier.validateAgeText(''), isNotNull);
      expect(notifier.validateAgeText('5'), isNotNull);
      expect(notifier.validateAgeText('30'), isNull);
    });

    test('a valid age writes through to the shared draft', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onAgeChanged('30');

      expect(container.read(onboardingDraftProvider).age, 30);
    });

    test('a non-numeric keystroke does not write through to the draft '
        '(the field is digits-only, so this is only reachable via an '
        'emptied field)', () {
      final notifier = container.read(basicsProvider.notifier);
      notifier.onAgeChanged('30');

      notifier.onAgeChanged('');

      expect(container.read(onboardingDraftProvider).age, 30);
    });
  });

  group('name', () {
    test('no error before blur, even past the 24-character limit', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onNameChanged('A' * 25);

      expect(container.read(basicsProvider).nameError, isNull);
    });

    test('an error appears once blurred past the limit', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onNameChanged('A' * 25);
      notifier.onNameBlurred();

      expect(container.read(basicsProvider).nameError, isNotNull);
    });

    test('the error clears once the name becomes valid after a blur', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onNameChanged('A' * 25);
      notifier.onNameBlurred();
      expect(container.read(basicsProvider).nameError, isNotNull);

      notifier.onNameChanged('Alex');

      expect(container.read(basicsProvider).nameError, isNull);
    });

    test('an empty name is a valid, optional answer -- no error even '
        'after blur', () {
      final notifier = container.read(basicsProvider.notifier);

      notifier.onNameChanged('');
      notifier.onNameBlurred();

      expect(container.read(basicsProvider).nameError, isNull);
    });
  });

  test('onSexChanged writes straight through to the shared draft with no '
      'screen-owned state of its own', () {
    final notifier = container.read(basicsProvider.notifier);

    notifier.onSexChanged(Sex.male);

    expect(container.read(onboardingDraftProvider).sex, Sex.male);
  });
}
