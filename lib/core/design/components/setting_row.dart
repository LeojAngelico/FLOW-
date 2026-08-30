import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-14. 56dp row, opens a native time picker or interval sheet
/// (wiring is the caller's job via [onTap]). Carries the full pixel
/// frame treatment, not a plain chevron row. The chevron reuses
/// CMP-42's chevron-left asset, rotated 180 degrees — one icon file
/// across all of onboarding, per the Figma file's own note.
class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: 2),
          // 8 matches FlowRadius.sm.
          borderRadius: BorderRadius.circular(FlowRadius.sm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyL.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              value,
              style: typography.bodyL.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: FlowSpacing.sm),
            Transform.rotate(
              angle: pi,
              child: SizedBox(
                width: 14,
                height: 22,
                child: SvgPicture.asset(
                  'assets/icons/onboarding/icon-chevron-left.svg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
