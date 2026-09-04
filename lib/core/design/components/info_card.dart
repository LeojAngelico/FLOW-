import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

enum InfoCardKind { info, caution }

/// CMP-13. Non-blocking notice, two kinds (not three — the written
/// design-system summary said info/warning/error, Figma has exactly
/// two). Icon + colored text together carry the meaning, never color
/// alone.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.message,
    this.kind = InfoCardKind.info,
    super.key,
  });

  final String message;
  final InfoCardKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isCaution = kind == InfoCardKind.caution;

    final background = isCaution ? colors.warningSurface : colors.infoSurface;
    final foreground = isCaution ? colors.warning : colors.info;
    final iconAsset = isCaution
        ? 'assets/icons/onboarding/icon-info-filled.svg'
        : 'assets/icons/onboarding/icon-info.svg';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FlowSpacing.md,
        vertical: FlowSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(FlowRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, height: 26, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: FlowSpacing.smMd),
          Expanded(
            child: Text(
              message,
              style: typography.bodyM.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
