import 'package:flutter/material.dart';

import '../tokens/flow_radius.dart';

/// The pixel-frame recipe shared by nearly every CMP-* component: a
/// [fill] with a 2dp [frameInk] border, an optional solid [depth]
/// offset beneath it (never blurred — collapses to 0 for a pressed
/// state), and an optional inner top bevel highlight line.
class FlowFrameBox extends StatelessWidget {
  const FlowFrameBox({
    required this.child,
    required this.fill,
    required this.frameInk,
    this.radius = FlowRadius.sm,
    this.depth = 0,
    this.depthColor,
    this.bevelColor,
    this.borderWidth = 2,
    super.key,
  });

  final Widget child;
  final Color fill;
  final Color frameInk;
  final double radius;
  final double depth;
  final Color? depthColor;
  final Color? bevelColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    // The border lives in `foregroundDecoration`, not `decoration`: a
    // border on `decoration` makes Container add border-width padding to
    // its own layout size (BoxDecoration.padding == border.dimensions),
    // which would silently grow this box past the caller's child height.
    final content = Container(
      decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: frameInk, width: borderWidth),
      ),
      child: bevelColor == null
          ? child
          : Stack(
              children: [
                child,
                Positioned(
                  top: borderWidth,
                  left: borderWidth,
                  right: borderWidth,
                  child: Container(height: 2, color: bevelColor),
                ),
              ],
            ),
    );

    if (depth <= 0) {
      return content;
    }

    return Stack(
      children: [
        Positioned(
          top: depth,
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: depthColor,
              borderRadius: borderRadius,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: content,
        ),
      ],
    );
  }
}
