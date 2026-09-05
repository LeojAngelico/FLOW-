import 'package:flutter/material.dart';

import '../../../../../core/design/components/log_row.dart';
import '../../../../../core/design/tokens/flow_colors.dart';
import '../../../../../core/design/tokens/flow_spacing.dart';
import '../../../../../core/design/tokens/flow_typography.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/hydration_entry.dart';

/// `FR-036`: today's entries, newest first, capped at 5 rows. Renders
/// nothing at all when there are no entries yet — the empty-state copy
/// lives in `hydration_summary.dart` instead, so this section doesn't
/// duplicate it.
///
/// No "See all (N)" link: `OVL-12` (the overlay it would open) doesn't
/// exist yet, and a link to nowhere is a dead end (see the workplan's
/// § Explicitly out of scope).
class TodaysLogsSection extends StatelessWidget {
  const TodaysLogsSection({required this.entries, super.key});

  /// Newest first, unbounded — this widget caps the *visible* rows.
  final List<HydrationEntry> entries;

  static const _maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final visible = entries.take(_maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.todaysLogs,
          style: typography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: FlowSpacing.sm),
        for (var i = 0; i < visible.length; i++) ...[
          LogRow(
            amountMl: visible[i].amountMl,
            occurredAt: visible[i].occurredAt.toLocal(),
          ),
          if (i != visible.length - 1) const SizedBox(height: FlowSpacing.sm),
        ],
      ],
    );
  }
}
