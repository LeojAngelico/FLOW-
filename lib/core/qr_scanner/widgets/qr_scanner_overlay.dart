import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_spacing.dart';

// The scanner draws on top of a live camera image, not on a themed
// surface, so these three values are deliberately fixed instead of
// coming from the ColorScheme: a light theme's `onSurface` would be
// invisible over a bright camera frame. Everything that is *not* on top
// of the camera (permission and error states) uses the app theme.
const Color _scrimColor = Color(0x99000000);
const Color _frameColor = Color(0xFFFFFFFF);
const Color _instructionColor = Color(0xCCFFFFFF);

/// The scanning overlay: a dimmed screen with a square cut-out, corner
/// markers, and the "what do I do" copy above it.
///
/// Purely presentational — it neither owns the camera nor knows what a
/// scanned value means. The cut-out is also used as the scanner's scan
/// window, so what the user sees framed is exactly what gets decoded.
class QrScannerOverlay extends StatelessWidget {
  /// The scan frame, in the coordinate space of the scanner surface.
  final Rect frame;

  final String title;
  final String instruction;

  /// Highlights the frame in the theme's primary color for the brief
  /// moment between a successful scan and the scanner closing.
  final bool isSuccess;

  const QrScannerOverlay({
    super.key,
    required this.frame,
    required this.title,
    required this.instruction,
    this.isSuccess = false,
  });

  /// The centered square scan frame for a scanner surface of [size].
  ///
  /// [sizeFactor] is a fraction of the shorter side; the result is also
  /// capped at half the height so the copy above it always has room.
  static Rect frameFor(Size size, double sizeFactor) {
    final side = math.min(size.shortestSide * sizeFactor, size.height / 2);

    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanFramePainter(
                frame: frame,
                color: isSuccess ? theme.colorScheme.primary : _frameColor,
              ),
            ),
          ),

          // Sits in the band above the frame, anchored to the frame so
          // the copy and the cut-out never drift apart.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: frame.top,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _frameColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      instruction,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _instructionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dims everything outside [frame] and draws the four corner markers.
class _ScanFramePainter extends CustomPainter {
  final Rect frame;
  final Color color;

  const _ScanFramePainter({required this.frame, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(frame),
    );

    canvas.drawPath(scrim, Paint()..color = _scrimColor);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    // Marker arms stay proportional to the frame but never grow long
    // enough to read as a full border.
    final arm = (frame.width * 0.18).clamp(20.0, 44.0);

    final corners = Path()
      // Top-left.
      ..moveTo(frame.left, frame.top + arm)
      ..lineTo(frame.left, frame.top)
      ..lineTo(frame.left + arm, frame.top)
      // Top-right.
      ..moveTo(frame.right - arm, frame.top)
      ..lineTo(frame.right, frame.top)
      ..lineTo(frame.right, frame.top + arm)
      // Bottom-right.
      ..moveTo(frame.right, frame.bottom - arm)
      ..lineTo(frame.right, frame.bottom)
      ..lineTo(frame.right - arm, frame.bottom)
      // Bottom-left.
      ..moveTo(frame.left + arm, frame.bottom)
      ..lineTo(frame.left, frame.bottom)
      ..lineTo(frame.left, frame.bottom - arm);

    canvas.drawPath(corners, stroke);
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.color != color;
  }
}
