import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_typography.dart';
import 'flow_frame_box.dart';
import 'flow_tappable.dart';

/// CMP-05. Two verified variants: `/Unit` (2 segments, segmentHeight 48
/// -> 56dp shell) and `/Sex` (3 segments, segmentHeight 56 -> 64dp
/// shell, wrapping enabled — a "WRAP FIX" the Figma file itself notes
/// was needed for "Prefer not to say" to stay legible). Selection is
/// three cues: brand fill + 2dp ink frame + a pixel check — never color
/// alone.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    this.segmentHeight = 48,
    super.key,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final double segmentHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    // The border lives in `foregroundDecoration`, not `decoration`: this
    // Container has no explicit height, so it shrink-wraps its Row child
    // (segmentHeight + this 4dp padding on each side). A border placed
    // on `decoration` adds its own width to that shrink-wrapped size
    // (BoxDecoration.padding == border.dimensions), which pushed the
    // measured shell height 4dp past the 56dp/64dp the brief specifies.
    // `foregroundDecoration` paints on top without affecting layout size.
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(FlowRadius.sm),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(FlowRadius.sm),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FlowTappable(
                  onTap: () => onChanged(option),
                  selected: option == selected,
                  child: option == selected
                      ? FlowFrameBox(
                          fill: colors.brandPrimary,
                          frameInk: colors.frameInk,
                          radius: 5,
                          bevelColor: colors.frameBevel,
                          child: SizedBox(
                            height: segmentHeight,
                            child: Center(
                              child: Text(
                                labelBuilder(option).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: typography.buttonGame.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: segmentHeight,
                          child: Center(
                            child: Text(
                              labelBuilder(option).toUpperCase(),
                              textAlign: TextAlign.center,
                              style: typography.buttonGame.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
