import 'package:flutter/material.dart';

import '../tokens/flow_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Whether a [CtaSection] renders one button or a primary + secondary
/// pair.
enum CtaSectionVariant {
  /// A single [PrimaryButton].
  primary,

  /// A [PrimaryButton] over a [SecondaryButton] (e.g. Accept over
  /// Adjust on `ONB-07`).
  primaryAndSecondary,
}

/// CMP-45. The footer on all seven onboarding form screens; owns the
/// safe-area inset and the gap between the buttons so it is identical
/// everywhere instead of re-typed on every screen.
class CtaSection extends StatelessWidget {
  const CtaSection({
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.variant = CtaSectionVariant.primary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondaryPressed,
    super.key,
  }) : assert(
         variant == CtaSectionVariant.primary || secondaryLabel != null,
         'CtaSectionVariant.primaryAndSecondary requires a secondaryLabel',
       );

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final CtaSectionVariant variant;
  final bool primaryLoading;

  /// Required when [variant] is [CtaSectionVariant.primaryAndSecondary].
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: FlowSpacing.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlowSpacing.md,
          FlowSpacing.md,
          FlowSpacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: primaryLabel,
              onPressed: onPrimaryPressed,
              isLoading: primaryLoading,
            ),
            if (variant == CtaSectionVariant.primaryAndSecondary) ...[
              const SizedBox(height: FlowSpacing.sm),
              SecondaryButton(
                label: secondaryLabel!,
                onPressed: onSecondaryPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
