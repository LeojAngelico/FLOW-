import 'dart:math' as math;
import 'dart:ui';

import 'face_sample.dart';

/// Maps a face box from camera-image space onto the preview the user
/// is actually looking at.
///
/// This matters more than it sounds: the preview is drawn with
/// `BoxFit.cover`, so a 4:3 camera image on a tall phone is scaled up
/// and cropped. Without this correction, "centred in the image" and
/// "centred in the guide circle" are different places, and the scanner
/// would ask people to move a face that already looks centred to them.
///
/// Pure geometry — no camera or ML types — so it can be unit tested.
class FaceSurfaceProjection {
  /// Size of the image *after* rotation, i.e. the upright image the
  /// detector reported coordinates in.
  final Size imageSize;

  /// Logical size of the on-screen preview.
  final Size surfaceSize;

  /// Whether the preview is mirrored (front cameras are, so the user
  /// sees themselves as in a mirror).
  final bool mirrored;

  const FaceSurfaceProjection({
    required this.imageSize,
    required this.surfaceSize,
    required this.mirrored,
  });

  /// The `BoxFit.cover` scale factor.
  double get scale {
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return 1;
    }

    return math.max(
      surfaceSize.width / imageSize.width,
      surfaceSize.height / imageSize.height,
    );
  }

  /// Builds the normalized sample the readiness rules work on.
  FaceSample sample({
    required int faceCount,
    required Rect bounds,
    double? yawDegrees,
    double? smileProbability,
    double? noseOffsetFraction,
  }) {
    if (surfaceSize.width <= 0 || surfaceSize.height <= 0) {
      return const FaceSample.empty();
    }

    final scaled = scale;

    // Offsets of the cropped-away parts, split evenly by cover.
    final dx = (imageSize.width * scaled - surfaceSize.width) / 2;
    final dy = (imageSize.height * scaled - surfaceSize.height) / 2;

    final centerX = (bounds.center.dx * scaled - dx) / surfaceSize.width;
    final centerY = (bounds.center.dy * scaled - dy) / surfaceSize.height;

    return FaceSample(
      faceCount: faceCount,
      // Mirroring only flips the axis; the guide is centred, so this
      // does not change whether the face passes, but it keeps the
      // coordinate honest about what the user sees.
      centerX: mirrored ? 1 - centerX : centerX,
      centerY: centerY,
      widthFraction: (bounds.width * scaled) / surfaceSize.width,
      yawDegrees: yawDegrees,
      smileProbability: smileProbability,
      // A ratio inside the face box, so the surface projection does
      // not apply to it.
      noseOffsetFraction: noseOffsetFraction,
    );
  }
}
