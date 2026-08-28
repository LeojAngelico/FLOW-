/// The conditions the readiness score is built from.
///
/// `distance` and `position` are separate rules but share one row in
/// the status panel — the user only cares that their framing is off,
/// not which of the two rules said so.
enum FaceCaptureCheck {
  face,
  position,
  distance,
  orientation,
  smile,
  stability,
}

enum FaceCheckStatus {
  /// Not satisfied yet.
  pending,

  /// Satisfied.
  passed,

  /// Not part of this capture (e.g. smile when it isn't required).
  notApplicable,
}

/// How far the face is from the camera, relative to the guide.
enum FaceDistance { unknown, tooFar, ok, tooClose }

/// The single instruction to show the user, picked from whichever
/// condition is blocking progress.
enum FaceCaptureGuidance {
  positionFace,
  multipleFaces,
  moveCloser,
  moveBack,
  centerFace,
  lookStraight,
  turnLeft,
  turnRight,
  smile,
  holdStill,
  capturing,
  captured,
}

/// Coarse band shown next to the percentage ("Almost there").
enum FaceReadinessLabel { getReady, keepGoing, almostThere, ready }

/// The boolean outcome of every rule for one frame, before stability
/// is taken into account.
class FaceCaptureConditions {
  final int faceCount;
  final bool hasSingleFace;
  final FaceDistance distance;
  final bool isCentered;
  final bool isOrientationCorrect;

  /// True when a smile isn't required, so callers can treat this as
  /// "the smile rule is satisfied" rather than "the user smiled".
  final bool isSmileSatisfied;

  final bool smileRequired;

  const FaceCaptureConditions({
    required this.faceCount,
    required this.hasSingleFace,
    required this.distance,
    required this.isCentered,
    required this.isOrientationCorrect,
    required this.isSmileSatisfied,
    required this.smileRequired,
  });

  bool get isDistanceOk => distance == FaceDistance.ok;

  /// Everything except stability — i.e. "this frame is capturable".
  bool get allSatisfied {
    return hasSingleFace &&
        isDistanceOk &&
        isCentered &&
        isOrientationCorrect &&
        isSmileSatisfied;
  }
}

/// The full, display-ready verdict for one frame.
class FaceCaptureAssessment {
  /// 0–100. Reaches 100 only when [isReady] does — the displayed
  /// number never claims a readiness the scanner hasn't reached.
  final int score;

  /// Whether every rule passes and the hold period has elapsed.
  ///
  /// Decided from the conditions themselves, not from [score]: a
  /// rounded percentage is for the user to read, never what fires the
  /// shutter.
  final bool isReady;

  final Map<FaceCaptureCheck, FaceCheckStatus> checks;

  /// The instruction to show.
  final FaceCaptureGuidance guidance;

  /// Whether to show the "hold still" secondary line — true once the
  /// frame is capturable and only stability remains.
  final bool isHolding;

  /// 0..1 progress through the hold period.
  final double stabilityProgress;

  /// Whole seconds still to hold, for the countdown under the
  /// instruction. Counts down to 1 and reaches 0 only once the capture
  /// is ready, so the user never sees "0" while still waiting.
  final int holdCountdownSeconds;

  const FaceCaptureAssessment({
    required this.score,
    required this.isReady,
    required this.checks,
    required this.guidance,
    required this.isHolding,
    required this.stabilityProgress,
    required this.holdCountdownSeconds,
  });

  FaceReadinessLabel get label {
    // Keyed on the score, not on [isReady]: at 100% every requirement
    // really is met, and the countdown below says what is left to do.
    if (score >= 100) {
      return FaceReadinessLabel.ready;
    }

    if (score >= 70) {
      return FaceReadinessLabel.almostThere;
    }

    if (score >= 30) {
      return FaceReadinessLabel.keepGoing;
    }

    return FaceReadinessLabel.getReady;
  }

  FaceCheckStatus statusOf(FaceCaptureCheck check) {
    return checks[check] ?? FaceCheckStatus.pending;
  }

  /// True when nothing the user can see has changed, so the scanner
  /// can skip a rebuild. Live detection runs many frames a second;
  /// most of them produce an identical screen.
  bool isVisuallySameAs(FaceCaptureAssessment? other) {
    if (other == null) {
      return false;
    }

    if (other.score != score ||
        other.guidance != guidance ||
        other.isHolding != isHolding ||
        other.holdCountdownSeconds != holdCountdownSeconds) {
      return false;
    }

    for (final check in FaceCaptureCheck.values) {
      if (other.statusOf(check) != statusOf(check)) {
        return false;
      }
    }

    return true;
  }
}
