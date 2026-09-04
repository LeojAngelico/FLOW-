import 'package:flutter/material.dart';

import '../../../../../core/design/components/quick_add_chip.dart';
import '../../../../../core/design/tokens/flow_colors.dart';
import '../../../../../core/design/tokens/flow_spacing.dart';
import '../../../../../core/design/tokens/flow_typography.dart';
import '../../../../../core/utils/volume_format.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// `FR-020`/`FR-021`: one tap on a [QuickAddChip] logs an entry
/// immediately, no confirmation. The four default amounts are
/// hardcoded, ascending, per `FR-021` — configurable quick-add amounts
/// (`FR-022`) need `APP-10`, out of scope this pass (see the workplan's
/// § Explicitly out of scope).
///
/// Horizontally scrollable under 400dp so the row never overflows on a
/// narrow phone; laid out as an evenly-spaced row above that width.
/// Stays **enabled** after goal completion — only de-emphasised
/// (`FR-033` allows logging past 100%) — per the workplan's Manual QA
/// item 10.
class QuickAddRow extends StatelessWidget {
  const QuickAddRow({
    required this.goalCompleted,
    required this.onQuickAdd,
    super.key,
  });

  final bool goalCompleted;
  final ValueChanged<int> onQuickAdd;

  /// `FR-021`'s default set, ascending.
  static const quickAddAmountsMl = <int>[150, 250, 350, 500];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.quickAdd,
          style: typography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: FlowSpacing.sm),
        Opacity(
          // De-emphasised, not disabled — a completed goal must not
          // stop further logging.
          opacity: goalCompleted ? 0.6 : 1.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chips = [
                for (final amount in quickAddAmountsMl) _chip(loc, amount),
              ];

              if (constraints.maxWidth < 400) {
                return SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: chips.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: FlowSpacing.sm),
                    itemBuilder: (context, index) => chips[index],
                  ),
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    Expanded(child: chips[i]),
                    if (i != chips.length - 1)
                      const SizedBox(width: FlowSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(AppLocalizations loc, int amountMl) {
    // `QuickAddChip` (CMP-04, pre-existing) folds its own visible
    // "150 ML" text into the accessible name via `FlowTappable`. This
    // outer override replaces that with an explicit action announcement
    // ("Add 250 ml") — see the workplan's Manual QA item 7 ("Chips must
    // announce 'Add 250 millilitres' with a button role").
    return Semantics(
      button: true,
      label: loc.quickAddChipSemantics(formatVolumeMl(amountMl)),
      child: ExcludeSemantics(
        child: QuickAddChip(
          amountMl: amountMl,
          selected: false,
          onTap: () => onQuickAdd(amountMl),
        ),
      ),
    );
  }
}
