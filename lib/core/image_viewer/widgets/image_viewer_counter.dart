import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../ui_kit/tokens/app_radius.dart';
import '../../ui_kit/tokens/app_spacing.dart';

const Color _pillColor = Color(0x66000000);
const Color _onPillColor = Color(0xFFFFFFFF);

/// The "2 / 5" pill.
///
/// Shown only when there is more than one image — a counter that always
/// reads "1 / 1" is noise.
class ImageViewerCounter extends StatelessWidget {
  /// Zero-based position of the visible image.
  final int index;
  final int total;

  const ImageViewerCounter({
    super.key,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final current = index + 1;

    return Semantics(
      // "2 / 5" is fine to read but poor to hear.
      label: loc.imageViewerCounterSemantics(current, total),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: _pillColor,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          loc.imageViewerCounter(current, total),
          style: theme.textTheme.labelLarge?.copyWith(color: _onPillColor),
        ),
      ),
    );
  }
}
