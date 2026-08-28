import '../face_capture_config.dart';
import 'face_capture_assessment.dart';
import 'face_capture_thresholds.dart';
import 'face_sample.dart';

/// Turns a detected face into rules, a score, and one instruction.
///
/// Pure and synchronous — no camera, no ML types, no `BuildContext` —
/// which is what makes the readiness model testable and predictable
/// rather than a black box.
///
/// ## The scoring model
///
/// The score answers one question: **how much of what we need is
/// currently true?** Every rule carries a fixed weight, and the score
/// is the share of the active weight that passes:
///
/// ```
/// score = round(100 * passedWeight / activeWeight)
/// ```
///
/// | Rule | Weight |
/// |---|---|
/// | exactly one face | 2 |
/// | face centred on the guide | 2 |
/// | face at a usable distance | 2 |
/// | head at the requested orientation | 3 |
/// | smile — only when `smileRequired` | 2 |
///
/// Holding still is deliberately **not** one of the weights. It is a
/// separate gate that runs *after* the score reaches 100, which gives
/// the two halves distinct and honest meanings:
///
/// - **100% means every requirement is satisfied** — right now, in
///   this frame. The weights are whole numbers and nothing is graded,
///   so `score == 100` is exactly equivalent to
///   `conditions.allSatisfied`: there is no rounding by which one
///   could be true without the other.
/// - **Then the countdown proves the user can hold it.** `isReady` —
///   the only thing that fires the shutter — additionally requires the
///   hold period to have elapsed with those conditions unbroken. The
///   user sees 100%, watches 3 → 2 → 1, and the photo is taken.
///   Reaching 100% is not itself a capture.
/// - **No face means 0%**, not a partial score. A frame with no face
///   (or more than one) can't satisfy anything else meaningfully, so
///   the score is gated to zero and the ring empties.
class FaceCaptureEvaluator {
  final FaceOrientation orientation;
  final bool smileRequired;
  final FaceCaptureThresholds thresholds;

  /// How long the pose must be held once every requirement passes.
  ///
  /// Only used to turn the hold progress into the seconds shown on
  /// screen; the gate itself is the progress value, so the countdown
  /// and the shutter can never disagree.
  final Duration holdDuration;

  const FaceCaptureEvaluator({
    required this.orientation,
    this.smileRequired = false,
    this.thresholds = const FaceCaptureThresholds(),
    this.holdDuration = const Duration(seconds: 3),
  });

  static const int _faceWeight = 2;
  static const int _positionWeight = 2;
  static const int _distanceWeight = 2;
  static const int _orientationWeight = 3;
  static const int _smileWeight = 2;

  /// Applies every rule except stability to a single frame.
  FaceCaptureConditions check(FaceSample sample) {
    if (!sample.hasSingleFace) {
      return FaceCaptureConditions(
        faceCount: sample.faceCount,
        hasSingleFace: false,
        distance: FaceDistance.unknown,
        isCentered: false,
        isOrientationCorrect: false,
        isSmileSatisfied: !_isSmileRelevant,
        smileRequired: _isSmileRelevant,
      );
    }

    return FaceCaptureConditions(
      faceCount: sample.faceCount,
      hasSingleFace: true,
      distance: _distanceOf(sample),
      isCentered: _isCentered(sample),
      isOrientationCorrect: _isOrientationCorrect(sample),
      isSmileSatisfied: _isSmileSatisfied(sample),
      smileRequired: _isSmileRelevant,
    );
  }

  /// Combines the frame's rules with how long they have held into the
  /// score, the per-rule statuses, and the instruction to show.
  ///
  /// [stabilityProgress] is 0..1 and comes from
  /// `FaceStabilityTracker`.
  FaceCaptureAssessment assess(
    FaceCaptureConditions conditions,
    double stabilityProgress,
  ) {
    final progress = stabilityProgress.clamp(0.0, 1.0);

    final activeWeight =
        _faceWeight +
        _positionWeight +
        _distanceWeight +
        _orientationWeight +
        (_isSmileRelevant ? _smileWeight : 0);

    var passedWeight = 0;

    if (conditions.hasSingleFace) {
      passedWeight += _faceWeight;

      if (conditions.isCentered) {
        passedWeight += _positionWeight;
      }

      if (conditions.isDistanceOk) {
        passedWeight += _distanceWeight;
      }

      if (conditions.isOrientationCorrect) {
        passedWeight += _orientationWeight;
      }

      if (_isSmileRelevant && conditions.isSmileSatisfied) {
        passedWeight += _smileWeight;
      }
    }

    // Gate: nothing is capturable without exactly one face, and a
    // partial score there would be misleading.
    final score = conditions.hasSingleFace
        ? (100 * passedWeight / activeWeight).round()
        : 0;

    // The shutter needs the requirements *and* the hold; reaching 100%
    // only starts the countdown.
    final isReady = conditions.allSatisfied && progress >= 1;

    return FaceCaptureAssessment(
      score: score,
      isReady: isReady,
      checks: _statusesFor(conditions, progress),
      guidance: _guidanceFor(conditions),
      isHolding: conditions.allSatisfied,
      stabilityProgress: progress,
      // Nothing to count down until the score is at 100 — the number
      // is a promise that every other requirement already passed.
      holdCountdownSeconds: conditions.allSatisfied
          ? _countdownFor(progress, isReady: isReady)
          : 0,
    );
  }

  /// Whole seconds left to hold.
  ///
  /// Rounded *up*, so the countdown shows the second the user is
  /// currently in — three seconds of hold reads "3, 2, 1" rather than
  /// starting at 2. It only reaches 0 once the capture is actually
  /// ready, so the number never sits at zero while still waiting.
  int _countdownFor(double progress, {required bool isReady}) {
    if (isReady) {
      return 0;
    }

    final remainingMs = (1 - progress) * holdDuration.inMilliseconds;

    return (remainingMs / Duration.millisecondsPerSecond).ceil().clamp(
      1,
      holdDuration.inSeconds < 1 ? 1 : holdDuration.inSeconds,
    );
  }

  // --------------------------------------------------
  // RULES
  // --------------------------------------------------

  /// Whether this capture is a profile, which is framed differently
  /// from a front view.
  bool get _isProfile => orientation != FaceOrientation.front;

  /// Whether a smile is actually part of *this* capture.
  ///
  /// A smile requirement only applies to a front capture. ML Kit's
  /// smile probability is derived from a mouth it can barely see once
  /// the head is turned, so enforcing it on a profile would gate the
  /// capture on a number that means nothing — the caller's
  /// `smileRequired` is honoured where it can be, and ignored where it
  /// cannot.
  bool get _isSmileRelevant => smileRequired && !_isProfile;

  double get _minWidthFraction {
    return _isProfile
        ? thresholds.profileMinWidthFraction
        : thresholds.minWidthFraction;
  }

  double get _maxCenterOffsetX {
    return _isProfile
        ? thresholds.profileMaxCenterOffsetX
        : thresholds.maxCenterOffsetX;
  }

  FaceDistance _distanceOf(FaceSample sample) {
    final width = sample.widthFraction;

    if (width == null) {
      return FaceDistance.unknown;
    }

    if (width < _minWidthFraction) {
      return FaceDistance.tooFar;
    }

    if (width > thresholds.maxWidthFraction) {
      return FaceDistance.tooClose;
    }

    return FaceDistance.ok;
  }

  bool _isCentered(FaceSample sample) {
    final x = sample.centerX;
    final y = sample.centerY;

    if (x == null || y == null) {
      return false;
    }

    return (x - thresholds.targetCenterX).abs() <= _maxCenterOffsetX &&
        (y - thresholds.targetCenterY).abs() <= thresholds.maxCenterOffsetY;
  }

  /// Whether the head has turned far enough to count, by either
  /// measure.
  ///
  /// The two signals cover for each other: the yaw angle is precise
  /// near the front and saturates on a real profile, while the nose
  /// offset keeps growing all the way round but is coarse near centre.
  bool _isTurnedEnough(FaceSample sample) {
    final yaw = sample.yawDegrees;
    final nose = sample.noseOffsetFraction;

    if (yaw != null && yaw.abs() >= thresholds.turnMinYawDegrees) {
      return true;
    }

    return nose != null && nose >= thresholds.noseTurnOffsetFraction;
  }

  /// Whether the face is looking straight ahead.
  ///
  /// Both signals have to agree. A head turned far enough to show an
  /// ear can report a yaw of ~10°, which is inside the front
  /// tolerance — so a small angle alone is not evidence of a front
  /// view.
  bool _isFacingFront(FaceSample sample) {
    final yaw = sample.yawDegrees;

    if (yaw == null || yaw.abs() > thresholds.frontMaxYawDegrees) {
      return false;
    }

    final nose = sample.noseOffsetFraction;

    return nose == null || nose <= thresholds.noseTurnOffsetFraction;
  }

  bool _isOrientationCorrect(FaceSample sample) {
    final yaw = sample.yawDegrees;

    if (yaw == null) {
      // No head pose reported. A front capture is still a usable photo
      // of a detected, framed, centred face, so it passes — but a
      // profile cannot be verified at all, and silently accepting one
      // would return a photo that is not what the caller asked for.
      //
      // This should not happen with the detector's current options
      // (see FaceCaptureDetector), and the debug overlay shows a dash
      // for the yaw if it ever does.
      return orientation == FaceOrientation.front;
    }

    switch (orientation) {
      case FaceOrientation.front:
        return _isFacingFront(sample);
      // Positive yaw is the user's own left (see FaceCaptureDetector).
      // Direction from the sign, distance from either signal.
      case FaceOrientation.left:
        return _isTurnedEnough(sample) &&
            yaw >= thresholds.turnDirectionMinYawDegrees;
      case FaceOrientation.right:
        return _isTurnedEnough(sample) &&
            yaw <= -thresholds.turnDirectionMinYawDegrees;
    }
  }

  bool _isSmileSatisfied(FaceSample sample) {
    if (!_isSmileRelevant) {
      return true;
    }

    final smile = sample.smileProbability;

    return smile != null && smile >= thresholds.smileMinProbability;
  }

  // --------------------------------------------------
  // PRESENTATION
  // --------------------------------------------------

  Map<FaceCaptureCheck, FaceCheckStatus> _statusesFor(
    FaceCaptureConditions conditions,
    double progress,
  ) {
    FaceCheckStatus of(bool passed) {
      return passed ? FaceCheckStatus.passed : FaceCheckStatus.pending;
    }

    return {
      FaceCaptureCheck.face: of(conditions.hasSingleFace),
      FaceCaptureCheck.position: of(conditions.isCentered),
      FaceCaptureCheck.distance: of(conditions.isDistanceOk),
      FaceCaptureCheck.orientation: of(conditions.isOrientationCorrect),
      FaceCaptureCheck.smile: _isSmileRelevant
          ? of(conditions.isSmileSatisfied)
          : FaceCheckStatus.notApplicable,
      FaceCaptureCheck.stability: of(progress >= 1),
    };
  }

  /// Whichever rule is blocking progress, in the order the user should
  /// fix them. Once nothing is blocking, the orientation line stays up
  /// while the hold completes — the user is doing the right thing and
  /// shouldn't be given a new instruction.
  FaceCaptureGuidance _guidanceFor(FaceCaptureConditions conditions) {
    if (conditions.faceCount == 0) {
      return FaceCaptureGuidance.positionFace;
    }

    if (conditions.faceCount > 1) {
      return FaceCaptureGuidance.multipleFaces;
    }

    switch (conditions.distance) {
      case FaceDistance.tooFar:
        return FaceCaptureGuidance.moveCloser;
      case FaceDistance.tooClose:
        return FaceCaptureGuidance.moveBack;
      case FaceDistance.unknown:
        return FaceCaptureGuidance.positionFace;
      case FaceDistance.ok:
        break;
    }

    if (!conditions.isCentered) {
      return FaceCaptureGuidance.centerFace;
    }

    if (!conditions.isOrientationCorrect) {
      return _orientationGuidance;
    }

    if (!conditions.isSmileSatisfied) {
      return FaceCaptureGuidance.smile;
    }

    return _orientationGuidance;
  }

  FaceCaptureGuidance get _orientationGuidance {
    switch (orientation) {
      case FaceOrientation.front:
        return FaceCaptureGuidance.lookStraight;
      case FaceOrientation.left:
        return FaceCaptureGuidance.turnLeft;
      case FaceOrientation.right:
        return FaceCaptureGuidance.turnRight;
    }
  }
}
