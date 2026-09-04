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
  final nextLocalMidnight = localMidnightToday.add(const Duration(days: 1));
  final delay = nextLocalMidnight.difference(now);

  final timer = Timer(delay, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return localDate;
}
