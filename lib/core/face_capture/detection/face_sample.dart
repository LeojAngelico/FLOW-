/// One frame's worth of face detection, normalized and stripped of
/// every ML Kit type.
///
/// Coordinates are fractions of the camera surface (0..1), so the
/// readiness rules can be reasoned about — and unit tested — without a
/// camera, an image, or a device orientation in sight.
class FaceSample {
  /// How many faces the frame contained.
  final int faceCount;

  /// Centre of the largest face, as a fraction of the surface.
  final double? centerX;
  final double? centerY;

  /// Face width as a fraction of the surface width.
  final double? widthFraction;

  /// Head yaw in degrees.
  ///
  /// **Positive means the user turned toward their own left.** See
  /// `FaceCaptureDetector` for where that sign is established, and
  /// `Instructions.md` for the one-line fix if a device reports it the
  /// other way round.
  final double? yawDegrees;

  /// Smile probability (0..1), or null when classification is off.
  final double? smileProbability;

  /// How far the nose sits from the middle of the face box, as an
  /// unsigned fraction of the box width.
  ///
  /// Near zero for a face looking straight ahead, and it keeps growing
  /// as the head turns — including past the point where the yaw angle
  /// stops being reliable. Direction still comes from the yaw's sign.
  final double? noseOffsetFraction;

  const FaceSample({
    required this.faceCount,
    this.centerX,
    this.centerY,
    this.widthFraction,
    this.yawDegrees,
    this.smileProbability,
    this.noseOffsetFraction,
  });

  /// No face in this frame.
  const FaceSample.empty() : this(faceCount: 0);

  bool get hasSingleFace => faceCount == 1;
}
