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
import 'package:flow/features/hydration/presentation/add_water/add_water_notifier.dart';

/// Stands in for `HydrationRepositoryImpl`. [failWith] is a deliberate
/// failure switch; [logWaterCallCount] and [lastAmountMl] let a test
/// assert exactly what (and how many times) the notifier actually
/// submitted.
class _FakeHydrationRepository implements HydrationRepository {
  Failure? failWith;
  int logWaterCallCount = 0;
  int? lastAmountMl;
  HydrationSource? lastSource;

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
    lastAmountMl = amountMl;
    lastSource = source;
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
  });

  group('the stepper (increment/decrement)', () {
    test('increment steps by 50ml from the unset 0 starting value', () {
      container.read(addWaterProvider.notifier).increment();

      expect(container.read(addWaterProvider).amountMl, 50);
    });

    test('decrement clamps at the 50ml floor rather than going below it', () {
      final notifier = container.read(addWaterProvider.notifier)
        ..increment();
      notifier.decrement();
      notifier.decrement();

      expect(container.read(addWaterProvider).amountMl, 50);
    });

    test('increment clamps at the 2,000ml ceiling', () {
      final notifier = container.read(addWaterProvider.notifier);
      for (var i = 0; i < 45; i++) {
        notifier.increment();
      }

      expect(container.read(addWaterProvider).amountMl, 2000);
    });
  });

  group('setAmount (direct entry / value-setting chips)', () {
    test('clamps a negative value to 0 (unlike the stepper, this can '
        "reach the screen's pristine unset state)", () {
      container.read(addWaterProvider.notifier).setAmount(-10);

      expect(container.read(addWaterProvider).amountMl, 0);
    });

    test('clamps above 2,000ml to the ceiling', () {
      container.read(addWaterProvider.notifier).setAmount(5000);

      expect(container.read(addWaterProvider).amountMl, 2000);
    });

    test('setting the amount back to 0 clears isDirty', () {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(300);
      expect(container.read(addWaterProvider).isDirty, isTrue);

      notifier.setAmount(0);

      expect(container.read(addWaterProvider).isDirty, isFalse);
    });
  });

  group('the >1,000ml large-amount confirm gate (FR-024, CPY-104)', () {
    test('the first submit() past 1,000ml is blocked and sets '
        'needsLargeAmountConfirm instead of writing', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(1500);

      final committed = await notifier.submit();

      expect(committed, isFalse);
      expect(container.read(addWaterProvider).needsLargeAmountConfirm, isTrue);
      expect(repository.logWaterCallCount, 0);
    });

    test('a second submit() call after the gate is set proceeds with '
        'the write', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(1500);
      await notifier.submit();

      final committed = await notifier.submit();

      expect(committed, isTrue);
      expect(repository.logWaterCallCount, 1);
      expect(repository.lastAmountMl, 1500);
    });

    test('an amount at exactly 1,000ml does not require confirmation', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(1000);

      final committed = await notifier.submit();

      expect(committed, isTrue);
      expect(container.read(addWaterProvider).needsLargeAmountConfirm, isFalse);
    });

    test('changing the amount after a blocked confirm resets the gate '
        "so a stale confirmation can't apply to a different amount", () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(1500);
      await notifier.submit();
      expect(container.read(addWaterProvider).needsLargeAmountConfirm, isTrue);

      notifier.setAmount(1600);

      expect(container.read(addWaterProvider).needsLargeAmountConfirm, isFalse);
    });

    test('dismissLargeAmountConfirm clears the gate without submitting', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(1500);
      await notifier.submit();

      notifier.dismissLargeAmountConfirm();

      expect(container.read(addWaterProvider).needsLargeAmountConfirm, isFalse);
      expect(repository.logWaterCallCount, 0);
    });
  });

  group('submit()', () {
    test('an amount below the 50ml minimum cannot be submitted', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(40);

      final committed = await notifier.submit();

      expect(committed, isFalse);
      expect(repository.logWaterCallCount, 0);
    });

    test('the zero (nothing chosen yet) amount cannot be submitted', () async {
      final committed = await container.read(addWaterProvider.notifier).submit();

      expect(committed, isFalse);
      expect(repository.logWaterCallCount, 0);
    });

    test('logs the custom source, not quickAdd', () async {
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(250);

      await notifier.submit();

      expect(repository.lastSource, HydrationSource.custom);
    });

    test('a repository failure surfaces on AddWaterState.failure and '
        'returns false without popping', () async {
      repository.failWith = const StorageFailure('disk full');
      final notifier = container.read(addWaterProvider.notifier)
        ..setAmount(250);

      final committed = await notifier.submit();

      expect(committed, isFalse);
      final state = container.read(addWaterProvider);
      expect(state.failure, isA<StorageFailure>());
      expect(state.isSubmitting, isFalse);
    });
  });
}
