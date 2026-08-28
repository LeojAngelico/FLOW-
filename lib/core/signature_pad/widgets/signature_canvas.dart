import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_radius.dart';
import '../../ui_kit/tokens/app_spacing.dart';
import '../signature_pad_controller.dart';
import 'signature_painter.dart';

/// The signing area: a dashed frame the user draws inside.
///
/// The frame, the hint and the ink are separate layers on purpose —
/// only the ink layer is ever exported.
class SignatureCanvas extends StatelessWidget {
  final SignaturePadController controller;

  /// Faint placeholder shown while the area is empty. Null or empty
  /// hides it.
  final String? hint;

  /// Announced in place of the drawing area.
  final String semanticLabel;

  const SignatureCanvas({
    super.key,
    required this.controller,
    this.hint,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      // The area is a drawing surface, not a control: describing it is
      // useful, but it must not swallow the touch events that draw.
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: theme.colorScheme.outlineVariant,
            radius: AppRadius.lg,
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (controller.isEmpty && (hint?.isNotEmpty ?? false))
                    // Ignores pointers so it can never intercept the
                    // first stroke.
                    IgnorePointer(
                      child: Center(
                        child: Text(
                          hint!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),

                  // The ink layer. Nothing else paints inside it, which
                  // is what the export relies on.
                  Positioned.fill(
                    child: _DrawingSurface(controller: controller),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Turns touches into strokes.
class _DrawingSurface extends StatelessWidget {
  final SignaturePadController controller;

  const _DrawingSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Listener rather than GestureDetector: pointer events arrive
      // without waiting for the gesture arena to decide, so the first
      // millimetre of a stroke is not lost, and a stylus reports the
      // same way as a finger.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => controller.startStroke(event.localPosition),
      onPointerMove: (event) => controller.extendStroke(event.localPosition),
      child: CustomPaint(
        painter: SignaturePainter(strokes: controller.strokes),
        size: Size.infinite,
      ),
    );
  }
}

/// The dashed frame from the design. Flutter has no dashed border, and
/// a solid one reads as an input field rather than a place to sign.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  static const double _dash = 6;
  static const double _gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ).deflate(AppSpacing.xs / 2),
          Radius.circular(radius),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;

      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);

        canvas.drawPath(metric.extractPath(distance, end), paint);

        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
