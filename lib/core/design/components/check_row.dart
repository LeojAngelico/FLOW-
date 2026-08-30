import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-12. 48dp tall (full-row hit target), true checkbox semantics.
/// Checked = brand.primary fill + pixel check icon + 2dp frame — three
/// cues, matching the unit-toggle and step-track pattern rather than
/// color alone.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    required this.checked,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Semantics(
      checked: checked,
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? colors.brandPrimary : colors.surfacePrimary,
                  border: Border.all(color: colors.frameInk, width: 2),
                  // 5px has no matching FlowRadius token (sm=8, md=12,
                  // lg=16, xl=24, quickAddChip=10) — genuine one-off for
                  // this small checkbox glyph.
                  borderRadius: BorderRadius.circular(5),
                ),
                child: checked
                    ? SvgPicture.asset(
                        'assets/icons/onboarding/icon-check.svg',
                        width: 14,
                        height: 10,
                      )
                    : null,
              ),
              const SizedBox(width: FlowSpacing.smMd),
              Text(
                label,
                style: typography.bodyL.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
