import 'dart:math' as math;
import 'dart:ui';

/// Where the face guide sits on screen.
///
/// This is shared, not duplicated, on purpose: the ring the user aims
/// at and the target the readiness score is measured against have to
/// be the same circle, or the scanner would tell people to centre
/// their face somewhere other than where the guide is drawn.
class FaceCaptureGeometry {
  FaceCaptureGeometry._();

  /// Vertical centre of the guide, as a fraction of the surface
  /// height. Above the middle, to leave room for the guidance copy
  /// and the status panel underneath.
  static const double guideCenterY = 0.42;

  /// Guide diameter as a fraction of the shorter side.
  static const double guideDiameterFactor = 0.68;

  /// The guide circle for a scanner surface of [size].
  static Rect guideCircle(Size size) {
    final diameter = math.min(
      size.shortestSide * guideDiameterFactor,
      size.height * 0.55,
    );

    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height * guideCenterY),
      radius: diameter / 2,
    );
  }
}
