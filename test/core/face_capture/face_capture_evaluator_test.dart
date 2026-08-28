import 'package:flow/core/face_capture/detection/face_capture_assessment.dart';
import 'package:flow/core/face_capture/detection/face_capture_evaluator.dart';
import 'package:flow/core/face_capture/detection/face_capture_geometry.dart';
import 'package:flow/core/face_capture/detection/face_sample.dart';
import 'package:flow/core/face_capture/face_capture_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// A frame that satisfies every rule for [orientation].
FaceSample goodSample({
  required FaceOrientation orientation,
  double? smile,
  double? widthFraction,
  double? centerX,
  double? centerY,
  int faceCount = 1,
}) {
  final yaw = switch (orientation) {
    FaceOrientation.front => 0.0,
    FaceOrientation.left => 30.0,
    FaceOrientation.right => -30.0,
  };

  return FaceSample(
    faceCount: faceCount,
    centerX: centerX ?? 0.5,
    centerY: centerY ?? FaceCaptureGeometry.guideCenterY,
    widthFraction: widthFraction ?? 0.42,
    yawDegrees: yaw,
    smileProbability: smile,
    // Matches the pose: centred for a front view, displaced for a turn.
    noseOffsetFraction: orientation == FaceOrientation.front ? 0.03 : 0.2,
  );
}

void main() {
  const front = FaceCaptureEvaluator(orientation: FaceOrientation.front);

  group('scoring', () {
    test('a frame that meets every requirement scores 100 at once', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      expect(conditions.allSatisfied, isTrue);

      // 100% is a statement about the requirements, so holding longer
      // cannot make it any truer.
      expect(front.assess(conditions, 0).score, 100);
      expect(front.assess(conditions, 0.5).score, 100);
      expect(front.assess(conditions, 1).score, 100);
    });

    test('100% is exactly "every requirement passes", never rounding', () {
      // Whole-number weights and nothing graded, so the two can't
      // disagree in either direction.
      final samples = [
        goodSample(orientation: FaceOrientation.front),
        goodSample(orientation: FaceOrientation.front, widthFraction: 0.1),
        goodSample(orientation: FaceOrientation.front, centerX: 0.9),
        goodSample(orientation: FaceOrientation.front).copyYaw(40),
        const FaceSample.empty(),
        goodSample(orientation: FaceOrientation.front, faceCount: 2),
      ];

      for (final sample in samples) {
        final conditions = front.check(sample);

        expect(
          front.assess(conditions, 0).score == 100,
          conditions.allSatisfied,
        );
      }
    });

    test('reaching 100% starts the hold, it does not fire the shutter', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      final counting = front.assess(conditions, 0);

      expect(counting.score, 100);
      expect(counting.isReady, isFalse);
      expect(counting.holdCountdownSeconds, 3);

      final almost = front.assess(conditions, 0.99);

      expect(almost.score, 100);
      expect(almost.isReady, isFalse);

      final done = front.assess(conditions, 1);

      expect(done.isReady, isTrue);
      expect(done.holdCountdownSeconds, 0);
    });

    test('a smile requirement is just one more weight', () {
      const smiling = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        smileRequired: true,
      );

      final withSmile = smiling.check(
        goodSample(orientation: FaceOrientation.front, smile: 0.9),
      );

      expect(smiling.assess(withSmile, 0).score, 100);
    });

    test('a smile requirement caps the score until the user smiles', () {
      const smiling = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        smileRequired: true,
      );

      final noSmile = smiling.check(
        goodSample(orientation: FaceOrientation.front, smile: 0.1),
      );

      expect(noSmile.allSatisfied, isFalse);
      // 9 of 11 weight: everything but the smile.
      expect(smiling.assess(noSmile, 0).score, 82);
      // And no countdown, because the requirements are not all met.
      expect(smiling.assess(noSmile, 0).holdCountdownSeconds, 0);
      expect(smiling.assess(noSmile, 1).isReady, isFalse);
    });

    test('no face scores zero rather than a partial score', () {
      final conditions = front.check(const FaceSample.empty());

      expect(front.assess(conditions, 0).score, 0);
      // Even a stale hold cannot lift a frame with no face.
      expect(front.assess(conditions, 1).score, 0);
    });

    test('the score ignores nonsense hold values', () {
      final good = front.check(goodSample(orientation: FaceOrientation.front));

      expect(front.assess(good, 5).score, 100);
      expect(front.assess(good, -5).score, 100);
      expect(front.assess(good, -5).holdCountdownSeconds, 3);
    });
  });

  group('orientation', () {
    test('front accepts a small tilt and rejects a turn', () {
      expect(
        front
            .check(goodSample(orientation: FaceOrientation.front).copyYaw(12))
            .isOrientationCorrect,
        isTrue,
      );

      expect(
        front
            .check(goodSample(orientation: FaceOrientation.front).copyYaw(25))
            .isOrientationCorrect,
        isFalse,
      );
    });

    test('left and right are not interchangeable', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);
      const right = FaceCaptureEvaluator(orientation: FaceOrientation.right);

      final turnedLeft = goodSample(orientation: FaceOrientation.left);

      expect(left.check(turnedLeft).isOrientationCorrect, isTrue);
      expect(right.check(turnedLeft).isOrientationCorrect, isFalse);

      final turnedRight = goodSample(orientation: FaceOrientation.right);

      expect(right.check(turnedRight).isOrientationCorrect, isTrue);
      expect(left.check(turnedRight).isOrientationCorrect, isFalse);
    });

    test('a turn only has to be a natural one', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);

      FaceSample turn({required double yaw, required double nose}) {
        return FaceSample(
          faceCount: 1,
          centerX: 0.5,
          centerY: FaceCaptureGeometry.guideCenterY,
          widthFraction: 0.4,
          yawDegrees: yaw,
          noseOffsetFraction: nose,
        );
      }

      // 15 degrees is a glance, not a contortion, and turning further
      // keeps passing.
      expect(
        left.check(turn(yaw: 15, nose: 0.05)).isOrientationCorrect,
        isTrue,
      );
      expect(left.check(turn(yaw: 80, nose: 0.4)).isOrientationCorrect, isTrue);

      // Neither signal says "turned".
      expect(
        left.check(turn(yaw: 10, nose: 0.05)).isOrientationCorrect,
        isFalse,
      );

      // Same small angle, but the nose says otherwise — which is the
      // case that a real profile produces.
      expect(left.check(turn(yaw: 10, nose: 0.2)).isOrientationCorrect, isTrue);
    });

    // The numbers in this group are what an iPhone 15 actually
    // reported, from the two screenshots that showed left and right
    // failing. They are the regression guard for that bug.
    test('accepts the turns a real device reports', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);
      const right = FaceCaptureEvaluator(orientation: FaceOrientation.right);

      // Turning to the user's own left: the device reported -29°, so
      // the stored angle (negated on the way in) is +29.
      const turnedLeft = FaceSample(
        faceCount: 1,
        centerX: 0.51,
        centerY: 0.43,
        widthFraction: 0.49,
        yawDegrees: 29,
        noseOffsetFraction: 0.2,
      );

      expect(left.check(turnedLeft).isOrientationCorrect, isTrue);
      expect(right.check(turnedLeft).isOrientationCorrect, isFalse);

      // Turning to their right, far enough to show an ear — and yet
      // the device only reported 10.1°, which is *inside* the front
      // tolerance. The nose offset is what makes this a turn.
      const turnedRight = FaceSample(
        faceCount: 1,
        centerX: 0.41,
        centerY: 0.46,
        widthFraction: 0.51,
        yawDegrees: -10.1,
        noseOffsetFraction: 0.24,
      );

      expect(right.check(turnedRight).isOrientationCorrect, isTrue);
      expect(left.check(turnedRight).isOrientationCorrect, isFalse);
      expect(right.assess(right.check(turnedRight), 0).score, 100);
    });

    test('a saturated yaw is not mistaken for a front view', () {
      // 10.1° would have passed as "front" on the angle alone, handing
      // back a profile photo for a front capture.
      const profile = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.42,
        yawDegrees: -10.1,
        noseOffsetFraction: 0.24,
      );

      expect(front.check(profile).isOrientationCorrect, isFalse);
    });

    test('a big nose offset alone cannot pick a side', () {
      // Without a directional lean there is nothing to say which way
      // the head went, so neither profile passes.
      const ambiguous = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.42,
        yawDegrees: 1,
        noseOffsetFraction: 0.3,
      );

      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);
      const right = FaceCaptureEvaluator(orientation: FaceOrientation.right);

      expect(left.check(ambiguous).isOrientationCorrect, isFalse);
      expect(right.check(ambiguous).isOrientationCorrect, isFalse);
    });

    test('a profile is judged on profile framing, not front framing', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);

      // A turned head hides a cheek, so ML Kit's box is narrower and
      // sits off-centre. Judged by the front thresholds it would fail
      // on framing for doing exactly what it was asked to do.
      const turned = FaceSample(
        faceCount: 1,
        centerX: 0.64,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.27,
        yawDegrees: 30,
        noseOffsetFraction: 0.2,
      );

      expect(front.check(turned).isDistanceOk, isFalse);
      expect(front.check(turned).isCentered, isFalse);

      final conditions = left.check(turned);

      expect(conditions.isDistanceOk, isTrue);
      expect(conditions.isCentered, isTrue);
      expect(conditions.allSatisfied, isTrue);
      expect(left.assess(conditions, 0).score, 100);
    });

    test('a profile still has to be a face, not a sliver', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);

      const tiny = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.12,
        yawDegrees: 30,
        noseOffsetFraction: 0.2,
      );

      expect(left.check(tiny).isDistanceOk, isFalse);
    });

    test('without head pose only a front capture can be assumed', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);

      final noPose = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.42,
      );

      expect(front.check(noPose).isOrientationCorrect, isTrue);
      // Deliberate: accepting an unverifiable profile would hand back a
      // photo that is not what the caller asked for. This is also the
      // shape of the bug that made left/right undetectable on iOS —
      // the detector reported no pose at all, so only front ever
      // passed. See FaceCaptureDetector for why that cannot recur.
      expect(left.check(noPose).isOrientationCorrect, isFalse);
      expect(left.assess(left.check(noPose), 1).isReady, isFalse);
    });
  });

  group('smile requirement', () {
    test('is ignored for a profile capture', () {
      const left = FaceCaptureEvaluator(
        orientation: FaceOrientation.left,
        smileRequired: true,
      );

      // A mouth ML Kit can barely see produces a number that means
      // nothing, so a profile is not gated on it.
      const unsmilingProfile = FaceSample(
        faceCount: 1,
        centerX: 0.5,
        centerY: FaceCaptureGeometry.guideCenterY,
        widthFraction: 0.4,
        yawDegrees: 29,
        noseOffsetFraction: 0.2,
        smileProbability: 0.01,
      );

      final conditions = left.check(unsmilingProfile);

      expect(conditions.smileRequired, isFalse);
      expect(conditions.isSmileSatisfied, isTrue);
      expect(conditions.allSatisfied, isTrue);
      expect(left.assess(conditions, 0).score, 100);
      expect(
        left.assess(conditions, 0).statusOf(FaceCaptureCheck.smile),
        FaceCheckStatus.notApplicable,
      );
    });

    test('still applies to a front capture', () {
      const smilingFront = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        smileRequired: true,
      );

      final unsmiling = smilingFront.check(
        goodSample(orientation: FaceOrientation.front, smile: 0.01),
      );

      expect(unsmiling.smileRequired, isTrue);
      expect(unsmiling.allSatisfied, isFalse);
    });
  });

  group('guidance', () {
    FaceCaptureGuidance guidanceFor(FaceSample sample, {double hold = 0}) {
      return front.assess(front.check(sample), hold).guidance;
    }

    test('asks for a face, then for only one face', () {
      expect(
        guidanceFor(const FaceSample.empty()),
        FaceCaptureGuidance.positionFace,
      );

      expect(
        guidanceFor(
          goodSample(orientation: FaceOrientation.front, faceCount: 3),
        ),
        FaceCaptureGuidance.multipleFaces,
      );
    });

    test('asks about distance before framing', () {
      expect(
        guidanceFor(
          goodSample(orientation: FaceOrientation.front, widthFraction: 0.1),
        ),
        FaceCaptureGuidance.moveCloser,
      );

      expect(
        guidanceFor(
          goodSample(orientation: FaceOrientation.front, widthFraction: 0.9),
        ),
        FaceCaptureGuidance.moveBack,
      );
    });

    test('asks the user to centre an off-centre face', () {
      expect(
        guidanceFor(
          goodSample(orientation: FaceOrientation.front, centerX: 0.9),
        ),
        FaceCaptureGuidance.centerFace,
      );

      expect(
        guidanceFor(
          goodSample(orientation: FaceOrientation.front, centerY: 0.85),
        ),
        FaceCaptureGuidance.centerFace,
      );
    });

    test('asks for the requested pose', () {
      const left = FaceCaptureEvaluator(orientation: FaceOrientation.left);
      const right = FaceCaptureEvaluator(orientation: FaceOrientation.right);

      final straight = goodSample(orientation: FaceOrientation.front);

      expect(
        left.assess(left.check(straight), 0).guidance,
        FaceCaptureGuidance.turnLeft,
      );
      expect(
        right.assess(right.check(straight), 0).guidance,
        FaceCaptureGuidance.turnRight,
      );
    });

    test('asks for a smile last, once framing and pose are right', () {
      const smiling = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        smileRequired: true,
      );

      final unsmiling = goodSample(
        orientation: FaceOrientation.front,
        smile: 0.0,
      );

      expect(
        smiling.assess(smiling.check(unsmiling), 0).guidance,
        FaceCaptureGuidance.smile,
      );
    });

    test('keeps the pose instruction up while the hold runs down', () {
      final good = goodSample(orientation: FaceOrientation.front);
      final assessment = front.assess(front.check(good), 0.4);

      // Not a new instruction — the user is already doing it right;
      // the "hold still" line is what the UI adds on top.
      expect(assessment.guidance, FaceCaptureGuidance.lookStraight);
      expect(assessment.isHolding, isTrue);
    });
  });

  group('status rows', () {
    test('smile reads as not applicable unless it is required', () {
      final assessment = front.assess(
        front.check(goodSample(orientation: FaceOrientation.front)),
        0,
      );

      expect(
        assessment.statusOf(FaceCaptureCheck.smile),
        FaceCheckStatus.notApplicable,
      );
      expect(
        assessment.statusOf(FaceCaptureCheck.face),
        FaceCheckStatus.passed,
      );
      expect(
        assessment.statusOf(FaceCaptureCheck.stability),
        FaceCheckStatus.pending,
      );
    });

    test('stability only passes once the hold is complete', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      expect(
        front.assess(conditions, 0.9).statusOf(FaceCaptureCheck.stability),
        FaceCheckStatus.pending,
      );
      expect(
        front.assess(conditions, 1).statusOf(FaceCaptureCheck.stability),
        FaceCheckStatus.passed,
      );
    });
  });

  group('hold countdown', () {
    test('a three second hold counts 3, 2, 1', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      // Rounded up, so the number shown is the second the user is
      // currently in — the countdown starts at 3, not 2.
      expect(front.assess(conditions, 0).holdCountdownSeconds, 3);
      expect(front.assess(conditions, 0.2).holdCountdownSeconds, 3);
      expect(front.assess(conditions, 0.4).holdCountdownSeconds, 2);
      expect(front.assess(conditions, 0.7).holdCountdownSeconds, 1);
      expect(front.assess(conditions, 0.99).holdCountdownSeconds, 1);
    });

    test('only reaches zero once the capture is actually ready', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      // The user must never watch a "0" that is still waiting.
      expect(front.assess(conditions, 0.999).isReady, isFalse);
      expect(front.assess(conditions, 0.999).holdCountdownSeconds, 1);

      expect(front.assess(conditions, 1).isReady, isTrue);
      expect(front.assess(conditions, 1).holdCountdownSeconds, 0);
    });

    test('follows a custom hold duration', () {
      const quick = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        holdDuration: Duration(seconds: 5),
      );

      final conditions = quick.check(
        goodSample(orientation: FaceOrientation.front),
      );

      expect(quick.assess(conditions, 0).holdCountdownSeconds, 5);
      expect(quick.assess(conditions, 0.5).holdCountdownSeconds, 3);
    });

    test('a sub-second hold still shows something to wait for', () {
      const instant = FaceCaptureEvaluator(
        orientation: FaceOrientation.front,
        holdDuration: Duration(milliseconds: 400),
      );

      final conditions = instant.check(
        goodSample(orientation: FaceOrientation.front),
      );

      expect(instant.assess(conditions, 0).holdCountdownSeconds, 1);
      expect(instant.assess(conditions, 1).holdCountdownSeconds, 0);
    });

    test('a frame short of 100% has nothing to count down', () {
      // Progress can be stale from a moment ago; the countdown is only
      // ever shown for a pose that currently passes everything.
      for (final sample in [
        const FaceSample.empty(),
        goodSample(orientation: FaceOrientation.front, widthFraction: 0.1),
        goodSample(orientation: FaceOrientation.front).copyYaw(40),
      ]) {
        final assessment = front.assess(front.check(sample), 0.8);

        expect(assessment.isHolding, isFalse);
        expect(assessment.score, lessThan(100));
        expect(assessment.holdCountdownSeconds, 0);
      }
    });
  });

  group('readiness label', () {
    test('bands follow the score', () {
      final good = front.check(goodSample(orientation: FaceOrientation.front));
      final none = front.check(const FaceSample.empty());

      expect(front.assess(none, 0).label, FaceReadinessLabel.getReady);
      // Every requirement met reads as "Ready" while the hold runs —
      // the countdown below says what is left to do.
      expect(front.assess(good, 0).label, FaceReadinessLabel.ready);
      expect(front.assess(good, 1).label, FaceReadinessLabel.ready);
    });
  });

  group('rebuild suppression', () {
    test('identical frames are recognized as visually unchanged', () {
      final conditions = front.check(
        goodSample(orientation: FaceOrientation.front),
      );

      final a = front.assess(conditions, 0.5);
      final b = front.assess(conditions, 0.5);
      final c = front.assess(conditions, 0.9);

      expect(a.isVisuallySameAs(b), isTrue);
      expect(a.isVisuallySameAs(c), isFalse);
      expect(a.isVisuallySameAs(null), isFalse);
    });
  });
}

extension on FaceSample {
  /// Same frame, different head angle.
  FaceSample copyYaw(double yaw) {
    return FaceSample(
      faceCount: faceCount,
      centerX: centerX,
      centerY: centerY,
      widthFraction: widthFraction,
      yawDegrees: yaw,
      smileProbability: smileProbability,
    );
  }
}
