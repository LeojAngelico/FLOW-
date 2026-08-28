import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';
import 'detection/face_capture_assessment.dart';
import 'face_capture_config.dart';

/// Resolves face capture enums into localized text.
///
/// Mirrors `ErrorLocalizer`: the detection layer deals in enums so it
/// stays free of presentation concerns, and this is the single place
/// those enums become words. A missing case is a compile error, not a
/// blank instruction on screen.
class FaceCaptureLocalizer {
  FaceCaptureLocalizer._();

  static String guidance(BuildContext context, FaceCaptureGuidance guidance) {
    final loc = AppLocalizations.of(context)!;

    switch (guidance) {
      case FaceCaptureGuidance.positionFace:
        return loc.faceCaptureGuidancePositionFace;
      case FaceCaptureGuidance.multipleFaces:
        return loc.faceCaptureGuidanceMultipleFaces;
      case FaceCaptureGuidance.moveCloser:
        return loc.faceCaptureGuidanceMoveCloser;
      case FaceCaptureGuidance.moveBack:
        return loc.faceCaptureGuidanceMoveBack;
      case FaceCaptureGuidance.centerFace:
        return loc.faceCaptureGuidanceCenterFace;
      case FaceCaptureGuidance.lookStraight:
        return loc.faceCaptureGuidanceLookStraight;
      case FaceCaptureGuidance.turnLeft:
        return loc.faceCaptureGuidanceTurnLeft;
      case FaceCaptureGuidance.turnRight:
        return loc.faceCaptureGuidanceTurnRight;
      case FaceCaptureGuidance.smile:
        return loc.faceCaptureGuidanceSmile;
      case FaceCaptureGuidance.holdStill:
        return loc.faceCaptureGuidanceHoldStill;
      case FaceCaptureGuidance.capturing:
        return loc.faceCaptureGuidanceCapturing;
      case FaceCaptureGuidance.captured:
        return loc.faceCaptureGuidanceCaptured;
    }
  }

  /// "Hold still... 3" — the seconds left before the photo is taken.
  static String holdCountdown(BuildContext context, int seconds) {
    return AppLocalizations.of(
      context,
    )!.faceCaptureGuidanceHoldStillCountdown(seconds);
  }

  static String readiness(BuildContext context, FaceReadinessLabel label) {
    final loc = AppLocalizations.of(context)!;

    switch (label) {
      case FaceReadinessLabel.getReady:
        return loc.faceCaptureReadinessGetReady;
      case FaceReadinessLabel.keepGoing:
        return loc.faceCaptureReadinessKeepGoing;
      case FaceReadinessLabel.almostThere:
        return loc.faceCaptureReadinessAlmostThere;
      case FaceReadinessLabel.ready:
        return loc.faceCaptureReadinessReady;
    }
  }

  static String orientation(BuildContext context, FaceOrientation orientation) {
    final loc = AppLocalizations.of(context)!;

    switch (orientation) {
      case FaceOrientation.front:
        return loc.faceOrientationFront;
      case FaceOrientation.left:
        return loc.faceOrientationLeft;
      case FaceOrientation.right:
        return loc.faceOrientationRight;
    }
  }

  /// Label for a row of the status panel.
  static String checkLabel(BuildContext context, FaceCaptureCheck check) {
    final loc = AppLocalizations.of(context)!;

    switch (check) {
      case FaceCaptureCheck.face:
        return loc.faceCaptureStatusFace;
      case FaceCaptureCheck.position:
      case FaceCaptureCheck.distance:
        return loc.faceCaptureStatusPosition;
      case FaceCaptureCheck.orientation:
        return loc.faceCaptureStatusOrientation;
      case FaceCaptureCheck.stability:
        return loc.faceCaptureStatusStability;
      case FaceCaptureCheck.smile:
        return loc.faceCaptureStatusSmile;
    }
  }

  /// Value for a row of the status panel.
  static String checkValue(
    BuildContext context,
    FaceCaptureCheck check,
    FaceCheckStatus status,
  ) {
    final loc = AppLocalizations.of(context)!;

    switch (status) {
      case FaceCheckStatus.notApplicable:
        return loc.faceCaptureStatusNotApplicable;
      case FaceCheckStatus.passed:
        return check == FaceCaptureCheck.face
            ? loc.faceCaptureStatusDetected
            : loc.faceCaptureStatusGood;
      case FaceCheckStatus.pending:
        return loc.faceCaptureStatusWaiting;
    }
  }
}
