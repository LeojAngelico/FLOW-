import 'package:flutter/material.dart';

/// A slow band of light travelling down the face window.
///
/// Deliberately faint: it signals "this is live and looking" without
/// competing with the face. It stops entirely once the capture is
/// ready, and honours the platform's reduce-motion setting — an
/// accessibility need, and a courtesy to anyone who finds moving
/// overlays on their own face unpleasant.
class FaceCaptureSweep extends StatefulWidget {
  /// The face window to sweep inside.
  final Rect guide;

  /// Whether the sweep should run.
  final bool isActive;

  const FaceCaptureSweep({
    super.key,
    required this.guide,
    required this.isActive,
  });

  @override
  State<FaceCaptureSweep> createState() => _FaceCaptureSweepState();
}

class _FaceCaptureSweepState extends State<FaceCaptureSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();

    _syncAnimation();
  }

  @override
  void didUpdateWidget(FaceCaptureSweep oldWidget) {
    super.didUpdateWidget(oldWidget);

    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isActive) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }

      return;
    }

    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (!widget.isActive || reduceMotion) {
      return const SizedBox.shrink();
    }

    final accent = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: widget.guide,
            child: ClipOval(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SweepPainter(
                      progress: _controller.value,
                      color: accent,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Travels top to bottom and back, so there is no jarring jump.
    final t = progress <= 0.5 ? progress * 2 : (1 - progress) * 2;
    final y = size.height * t;
    final band = size.height * 0.18;

    final rect = Rect.fromLTWH(0, y - band / 2, size.width, band);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_SweepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
