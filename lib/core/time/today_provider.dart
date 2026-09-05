import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clock_provider.dart';
import 'local_date.dart';

part 'today_provider.g.dart';

/// Today's local-calendar-date (`'YYYY-MM-DD'`), reactive across local
/// midnight while the app stays foregrounded (`FR-034`).
///
/// Reads "now" from [clockProvider] (so the dev-flavor clock override
/// changes what "today" resolves to) but schedules its own `Timer`
/// against real wall-clock time to the next local midnight, at which
/// point it calls [Ref.invalidateSelf] so every watcher recomputes.
/// `Timer`s are not guaranteed to fire while the process is suspended,
/// so this alone does not cover the app being backgrounded across
/// midnight — see `today_refresh_listener.dart` for that half.
@riverpod
String today(Ref ref) {
  final clock = ref.watch(clockProvider);
  final now = clock.now();
  final localDate = localDateFromDateTime(now);

  final localMidnightToday = dateTimeFromLocalDate(localDate);
  // Built via the DateTime constructor (which normalizes an
  // out-of-range day into the next month) rather than
  // `localMidnightToday.add(const Duration(days: 1))`. `add` moves 24
  // hours of *absolute* time, not one calendar day, which is wrong on a
  // DST transition day: on spring-forward it lands an hour past local
  // midnight (an hour of staleness before the timer fires); on
  // fall-back it lands an hour *before* local midnight, at 23:00 the
  // same day, so `delay` comes out `<= 0` and every re-invocation
  // immediately reschedules for "now" -- a hot self-invalidation loop
  // for the last hour of that day. The constructor call below asks for
  // "the next calendar day at 00:00 local time" directly, which the
  // platform's DST rules resolve correctly.
  final nextLocalMidnight = DateTime(
    localMidnightToday.year,
    localMidnightToday.month,
    localMidnightToday.day + 1,
  );
  final delay = nextLocalMidnight.difference(now);

  final timer = Timer(delay, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return localDate;
}
