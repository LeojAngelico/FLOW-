import 'face_capture_geometry.dart';

/// The numbers behind the readiness rules.
///
/// Kept out of `FaceCaptureConfig` on purpose: callers should be able
/// to ask for "left profile, smiling" without also having to hold an
/// opinion about acceptable yaw. They are gathered here, with their
/// reasoning, so tuning them is a one-file job.
class FaceCaptureThresholds {
  /// Smallest acceptable face width, as a fraction of the surface
  /// width. Below this the face is too far for a usable photo.
  final double minWidthFraction;

  /// Largest acceptable face width. Above this the face is cropped by
  /// the guide and usually badly lit.
  final double maxWidthFraction;

  /// How far the face centre may sit from the guide centre,
  /// horizontally and vertically, in surface fractions. Vertical is
  /// looser because people naturally hold a phone low.
  final double maxCenterOffsetX;
  final double maxCenterOffsetY;

  /// Front-facing tolerance. Nobody holds their head perfectly square,
  /// so this is generous.
  final double frontMaxYawDegrees;

  /// How far the head must turn to count as a profile. Deliberately
  /// modest — a natural glance, not a contortion. There is no upper
  /// bound: if detection still works at a sharper angle, that passes
  /// too.
  final double turnMinYawDegrees;

  /// Yaw needed merely to say *which* side the head turned toward.
  ///
  /// Small on purpose. The sign of the angle stays trustworthy long
  /// after its magnitude does, so direction is read from a light lean
  /// while the decision about whether it is a real turn is made by
  /// [turnMinYawDegrees] or [noseTurnOffsetFraction].
  final double turnDirectionMinYawDegrees;

  /// Nose displacement, as a fraction of the face box width, that
  /// separates "looking ahead" from "turned".
  ///
  /// Used from both sides of the same line: a front capture requires
  /// the nose to stay within it, and a profile passes on reaching it
  /// even if the yaw angle has saturated below
  /// [turnMinYawDegrees] — which it does on a real profile.
  final double noseTurnOffsetFraction;

  /// Smile probability that counts as a smile.
  final double smileMinProbability;

  /// Distance and framing limits for a profile capture.
  ///
  /// A turned head is not just a rotated front view: ML Kit's box
  /// covers less width once a cheek is hidden, and the visible face
  /// shifts toward the direction of the turn. Judging a profile by the
  /// front thresholds therefore fails it on framing for doing exactly
  /// what it was asked to do.
  final double profileMinWidthFraction;
  final double profileMaxCenterOffsetX;

  const FaceCaptureThresholds({
    this.minWidthFraction = 0.30,
    this.maxWidthFraction = 0.62,
    this.maxCenterOffsetX = 0.12,
    this.maxCenterOffsetY = 0.10,
    this.frontMaxYawDegrees = 14,
    this.turnMinYawDegrees = 15,
    this.turnDirectionMinYawDegrees = 4,
    this.noseTurnOffsetFraction = 0.14,
    this.smileMinProbability = 0.55,
    this.profileMinWidthFraction = 0.24,
    this.profileMaxCenterOffsetX = 0.18,
  });

  /// Where the face is expected to be, matching the drawn guide.
  double get targetCenterX => 0.5;
  double get targetCenterY => FaceCaptureGeometry.guideCenterY;
}
