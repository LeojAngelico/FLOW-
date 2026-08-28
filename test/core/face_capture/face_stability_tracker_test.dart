import 'package:flow/core/face_capture/detection/face_stability_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 1, 1, 12);

  FaceStabilityTracker tracker({int holdMs = 900}) {
    return FaceStabilityTracker(holdDuration: Duration(milliseconds: holdMs));
  }

  group('FaceStabilityTracker', () {
    test('the first frame only establishes a baseline', () {
      final subject = tracker();

      // No elapsed time exists yet, so nothing can have been held.
      expect(subject.update(conditionsMet: true, now: start), 0);
      expect(subject.isStable, isFalse);
    });

    test('fills up over the hold period and stops at 1', () {
      final subject = tracker();

      subject.update(conditionsMet: true, now: start);

      expect(
        subject.update(
          conditionsMet: true,
          now: start.add(const Duration(milliseconds: 450)),
        ),
        closeTo(0.5, 0.001),
      );

      expect(
        subject.update(
          conditionsMet: true,
          now: start.add(const Duration(milliseconds: 900)),
        ),
        1,
      );

      // Holding longer cannot overshoot.
      expect(
        subject.update(
          conditionsMet: true,
          now: start.add(const Duration(seconds: 5)),
        ),
        1,
      );
      expect(subject.isStable, isTrue);
    });

    test('a single dropped frame costs progress but not the whole hold', () {
      final subject = tracker();

      subject.update(conditionsMet: true, now: start);
      subject.update(
        conditionsMet: true,
        now: start.add(const Duration(milliseconds: 600)),
      );

      // One bad frame, 40ms later: 40 * 2.5 = 100ms of the 600 lost.
      final after = subject.update(
        conditionsMet: false,
        now: start.add(const Duration(milliseconds: 640)),
      );

      expect(after, closeTo(500 / 900, 0.001));
      expect(after, greaterThan(0));
    });

    test('losing the face for longer empties it, and never goes negative', () {
      final subject = tracker();

      subject.update(conditionsMet: true, now: start);
      subject.update(
        conditionsMet: true,
        now: start.add(const Duration(milliseconds: 900)),
      );

      expect(
        subject.update(
          conditionsMet: false,
          now: start.add(const Duration(milliseconds: 1500)),
        ),
        0,
      );
      expect(subject.progress, 0);
    });

    test('reset clears progress and the timing baseline', () {
      final subject = tracker();

      subject.update(conditionsMet: true, now: start);
      subject.update(
        conditionsMet: true,
        now: start.add(const Duration(milliseconds: 450)),
      );

      subject.reset();

      expect(subject.progress, 0);

      // The next frame is a baseline again, so a long gap while the
      // camera was restarting cannot count as time held steady.
      expect(
        subject.update(
          conditionsMet: true,
          now: start.add(const Duration(minutes: 5)),
        ),
        0,
      );
    });

    test('clocks that jump backwards are ignored', () {
      final subject = tracker();

      subject.update(conditionsMet: true, now: start);

      expect(
        subject.update(
          conditionsMet: true,
          now: start.subtract(const Duration(seconds: 1)),
        ),
        0,
      );
    });
  });
}
