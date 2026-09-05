import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/features/onboarding/domain/models/onboarding_rules.dart';

/// The boundary table CLAUDE.md §12 asks for, against every
/// `OnboardingRules` validator (`FR-003`-`FR-010`, `FR-014`, `FR-015`).
void main() {
  group('validateDisplayName (FR-003 — trimmed, optional, <= 24 runes)', () {
    test('empty string is valid (no name given)', () {
      expect(OnboardingRules.validateDisplayName(''), isNull);
    });

    test('null is valid', () {
      expect(OnboardingRules.validateDisplayName(null), isNull);
    });

    test('whitespace-only is valid (trims to the empty answer)', () {
      expect(OnboardingRules.validateDisplayName('   '), isNull);
    });

    test('a single character is valid', () {
      expect(OnboardingRules.validateDisplayName('A'), isNull);
    });

    test('exactly 24 characters is valid', () {
      expect(OnboardingRules.validateDisplayName('A' * 24), isNull);
    });

    test('25 characters is rejected', () {
      final failure = OnboardingRules.validateDisplayName('A' * 25);
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).field, 'displayName');
    });

    test('24 four-byte emoji is valid — counted as 24 runes, not 48 code '
        'units', () {
      // U+1F600 (grinning face) is one rune but two UTF-16 code units.
      final name = '😀' * 24;
      expect(name.length, 48); // sanity: code units, not runes
      expect(OnboardingRules.validateDisplayName(name), isNull);
    });

    test('25 four-byte emoji is rejected — a code-unit count would have '
        'let this slip through at 48 code units', () {
      final name = '😀' * 25;
      final failure = OnboardingRules.validateDisplayName(name);
      expect(failure, isA<ValidationFailure>());
    });

    test('leading/trailing whitespace does not count toward the limit', () {
      final padded = '  ${'A' * 24}  ';
      expect(OnboardingRules.validateDisplayName(padded), isNull);
    });
  });

  group('validateAge (FR-004 — 9 to 120 inclusive)', () {
    test('8 is rejected', () {
      expect(OnboardingRules.validateAge(8), isA<ValidationFailure>());
    });

    test('9 is valid', () {
      expect(OnboardingRules.validateAge(9), isNull);
    });

    test('120 is valid', () {
      expect(OnboardingRules.validateAge(120), isNull);
    });

    test('121 is rejected', () {
      expect(OnboardingRules.validateAge(121), isA<ValidationFailure>());
    });
  });

  group('validateWeightKg (FR-006 — 25.0 to 250.0 kg inclusive)', () {
    test('24.9 is rejected', () {
      expect(OnboardingRules.validateWeightKg(24.9), isA<ValidationFailure>());
    });

    test('25.0 is valid', () {
      expect(OnboardingRules.validateWeightKg(25.0), isNull);
    });

    test('250.0 is valid', () {
      expect(OnboardingRules.validateWeightKg(250.0), isNull);
    });

    test('250.1 is rejected', () {
      expect(OnboardingRules.validateWeightKg(250.1), isA<ValidationFailure>());
    });
  });

  group('validateTargetMl (FR-014 — 500 to 4,000 ml inclusive)', () {
    test('499 is rejected', () {
      expect(OnboardingRules.validateTargetMl(499), isA<ValidationFailure>());
    });

    test('500 is valid', () {
      expect(OnboardingRules.validateTargetMl(500), isNull);
    });

    test('3500 is valid and not yet a high-target caution', () {
      expect(OnboardingRules.validateTargetMl(3500), isNull);
      expect(OnboardingRules.isHighTarget(3500), isFalse);
    });

    test('3501 is valid but triggers the non-blocking high-target caution', () {
      expect(OnboardingRules.validateTargetMl(3501), isNull);
      expect(OnboardingRules.isHighTarget(3501), isTrue);
    });

    test('4000 is valid', () {
      expect(OnboardingRules.validateTargetMl(4000), isNull);
    });

    test('4001 is rejected', () {
      expect(OnboardingRules.validateTargetMl(4001), isA<ValidationFailure>());
    });
  });

  group('validateReminderWindow (end strictly after start)', () {
    test('end == start is rejected', () {
      final failure = OnboardingRules.validateReminderWindow(
        startMinuteOfDay: 480,
        endMinuteOfDay: 480,
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).field, 'reminderWindow');
    });

    test('end < start is rejected', () {
      expect(
        OnboardingRules.validateReminderWindow(
          startMinuteOfDay: 480,
          endMinuteOfDay: 300,
        ),
        isA<ValidationFailure>(),
      );
    });

    test('end == start + interval is valid', () {
      expect(
        OnboardingRules.validateReminderWindow(
          startMinuteOfDay: 480,
          endMinuteOfDay: 480 + 120,
        ),
        isNull,
      );
    });
  });
}
