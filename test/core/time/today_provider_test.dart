import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';
import 'package:flow/core/time/today_provider.dart';

/// A [Timer] that never fires and does nothing on [cancel] -- stands in
/// for the real `Timer` `today_provider.dart` schedules, so
/// [_capturedTimerDelay] can read the `Duration` it was asked to wait
/// without actually waiting (or without `ref.invalidateSelf()` ever
/// running against a container that may already be torn down by the
/// time a real 24-hour timer would fire).
class _NoopTimer implements Timer {
  @override
  void cancel() {}

  @override
  bool get isActive => false;

  @override
  int get tick => 0;
}

/// Reads [todayProvider] with [now] injected via a [FixedClock] and
/// returns the [Duration] it passed to its internal `Timer` — captured
/// by intercepting `Timer` construction through a custom [Zone], since
/// the delay is a local variable inside `today_provider.dart`, not part
/// of its return value.
///
/// `today_provider.dart`'s own `Timer` is not the only one created
/// during this call: `container.read` takes no listener, so `todayProvider`
/// (not `keepAlive`) has zero listeners the instant it finishes
/// computing, and Riverpod schedules its own `Duration.zero` disposal
/// check immediately after — a second, unrelated `createTimer` call in
/// the same synchronous frame. A single `Duration?` variable is
/// last-write-wins and silently captures that second, irrelevant timer
/// instead. Collecting every duration and taking the first is what
/// keeps this bound to `today_provider.dart`'s own timer, which is
/// always created first, before the function returns and Riverpod's
/// bookkeeping runs.
Duration _capturedTimerDelay(DateTime now) {
  final container = ProviderContainer(
    overrides: [clockProvider.overrideWithValue(FixedClock(now))],
  );
  addTearDown(container.dispose);

  final captured = <Duration>[];
  final zoneSpec = ZoneSpecification(
    createTimer:
        (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Duration duration,
          void Function() f,
        ) {
          captured.add(duration);
          return _NoopTimer();
        },
  );

  runZoned(() => container.read(todayProvider), zoneSpecification: zoneSpec);

  return captured.first;
}

/// `today_provider.dart` schedules a `Timer` to the next local midnight
/// so `FR-034` (a live total reset) works while foregrounded. As with
/// `local_date_test.dart`'s own DST tests, a real cross-DST discontinuity
/// can only be *observed* on a host whose system timezone actually
/// transitions on the fixture date under test -- these tests prove the
/// delay is computed via calendar-day arithmetic (which is correct on
/// any host, DST-observing or not), not that this process's host
/// timezone happens to exercise the bug this guards against.
void main() {
  group('todayProvider next-midnight delay', () {
    test('a normal day delays to the following local midnight', () {
      final now = DateTime(2026, 1, 1, 8);
      final delay = _capturedTimerDelay(now);

      expect(delay, DateTime(2026, 1, 2).difference(now));
      expect(delay, const Duration(hours: 16));
    });

    test('a US spring-forward day (2026-03-08, same fixture date as '
        'local_date_test.dart) computes the boundary via calendar-day '
        'arithmetic, not `midnight + 24h`', () {
      final now = DateTime(2026, 3, 8, 23, 30);
      final delay = _capturedTimerDelay(now);

      // The bug this guards against: `midnight.add(Duration(days: 1))`
      // adds 24 *absolute* hours. On a host observing DST, spring
      // forward loses an hour of wall-clock time during that add, so
      // the timer would fire an hour late relative to the next actual
      // local midnight. Constructing the boundary via
      // `DateTime(y, m, d + 1)` asks for "the next calendar day at
      // 00:00 local time" directly, sidestepping the absolute-time
      // arithmetic entirely.
      expect(delay, DateTime(2026, 3, 9).difference(now));
      expect(delay, greaterThan(Duration.zero));
    });

    test('a US fall-back day (2026-11-01, same fixture date as '
        'local_date_test.dart) never produces a zero-or-negative delay in '
        'the last hour of the day', () {
      final now = DateTime(2026, 11, 1, 23, 30);
      final delay = _capturedTimerDelay(now);

      // The bug this guards against: on fall-back, 24 *absolute*
      // hours after local midnight lands at 23:00 the same calendar
      // day (one hour was repeated), so `midnight.add(Duration(days:
      // 1))` produced a boundary *before* `now` for the last hour of
      // the day -- a `delay <= 0`, which made every
      // `ref.invalidateSelf()` immediately reschedule for "now" (a hot
      // self-invalidation loop). The calendar-day constructor cannot
      // land before `now` here, because it targets the next day's
      // 00:00 regardless of how many absolute hours that is away.
      expect(delay, greaterThan(Duration.zero));
      expect(delay, DateTime(2026, 11, 2).difference(now));
      expect(delay, lessThanOrEqualTo(const Duration(hours: 1)));
    });

    test('the delay stays strictly positive at the last millisecond of the '
        'day', () {
      final now = DateTime(2026, 6, 30, 23, 59, 59, 999);
      final delay = _capturedTimerDelay(now);

      expect(delay, greaterThan(Duration.zero));
    });
  });
}
