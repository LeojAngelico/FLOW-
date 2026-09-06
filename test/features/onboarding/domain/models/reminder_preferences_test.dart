import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/onboarding/domain/models/reminder_preferences.dart';

/// `BR-30` — the reminder-time derivation `ONB-08`'s live preview
/// (`reminder_preview_card.dart`) reads directly.
void main() {
  group('reminderMinutes (BR-30)', () {
    test(
      '08:00-22:00 every 120 minutes -> 8 times, ending exactly at 22:00',
      () {
        const preferences = ReminderPreferences(
          enabled: true,
          startMinuteOfDay: 480, // 08:00
          endMinuteOfDay: 1320, // 22:00
          intervalMinutes: 120,
          activeWeekdays: {1, 2, 3, 4, 5, 6, 7},
        );

        final minutes = preferences.reminderMinutes();

        expect(minutes, [480, 600, 720, 840, 960, 1080, 1200, 1320]);
        expect(minutes.length, 8);
        expect(minutes.last, 1320);
      },
    );

    test('an interval that overshoots the end drops the overshoot', () {
      const preferences = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 530,
        intervalMinutes: 40,
        activeWeekdays: {1},
      );

      final minutes = preferences.reminderMinutes();

      // 480, 520 (<= 530) are included; 560 overshoots 530 and is dropped.
      expect(minutes, [480, 520]);
      expect(minutes, isNot(contains(560)));
    });

    test('a window shorter than one interval yields exactly one time', () {
      const preferences = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 500,
        intervalMinutes: 30,
        activeWeekdays: {1},
      );

      final minutes = preferences.reminderMinutes();

      expect(minutes, [480]);
    });

    test('a start equal to end yields exactly one time', () {
      const preferences = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 480,
        intervalMinutes: 60,
        activeWeekdays: {1},
      );

      expect(preferences.reminderMinutes(), [480]);
    });

    test('a non-positive interval degrades defensively to a single reminder '
        'at start rather than looping forever', () {
      const preferences = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 1320,
        intervalMinutes: 0,
        activeWeekdays: {1},
      );

      expect(preferences.reminderMinutes(), [480]);
    });
  });

  group('defaults() (FR-015)', () {
    test('matches the seeded reminder_settings defaults exactly', () {
      const preferences = ReminderPreferences.defaults();

      expect(preferences.enabled, isTrue);
      expect(preferences.startMinuteOfDay, 480);
      expect(preferences.endMinuteOfDay, 1320);
      expect(preferences.intervalMinutes, 120);
      expect(preferences.activeWeekdays, {1, 2, 3, 4, 5, 6, 7});
    });
  });

  group('copyWith / equality', () {
    test('copyWith replaces only the given field', () {
      const preferences = ReminderPreferences.defaults();
      final updated = preferences.copyWith(enabled: false);

      expect(updated.enabled, isFalse);
      expect(updated.startMinuteOfDay, preferences.startMinuteOfDay);
      expect(updated, isNot(preferences));
    });

    test('two instances with the same fields (including weekday set order) '
        'are equal', () {
      const a = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 1320,
        intervalMinutes: 120,
        activeWeekdays: {1, 3, 5},
      );
      const b = ReminderPreferences(
        enabled: true,
        startMinuteOfDay: 480,
        endMinuteOfDay: 1320,
        intervalMinutes: 120,
        activeWeekdays: {5, 3, 1},
      );

      expect(a, b);
    });
  });
}
