import 'dart:io';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../ui_kit/buttons/app_button.dart';
import '../../ui_kit/surfaces/app_card.dart';
import '../../ui_kit/tokens/app_sizing.dart';
import '../../ui_kit/tokens/app_spacing.dart';
import '../face_capture_config.dart';
import '../face_capture_localizer.dart';
import 'face_capture_review_slot.dart';

/// The light, image-focused review step for captured faces.
///
/// A body widget rather than a page: the calling feature supplies the
/// `Scaffold` and app bar, because only it knows what the workflow is
/// called ("Verify Account", "Employee Check-In"). It renders slots,
/// completion state, tips, and the actions — and holds no state, makes
/// no decisions, and never uploads anything. Tapping a slot calls back;
/// what that means is the feature's business.
class FaceCaptureReviewView extends StatelessWidget {
  /// The capture positions to show, in the order the feature wants.
  final List<FaceCaptureReviewSlot> slots;

  /// Defaults to the localized "Take your selfie".
  final String? title;

  /// Defaults to the localized "Make sure to use a bright photo".
  final String? subtitle;

  /// Called when a slot is tapped — empty (capture) or filled
  /// (retake). Null makes the slots non-interactive.
  final ValueChanged<FaceOrientation>? onSlotTapped;

  /// Null disables the primary action. The caller decides what
  /// "complete" means; [allRequiredCompleted] is provided to help.
  final VoidCallback? onContinue;

  final String? continueLabel;

  /// Optional secondary action under the primary button.
  final VoidCallback? onRetake;

  /// Replaces the default three tips. An empty list hides the card.
  final List<String>? tips;

  const FaceCaptureReviewView({
    super.key,
    required this.slots,
    this.title,
    this.subtitle,
    this.onSlotTapped,
    this.onContinue,
    this.continueLabel,
    this.onRetake,
    this.tips,
  });

  /// Whether every required slot has a photo — the usual condition for
  /// enabling [onContinue].
  static bool allRequiredCompleted(List<FaceCaptureReviewSlot> slots) {
    return slots.every((slot) => !slot.isRequired || slot.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final resolvedTips =
        tips ??
        [
          loc.faceCaptureReviewTipLighting,
          loc.faceCaptureReviewTipAccessories,
          loc.faceCaptureReviewTipFrame,
        ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                title ?? loc.faceCaptureReviewTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                subtitle ?? loc.faceCaptureReviewSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final slot in slots)
                    Expanded(
                      child: _ReviewSlot(
                        slot: slot,
                        onTap: onSlotTapped == null
                            ? null
                            : () => onSlotTapped!(slot.orientation),
                      ),
                    ),
                ],
              ),

              if (resolvedTips.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _TipsCard(tips: resolvedTips),
              ],
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              AppButton(
                label: continueLabel ?? loc.faceCaptureReviewContinue,
                width: double.infinity,
                onPressed: onContinue,
              ),
              if (onRetake != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: AppButton(
                    label: loc.faceCaptureReviewRetake,
                    variant: AppButtonVariant.text,
                    height: AppSizing.buttonHeightCompact,
                    onPressed: onRetake,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single capture position: label, photo or placeholder, status.
class _ReviewSlot extends StatelessWidget {
  final FaceCaptureReviewSlot slot;
  final VoidCallback? onTap;

  const _ReviewSlot({required this.slot, this.onTap});

  static const double _diameter = 84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    final label =
        slot.label ??
        FaceCaptureLocalizer.orientation(context, slot.orientation);

    final status = slot.isCompleted
        ? loc.faceCaptureReviewCompleted
        : (slot.isRequired
              ? loc.faceCaptureReviewRequired
              : loc.faceCaptureReviewOptional);

    return Semantics(
      button: onTap != null,
      label: '$label, $status',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_diameter),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                width: _diameter,
                height: _diameter,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipOval(
                        child: slot.isCompleted
                            ? Image.file(
                                File(slot.imagePath!),
                                fit: BoxFit.cover,
                                // A missing temp file must not take the
                                // whole review screen down with it.
                                errorBuilder: (context, _, _) =>
                                    _SlotPlaceholder(scheme: scheme),
                              )
                            : _SlotPlaceholder(scheme: scheme),
                      ),
                    ),
                    if (slot.isCompleted)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 22,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: slot.isCompleted
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotPlaceholder extends StatelessWidget {
  final ColorScheme scheme;

  const _SlotPlaceholder({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 44,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;

  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  loc.faceCaptureReviewTipsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: AppSizing.iconSm,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(tip, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
