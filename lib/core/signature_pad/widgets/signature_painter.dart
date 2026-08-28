import 'dart:ui' show PointMode;

import 'package:flutter/rendering.dart';

import '../signature_stroke.dart';

/// Paints signature strokes — and **nothing else**.
///
/// No background fill, no border, no placeholder. That is deliberate:
/// this same painter draws the on-screen preview and the exported
/// image, so "the PNG contains only the strokes" is true by
/// construction rather than something to verify by eye. Anything that
/// belongs to the pad's chrome is painted by other widgets around it.
class SignaturePainter extends CustomPainter {
  final List<SignatureStroke> strokes;

  const SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.isEmpty) {
        continue;
      }

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        // Round caps and joins are what make a drawn line read as ink
        // rather than as a series of segments.
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      final points = stroke.points;

      // A tap with no movement still deserves a mark, and a zero
      // length path draws nothing.
      if (points.length == 1) {
        canvas.drawPoints(PointMode.points, points, paint);
        continue;
      }

      canvas.drawPath(pathFor(points), paint);
    }
  }

  /// Builds a smoothed path through [points].
  ///
  /// Straight segments between raw touch samples look faceted, because
  /// the samples arrive far apart when the finger moves quickly. Each
  /// sample is instead used as the control point of a quadratic curve
  /// ending at the midpoint of the next segment — the standard
  /// midpoint smoothing, which keeps the line inside the gesture while
  /// rounding the corners off.
  static Path pathFor(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);

      return path;
    }

    for (var i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      path.quadraticBezierTo(current.dx, current.dy, midpoint.dx, midpoint.dy);
    }

    // Finish on the last real sample so the stroke ends where the
    // finger lifted, not at a midpoint.
    path.lineTo(points.last.dx, points.last.dy);

    return path;
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    // Strokes are mutated in place while drawing, so identity is not a
    // safe test — the controller notifies on every point.
    return true;
  }
}
