import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/time/local_date.dart';

/// `BR-16`'s real guarantee -- that a device timezone change must not
/// rewrite an *existing* entry's day -- is architectural, not something
/// this pure-function pair can prove alone: it depends on
/// `localDateFromDateTime` being called once, at write time, and the
/// resulting string being persisted rather than recomputed later (see
/// the workplan's Manual QA item 5, which says outright this "cannot be
/// fully proven in a unit test"). What *is* unit-testable here is the
/// function's own contract: it derives the calendar date entirely from
/// [DateTime.toLocal], with no independent arithmetic of its own that
/// could disagree with the platform's DST rules.
void main() {
  group('localDateFromDateTime', () {
    test('pads a single-digit month and day', () {
      expect(localDateFromDateTime(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('does not pad a two-digit month and day', () {
      expect(localDateFromDateTime(DateTime(2026, 12, 25)), '2026-12-25');
    });

    test('a local instant just before midnight stays on the earlier day', () {
      expect(
        localDateFromDateTime(DateTime(2026, 6, 30, 23, 59, 59, 999)),
        '2026-06-30',
      );
    });

    test('a local instant at exactly midnight rolls to the next day '
        '(BR-15 day boundary)', () {
      expect(localDateFromDateTime(DateTime(2026, 7, 1)), '2026-07-01');
    });

    test('a leap-day instant round-trips correctly', () {
      expect(localDateFromDateTime(DateTime(2028, 2, 29, 12)), '2028-02-29');
    });

    test('a US spring-forward day (2026-03-08) formats to its own '
        'calendar date regardless of the wall-clock discontinuity', () {
      expect(localDateFromDateTime(DateTime(2026, 3, 8, 23, 30)), '2026-03-08');
    });

    test('a US fall-back day (2026-11-01) formats to its own calendar '
        'date -- including a wall-clock hour that occurs twice that day', () {
      expect(localDateFromDateTime(DateTime(2026, 11, 1, 1, 30)), '2026-11-01');
    });

    test('converts through DateTime.toLocal, not the caller\'s timezone '
        'assumption -- a UTC instant is formatted as its local date', () {
      final utcInstant = DateTime.utc(2026, 1, 1, 0, 30);
      final expected = localDateFromDateTime(utcInstant.toLocal());

      expect(localDateFromDateTime(utcInstant), expected);
    });
  });

  group('dateTimeFromLocalDate (the inverse, used by today_provider.dart)', () {
    test('parses back to local midnight of the same calendar day', () {
      final result = dateTimeFromLocalDate('2026-07-04');

      expect(result, DateTime(2026, 7, 4));
    });

    test('round-trips through localDateFromDateTime for a local-midnight '
        'instant', () {
      final localDate = localDateFromDateTime(DateTime(2026, 9, 4));

      expect(dateTimeFromLocalDate(localDate), DateTime(2026, 9, 4));
    });

    test('parses a leap-day string', () {
      expect(dateTimeFromLocalDate('2028-02-29'), DateTime(2028, 2, 29));
    });
  });
}
