import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/features/hydration/domain/models/daily_hydration.dart';
import 'package:flow/features/hydration/domain/models/hydration_entry.dart';
import 'package:flow/features/hydration/domain/models/logged_water.dart';
import 'package:flow/features/hydration/domain/repositories/hydration_repository.dart';
import 'package:flow/features/hydration/domain/usecases/log_water.dart';

/// Stands in for `HydrationRepositoryImpl`'s write path. Captures every
/// argument `LogWater` passes to [logWater] so a test can assert on them
/// directly (in particular, that `localDate` was derived from the
/// injected [Clock] rather than the wall clock), and exposes [failWith]
/// as a deliberate failure switch so the write-failure path is
/// reachable without a real database.
class _FakeHydrationRepository implements HydrationRepository {
  Failure? failWith;
  int callCount = 0;

  String? lastId;
  int? lastAmountMl;
  DateTime? lastOccurredAt;
  String? lastLocalDate;
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
    callCount++;
    lastId = id;
    lastAmountMl = amountMl;
    lastOccurredAt = occurredAt;
    lastLocalDate = localDate;
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

  setUp(() {
    repository = _FakeHydrationRepository();
  });

  group('the 50-2000ml boundary (FR-024)', () {
    Future<Result<LoggedWater>> callWith(int amountMl) {
      final logWater = LogWater(
        repository,
        FixedClock(DateTime(2026, 1, 1, 12)),
      );
      return logWater.call(amountMl: amountMl, source: HydrationSource.quickAdd);
    }

    test('49ml (one under the lower bound) is rejected', () async {
      final result = await callWith(49);

      expect(result, isA<Err<LoggedWater>>());
      expect((result as Err<LoggedWater>).failure, isA<ValidationFailure>());
      expect(repository.callCount, 0);
    });

    test('50ml (the lower bound) is accepted', () async {
      final result = await callWith(50);

      expect(result, isA<Ok<LoggedWater>>());
      expect(repository.callCount, 1);
    });

    test('2000ml (the upper bound) is accepted', () async {
      final result = await callWith(2000);

      expect(result, isA<Ok<LoggedWater>>());
      expect(repository.callCount, 1);
    });

    test('2001ml (one over the upper bound) is rejected', () async {
      final result = await callWith(2001);

      expect(result, isA<Err<LoggedWater>>());
      expect((result as Err<LoggedWater>).failure, isA<ValidationFailure>());
      expect(repository.callCount, 0);
    });

    test('0ml is rejected', () async {
      final result = await callWith(0);

      expect(result, isA<Err<LoggedWater>>());
      expect(repository.callCount, 0);
    });

    test('a negative amount is rejected', () async {
      final result = await callWith(-50);

      expect(result, isA<Err<LoggedWater>>());
      expect(repository.callCount, 0);
    });

    test('the ValidationFailure names the amountMl field and the bound', () async {
      final result = await callWith(1);

      final failure = (result as Err<LoggedWater>).failure as ValidationFailure;
      expect(failure.field, 'amountMl');
      expect(failure.message, contains('50'));
      expect(failure.message, contains('2000'));
    });
  });

  test('localDate is derived from the injected Clock, not the wall clock', () async {
    final clock = FixedClock(DateTime(2026, 3, 15, 23, 45));
    final logWater = LogWater(repository, clock);

    await logWater.call(amountMl: 250, source: HydrationSource.quickAdd);

    expect(repository.lastLocalDate, '2026-03-15');
    expect(repository.lastOccurredAt, clock.now());
  });

  test('a day boundary crossing is reflected in the derived localDate', () async {
    final justBeforeMidnight = FixedClock(DateTime(2026, 6, 30, 23, 59, 59));
    final justAfterMidnight = FixedClock(DateTime(2026, 7, 1));

    await LogWater(
      repository,
      justBeforeMidnight,
    ).call(amountMl: 250, source: HydrationSource.quickAdd);
    expect(repository.lastLocalDate, '2026-06-30');

    await LogWater(
      repository,
      justAfterMidnight,
    ).call(amountMl: 250, source: HydrationSource.quickAdd);
    expect(repository.lastLocalDate, '2026-07-01');
  });

  test('generates a fresh id per call and forwards the requested source', () async {
    final logWater = LogWater(repository, FixedClock(DateTime(2026, 1, 1)));

    await logWater.call(amountMl: 350, source: HydrationSource.custom);
    final firstId = repository.lastId;
    expect(firstId, isNotEmpty);
    expect(repository.lastSource, HydrationSource.custom);

    await logWater.call(amountMl: 350, source: HydrationSource.custom);
    expect(repository.lastId, isNotEmpty);
    expect(repository.lastId, isNot(firstId));
  });

  test('a repository failure passes through unchanged', () async {
    repository.failWith = const StorageFailure('disk full');
    final logWater = LogWater(repository, FixedClock(DateTime(2026, 1, 1)));

    final result = await logWater.call(
      amountMl: 250,
      source: HydrationSource.quickAdd,
    );

    expect(result, isA<Err<LoggedWater>>());
    expect((result as Err<LoggedWater>).failure, isA<StorageFailure>());
  });
}
