import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/hydration/domain/models/daily_hydration.dart';
import 'package:flow/features/hydration/domain/models/hydration_entry.dart';
import 'package:flow/features/hydration/domain/models/logged_water.dart';
import 'package:flow/features/hydration/domain/repositories/hydration_repository.dart';
import 'package:flow/features/hydration/domain/usecases/get_today_hydration.dart';

/// Stands in for `HydrationRepositoryImpl`'s read surface. Each of
/// [day]/[entries]/[targetMl] is a plain field rather than a
/// `StreamController`, since `GetTodayHydration.call` only ever reads
/// one emission (`.first`, via `asyncMap`) per composed value — see the
/// workplan's Decisions log #17. [logWater] is intentionally
/// unimplemented: this use case never writes.
class _FakeHydrationRepository implements HydrationRepository {
  _FakeHydrationRepository({
    this.day,
    this.entries = const [],
    this.targetMl = 2000,
  });

  final DailyHydration? day;
  final List<HydrationEntry> entries;
  final int targetMl;

  @override
  Stream<DailyHydration?> watchDailyHydration(String localDate) =>
      Stream.value(day);

  @override
  Stream<List<HydrationEntry>> watchEntries(String localDate) =>
      Stream.value(entries);

  @override
  Future<int> readActiveTargetMl() async => targetMl;

  @override
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  }) => throw UnimplementedError('GetTodayHydration never writes.');
}

void main() {
  test(
    'a zero-entry day (no daily_hydration row yet) falls back to the '
    "profile's active target",
    () async {
      final repository = _FakeHydrationRepository(
        day: null,
        entries: const [],
        targetMl: 2500,
      );

      final result = await GetTodayHydration(repository).call('2026-01-01').first;

      expect(result.effectiveTargetMl, 2500);
      expect(result.totalMl, 0);
      expect(result.entryCount, 0);
      expect(result.goalCompleted, isFalse);
      expect(result.entries, isEmpty);
    },
  );

  test(
    "once a daily_hydration row exists, the day row's own snapshotted "
    "target wins over the profile's current (possibly since-changed) "
    'target (BR-17)',
    () async {
      final entry = HydrationEntry(
        id: 'e1',
        amountMl: 500,
        occurredAt: DateTime.utc(2026, 1, 1, 8),
        localDate: '2026-01-01',
        source: HydrationSource.quickAdd,
        createdAt: DateTime.utc(2026, 1, 1, 8),
      );
      final repository = _FakeHydrationRepository(
        day: const DailyHydration(
          localDate: '2026-01-01',
          totalMl: 500,
          targetMl: 2100,
          goalCompleted: false,
          goalCompletedAt: null,
          entryCount: 1,
          status: DayStatus.inProgress,
        ),
        entries: [entry],
        // The profile's target has since changed to 3000 -- the day
        // row's own snapshot must win, not this value.
        targetMl: 3000,
      );

      final result = await GetTodayHydration(repository).call('2026-01-01').first;

      expect(result.effectiveTargetMl, 2100);
      expect(result.totalMl, 500);
      expect(result.entryCount, 1);
      expect(result.entries, [entry]);
    },
  );

  test('goalCompleted passes through from the day row once true', () async {
    final repository = _FakeHydrationRepository(
      day: DailyHydration(
        localDate: '2026-01-01',
        totalMl: 2000,
        targetMl: 2000,
        goalCompleted: true,
        goalCompletedAt: DateTime.utc(2026, 1, 1, 20),
        entryCount: 4,
        status: DayStatus.complete,
      ),
      entries: const [],
    );

    final result = await GetTodayHydration(repository).call('2026-01-01').first;

    expect(result.goalCompleted, isTrue);
  });

  test(
    'a StorageFailure from readActiveTargetMl (the missing-profile '
    'invariant violation) surfaces as a stream error, not a thrown '
    'exception outside the stream',
    () async {
      final repository = _FailingTargetRepository();

      await expectLater(
        GetTodayHydration(repository).call('2026-01-01'),
        emitsError(isA<StorageFailure>()),
      );
    },
  );
}

/// A second, narrower fake: only [readActiveTargetMl] fails, and only
/// on a zero-entry day (mirrors the real repository's invariant: a
/// missing profile row is only ever discovered when there's no day row
/// to fall back on).
class _FailingTargetRepository implements HydrationRepository {
  @override
  Stream<DailyHydration?> watchDailyHydration(String localDate) =>
      Stream.value(null);

  @override
  Stream<List<HydrationEntry>> watchEntries(String localDate) =>
      Stream.value(const []);

  @override
  Future<int> readActiveTargetMl() async {
    throw const StorageFailure(
      'No profile found. Complete onboarding before logging water.',
    );
  }

  @override
  Future<Result<LoggedWater>> logWater({
    required String id,
    required int amountMl,
    required DateTime occurredAt,
    required String localDate,
    required HydrationSource source,
  }) => throw UnimplementedError('GetTodayHydration never writes.');
}
