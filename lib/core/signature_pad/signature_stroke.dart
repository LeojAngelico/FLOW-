import 'dart:ui';

/// One continuous pen-down-to-pen-up mark.
///
/// Plain geometry with its own colour and width, so a stroke can be
/// painted, measured and bounded without a canvas — which is what lets
/// the export crop analytically instead of scanning pixels.
class SignatureStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  const SignatureStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  bool get isEmpty => points.isEmpty;

  /// Total distance the pen travelled, in logical pixels.
  ///
  /// Used to tell a signature from a stray tap: a single touch has
  /// length zero however many frames it lasted.
  double get length {
    var total = 0.0;

    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }

    return total;
  }

  /// The area this stroke covers, including the width of the pen —
  /// so inflating by half the stroke width never clips an end cap.
  Rect? get bounds {
    if (points.isEmpty) {
      return null;
    }

    var left = points.first.dx;
    var top = points.first.dy;
    var right = left;
    var bottom = top;

    for (final point in points) {
      if (point.dx < left) left = point.dx;
      if (point.dx > right) right = point.dx;
      if (point.dy < top) top = point.dy;
      if (point.dy > bottom) bottom = point.dy;
    }

    return Rect.fromLTRB(left, top, right, bottom).inflate(width / 2);
  }
}
