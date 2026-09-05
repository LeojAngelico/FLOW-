import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/brand_mark.dart';
import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/mascot_frame.dart';
import '../../../../core/design/components/pillar.dart';
import '../../../../core/design/theme/reduce_motion_provider.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_scaffold.dart';

/// `ONB-02` — FLOW's first screen (`01 §6`: explain FLOW in under 10
/// seconds). Single static state: nothing here is user input, so there
/// is nothing to validate or persist beyond navigating on to `ONB-03`.
/// Bloop **Curious** per `13 §9.3` — "invites engagement." Back exits
/// the app (no `StepHeader`, no back chevron — this is the flow's first
/// screen).
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final reduceMotion = ref.watch(reduceMotionProvider);

    return OnboardingScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: FlowSpacing.lg),
          const BrandMark(),
          const SizedBox(height: FlowSpacing.md),
          MascotFrame(pose: MascotPose.curious, reduceMotion: reduceMotion),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingWelcomeHeadline,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Text(
            loc.onboardingWelcomeSubhead,
            textAlign: TextAlign.center,
            style: typography.bodyL.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Pillar(
            iconAsset: 'assets/icons/onboarding/icon-droplet.svg',
            title: loc.onboardingWelcomePillarHydrateTitle,
            description: loc.onboardingWelcomePillarHydrateDescription,
          ),
          const SizedBox(height: FlowSpacing.sm),
          Pillar(
            iconAsset: 'assets/icons/onboarding/icon-chart.svg',
            title: loc.onboardingWelcomePillarProgressTitle,
            description: loc.onboardingWelcomePillarProgressDescription,
          ),
          const SizedBox(height: FlowSpacing.sm),
          Pillar(
            iconAsset: 'assets/icons/onboarding/icon-lightbulb.svg',
            title: loc.onboardingWelcomePillarLearnTitle,
            description: loc.onboardingWelcomePillarLearnDescription,
          ),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingWelcomeTrustLine,
            textAlign: TextAlign.center,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: FlowSpacing.md),
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.onboardingWelcomeCta,
        onPrimaryPressed: () => context.push('/onboarding/basics'),
      ),
    );
  }
}
