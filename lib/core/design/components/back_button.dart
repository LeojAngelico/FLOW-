import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import 'flow_frame_box.dart';

/// CMP-42. 48x48dp touch target, framed to match the button system but
/// with a shallower 3dp depth than CMP-01's 4dp, so it reads as
/// secondary. Onboarding uses no Material Symbols — this is the bundled
/// pixel chevron-left asset, reused (rotated) by CMP-14 SettingRow.
class FlowBackButton extends StatelessWidget {
  const FlowBackButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;

    return GestureDetector(
      onTap: onPressed,
      child: FlowFrameBox(
        fill: colors.surfacePrimary,
        frameInk: colors.frameInk,
        depth: 3,
        depthColor: colors.frameDepth,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 22,
              child: SvgPicture.asset(
                'assets/icons/onboarding/icon-chevron-left.svg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
