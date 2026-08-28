import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_motion.dart';

// The scanner draws over a live camera image, so these are fixed
// rather than theme colours: an `onSurface` from the light theme would
// vanish against a bright face. Every colour that is *not* over the
// camera comes from the theme.
const Color _scrimColor = Color(0xB3000000);
const Color _trackColor = Color(0x33FFFFFF);
const Color _bracketColor = Color(0x8AFFFFFF);

/// What the guide is currently communicating.
enum FaceGuideState { detecting, ready, capturing, captured }

/// The face guide: a dimmed screen with a clear circular window, a
/// readiness ring around it, and corner brackets.
///
/// The window is the whole point — the face stays unobstructed and
/// fully lit while everything around it recedes.
class FaceCaptureRing extends StatelessWidget {
  /// The guide circle, from `FaceCaptureGeometry.guideCircle`.
  final Rect guide;

  /// Readiness, 0–100. Drives the arc length.
  final int score;

  final FaceGuideState state;

  const FaceCaptureRing({
    super.key,
    required this.guide,
    required this.score,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Success reads as `tertiary` across this design system (see
    // AppSnackbar.success), so the ready/captured ring follows suit
    // and re-themes with the rest of the app.
    final accent = switch (state) {
      FaceGuideState.detecting => scheme.primary,
      FaceGuideState.ready => scheme.tertiary,
      FaceGuideState.capturing => scheme.tertiary,
      FaceGuideState.captured => scheme.tertiary,
    };

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        // The arc animates *to* a measured value; it is never a timer
        // running on its own.
        tween: Tween<double>(end: score / 100),
        duration: AppMotion.medium,
        curve: Curves.easeOut,
        builder: (context, progress, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _FaceGuidePainter(
              guide: guide,
              progress: progress,
              accent: accent,
              isEmphasized: state != FaceGuideState.detecting,
            ),
          );
        },
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  final Rect guide;
  final double progress;
  final Color accent;
  final bool isEmphasized;

  const _FaceGuidePainter({
    required this.guide,
    required this.progress,
    required this.accent,
    required this.isEmphasized,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Path()..addOval(guide);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        circle,
      ),
      Paint()..color = _scrimColor,
    );

    // The ring sits just outside the window so it never crops the face.
    final ringRect = guide.inflate(10);

    canvas.drawArc(
      ringRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = _trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    if (progress > 0) {
      canvas.drawArc(
        ringRect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = isEmphasized ? 6 : 5
          ..strokeCap = StrokeCap.round,
      );
    }

    _paintBrackets(canvas);
  }

  /// Four short corner markers around the window — the reference's
  /// framing cue, kept subtle so it reads as guidance, not chrome.
  void _paintBrackets(Canvas canvas) {
    final box = guide.inflate(22);
    final arm = (box.width * 0.12).clamp(14.0, 30.0);

    final paint = Paint()
      ..color = isEmphasized ? accent : _bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(box.left, box.top + arm)
      ..lineTo(box.left, box.top)
      ..lineTo(box.left + arm, box.top)
      ..moveTo(box.right - arm, box.top)
      ..lineTo(box.right, box.top)
      ..lineTo(box.right, box.top + arm)
      ..moveTo(box.right, box.bottom - arm)
      ..lineTo(box.right, box.bottom)
      ..lineTo(box.right - arm, box.bottom)
      ..moveTo(box.left + arm, box.bottom)
      ..lineTo(box.left, box.bottom)
      ..lineTo(box.left, box.bottom - arm);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) {
    return oldDelegate.guide != guide ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.isEmphasized != isEmphasized;
  }
}
