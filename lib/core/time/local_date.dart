/// The one place `BR-15`'s local-calendar-date day boundary is
/// expressed. Every feature that needs "which day does this instant
/// belong to" — hydration today, and any later feature that reuses the
/// same day-boundary concept — converts through these two pure
/// functions rather than re-deriving the rule at each call site.
///
/// `BR-16` (a device timezone change must not rewrite an *existing*
/// entry's day) falls out of this file's contract for free: callers are
/// expected to call [localDateFromDateTime] once, at write time, and
/// persist the resulting string — never to recompute it later from a
/// stored UTC instant under a possibly-different timezone.
library;

/// Formats [dateTime] as the local-calendar-date it falls on,
/// `'YYYY-MM-DD'`. Converts to the device's local timezone first via
/// [DateTime.toLocal] — callers must not do that conversion themselves
/// (see `docs/workplans/2026-09-04-hydration-logging.md` Decisions #19).
String localDateFromDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// The inverse of [localDateFromDateTime]: parses a `'YYYY-MM-DD'`
/// local-calendar-date string back into local midnight of that day.
/// Used to compute "the next local midnight" (`today_provider.dart`)
/// rather than for any storage round-trip — nothing in this feature
/// stores a parsed `DateTime` back to the database.
DateTime dateTimeFromLocalDate(String localDate) {
  final parts = localDate.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
