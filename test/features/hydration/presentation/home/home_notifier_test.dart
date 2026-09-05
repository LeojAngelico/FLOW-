import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';
import 'package:flow/features/hydration/data/providers/hydration_data_providers.dart';
import 'package:flow/features/hydration/domain/models/daily_hydration.dart';
import 'package:flow/features/hydration/domain/models/hydration_entry.dart';
import 'package:flow/features/hydration/domain/models/logged_water.dart';
import 'package:flow/features/hydration/domain/repositories/hydration_repository.dart';
import 'package:flow/features/hydration/presentation/home/home_notifier.dart';

/// Stands in for `HydrationRepositoryImpl`. [failWith] is a deliberate
/// failure switch so the write-error path (APP-01 `writeError`) is
/// reachable without a real database; [logWaterCallCount] lets the
/// debounce tests assert the underlying write only actually happened
/// once.
class _FakeHydrationRepository implements HydrationRepository {
  Failure? failWith;
  int logWaterCallCount = 0;

  @override
  Stream<DailyHydration?> watchDailyHydration(String localDate) =>
      const Stream.empty();

  @override
  Stream<List<HydrationEntry>> watchEntries(String localDate) =>
      const Stream.empty();

  @override
  Future<int> readActiveTargetMl() async => 2000;

  @override
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  }) async {
    logWaterCallCount++;
    final failure = failWith;
    if (failure != null) return Result.err(failure);

    return Result.ok(
      LoggedWater(
        amountMl: amountMl,
        newTotalMl: amountMl,
        goalJustCompleted: false,
      ),
    );
  }
}

void main() {
  late _FakeHydrationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeHydrationRepository();
    container = ProviderContainer(
      overrides: [
        hydrationRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 1, 1, 12))),
      ],
    );
    addTearDown(container.dispose);
    // homeProvider is autoDispose; in production home_page.dart keeps it
    // alive by watching it continuously in build(). A bare
    // container.read() here does not hold a listener, so the provider
    // (and its debounce/isSubmitting state) would be torn down the
    // moment a test awaits past a real Future.delayed gap. Mirror the
    // page's watch with a no-op listener so notifier calls separated by
    // a real delay observe the same long-lived instance the widget
    // would.
    container.listen(homeProvider, (previous, next) {});
  });

  test('a successful quickAdd records the write and clears any prior '
      'failure', () async {
    await container.read(homeProvider.notifier).quickAdd(250);

    final state = container.read(homeProvider);
    expect(state.lastLogged?.amountMl, 250);
    expect(state.isSubmitting, isFalse);
    expect(state.writeFailure, isNull);
    expect(repository.logWaterCallCount, 1);
  });

  test('a rapid double-tap (FR-039, within the 300ms debounce window) '
      'writes once, not twice', () async {
    final notifier = container.read(homeProvider.notifier);

    await notifier.quickAdd(250);
    // Immediately re-invoked, sequentially awaited -- the first call has
    // already completed (isSubmitting is back to false), so this
    // exercises the DateTime.now()-based debounce guard specifically,
    // not the separate in-flight guard below. Real elapsed wall-clock
    // time between these two lines is well under the 300ms window.
    await notifier.quickAdd(250);

    expect(repository.logWaterCallCount, 1);
  });

  test('two taps genuinely more than 300ms apart both write -- the '
      'debounce must not eat an intentional repeat log', () async {
    final notifier = container.read(homeProvider.notifier);

    await notifier.quickAdd(250);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await notifier.quickAdd(250);

    expect(repository.logWaterCallCount, 2);
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('a second quickAdd call while the first is still in flight is '
      'ignored (the isSubmitting guard, independent of the debounce '
      'window)', () async {
    final notifier = container.read(homeProvider.notifier);

    final first = notifier.quickAdd(250);
    final second = notifier.quickAdd(250);
    await Future.wait([first, second]);

    expect(repository.logWaterCallCount, 1);
  });

  test('a StorageFailure surfaces on HomeState.writeFailure without '
      'recording a successful write', () async {
    repository.failWith = const StorageFailure('disk full');
    final notifier = container.read(homeProvider.notifier);

    await notifier.quickAdd(250);

    final state = container.read(homeProvider);
    expect(state.writeFailure, isA<StorageFailure>());
    expect(state.isSubmitting, isFalse);
    // No LoggedWater was ever recorded by this state -- the displayed
    // total itself lives entirely in `todayHydrationProvider`, which
    // this notifier never touches, so a write failure here cannot have
    // moved it (the APP-01 writeError acceptance criterion).
    expect(state.lastLogged, isNull);
  });

  test('a write failure followed by an immediate retry on the same chip '
      'is not swallowed by the debounce', () async {
    repository.failWith = const StorageFailure('disk full');
    final notifier = container.read(homeProvider.notifier);
    await notifier.quickAdd(250);
    expect(container.read(homeProvider).writeFailure, isNotNull);

    repository.failWith = null;
    // No artificial delay: a failed attempt must clear its own debounce
    // stamp, so this immediate retry on the same 250ml chip is a
    // genuine second write, not a no-op swallowed by the debounce guard.
    await notifier.quickAdd(250);

    final state = container.read(homeProvider);
    expect(state.writeFailure, isNull);
    expect(state.lastLogged?.amountMl, 250);
    expect(repository.logWaterCallCount, 2);
  });

  test('two different chips tapped in quick succession both register -- '
      'the debounce is keyed on amount as well as time', () async {
    final notifier = container.read(homeProvider.notifier);

    await notifier.quickAdd(250);
    // Immediately re-invoked with a *different* amount -- must not be
    // eaten by the same-chip debounce, even though real elapsed time
    // between these two lines is well under the 300ms window.
    await notifier.quickAdd(350);

    expect(repository.logWaterCallCount, 2);
    expect(container.read(homeProvider).lastLogged?.amountMl, 350);
  });
}
