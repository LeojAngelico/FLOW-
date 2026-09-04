import 'package:flutter_test/flutter_test.dart';
import 'package:flow/features/hydration/domain/models/today_hydration.dart';

void main() {
  TodayHydration make({required int totalMl, required int targetMl}) {
    return TodayHydration(
      effectiveTargetMl: targetMl,
      totalMl: totalMl,
      entryCount: 0,
      goalCompleted: false,
      entries: const [],
    );
  }

  group('remainingMl', () {
    test('is target - total while under target', () {
      expect(make(totalMl: 750, targetMl: 2000).remainingMl, 1250);
    });

    test('is 0 exactly at the target', () {
      expect(make(totalMl: 2000, targetMl: 2000).remainingMl, 0);
    });

    test('floors at 0 once total exceeds the target -- never negative', () {
      expect(make(totalMl: 2500, targetMl: 2000).remainingMl, 0);
    });
  });

  group('progressFraction (uncapped, drives the textual readout)', () {
    test('is totalMl / effectiveTargetMl', () {
      expect(make(totalMl: 1000, targetMl: 2000).progressFraction, 0.5);
    });

    test('is 0 with zero entries', () {
      expect(make(totalMl: 0, targetMl: 2000).progressFraction, 0);
    });

    test('exceeds 1.0 once the goal is passed -- FR-033 requires the '
        'text to show the true total past 100%', () {
      expect(make(totalMl: 3000, targetMl: 2000).progressFraction, 1.5);
    });

    test('guards a non-positive target (corrupt-read guard) instead of '
        'dividing by zero', () {
      expect(make(totalMl: 500, targetMl: 0).progressFraction, 0);
    });
  });

  group('displayFraction (capped at 1.0, drives the HydrationGlass fill)', () {
    test('matches progressFraction while under target', () {
      final today = make(totalMl: 1000, targetMl: 2000);
      expect(today.displayFraction, today.progressFraction);
    });

    test('is exactly 1.0 at the target boundary', () {
      expect(make(totalMl: 2000, targetMl: 2000).displayFraction, 1.0);
    });

    test('caps at 1.0 once the goal is passed, unlike progressFraction', () {
      final today = make(totalMl: 3000, targetMl: 2000);

      expect(today.displayFraction, 1.0);
      expect(today.progressFraction, 1.5);
    });

    test('does not go negative for the same non-positive-target guard', () {
      expect(make(totalMl: 500, targetMl: 0).displayFraction, 0.0);
    });
  });
}
