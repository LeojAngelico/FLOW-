import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/cta_section.dart';
import '../../../../core/design/components/day_toggle.dart';
import '../../../../core/design/components/flow_tappable.dart';
import '../../../../core/design/components/flow_text_button.dart';
import '../../../../core/design/components/info_card.dart';
import '../../../../core/design/components/mascot_frame.dart';
import '../../../../core/design/components/pixel_icon.dart';
import '../../../../core/design/components/setting_row.dart';
import '../../../../core/design/theme/reduce_motion_provider.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../onboarding_draft_notifier.dart';
import '../widgets/onboarding_scaffold.dart';
import 'reminders_notifier.dart';
import 'widgets/reminder_preview_card.dart';

/// `ONB-08` — reminder **preference** capture only (Decisions #10):
/// nothing here schedules a notification or requests permission. Both
/// Skip (`CPY-120`) and the CTA (`CPY-128`) call
/// `RemindersNotifier.submit`, which is **the final write of the whole
/// flow**; this page's only job past that is to navigate on success —
/// the notifier exposes state, the page navigates
/// (`flutter-architecture-map` SKILL § Placement decisions).
class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    final succeeded = await ref
        .read(remindersProvider.notifier)
        .submit(enabled: enabled);
    if (succeeded && context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _pickTime(
    BuildContext context, {
    required int currentMinute,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinute ~/ 60,
        minute: currentMinute % 60,
      ),
    );
    if (picked != null) {
      onPicked(picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _pickInterval(
    BuildContext context,
    WidgetRef ref,
    int currentMinutes,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FlowSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final minutes in remindersIntervalOptionsMinutes)
                Padding(
                  padding: const EdgeInsets.only(bottom: FlowSpacing.sm),
                  child: FlowTappable(
                    selected: minutes == currentMinutes,
                    onTap: () => Navigator.of(sheetContext).pop(minutes),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FlowSpacing.md,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.onboardingRemindersIntervalOption(minutes),
                              style: typography.bodyL.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (minutes == currentMinutes)
                            const PixelIcon(
                              asset: 'assets/icons/onboarding/icon-check.svg',
                              size: PixelIconSize.sm,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      ref.read(remindersProvider.notifier).setIntervalMinutes(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final reduceMotion = ref.watch(reduceMotionProvider);
    final draft = ref.watch(onboardingDraftProvider);
    final state = ref.watch(remindersProvider);
    final reminders = draft.reminders;

    final dayLetters = <int, String>{
      1: loc.onboardingRemindersDayLetterMon,
      2: loc.onboardingRemindersDayLetterTue,
      3: loc.onboardingRemindersDayLetterWed,
      4: loc.onboardingRemindersDayLetterThu,
      5: loc.onboardingRemindersDayLetterFri,
      6: loc.onboardingRemindersDayLetterSat,
      7: loc.onboardingRemindersDayLetterSun,
    };
    final dayNames = <int, String>{
      1: loc.onboardingRemindersDayNameMon,
      2: loc.onboardingRemindersDayNameTue,
      3: loc.onboardingRemindersDayNameWed,
      4: loc.onboardingRemindersDayNameThu,
      5: loc.onboardingRemindersDayNameFri,
      6: loc.onboardingRemindersDayNameSat,
      7: loc.onboardingRemindersDayNameSun,
    };

    return OnboardingScaffold(
      header: Align(
        alignment: Alignment.centerRight,
        child: FlowTextButton(
          label: loc.onboardingRemindersSkip,
          showIcon: false,
          onPressed: state.isSubmitting
              ? null
              : () => _submit(context, ref, enabled: false),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.onboardingRemindersHeadline,
            maxLines: 2,
            style: onboardingTitleStyle(
              context,
            ).copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Center(
            child: MascotFrame(
              pose: MascotPose.happy,
              reduceMotion: reduceMotion,
            ),
          ),
          const SizedBox(height: FlowSpacing.lg),
          if (state.submitFailure != null) ...[
            InfoCard(
              message: loc.onboardingErrorStorage,
              kind: InfoCardKind.caution,
            ),
            const SizedBox(height: FlowSpacing.md),
          ],
          SettingRow(
            label: loc.onboardingRemindersStartLabel,
            value: MaterialLocalizations.of(context).formatTimeOfDay(
              TimeOfDay(
                hour: reminders.startMinuteOfDay ~/ 60,
                minute: reminders.startMinuteOfDay % 60,
              ),
            ),
            onTap: () => _pickTime(
              context,
              currentMinute: reminders.startMinuteOfDay,
              onPicked: (minute) => ref
                  .read(remindersProvider.notifier)
                  .setStartMinuteOfDay(minute),
            ),
          ),
          const SizedBox(height: FlowSpacing.sm),
          SettingRow(
            label: loc.onboardingRemindersEndLabel,
            value: MaterialLocalizations.of(context).formatTimeOfDay(
              TimeOfDay(
                hour: reminders.endMinuteOfDay ~/ 60,
                minute: reminders.endMinuteOfDay % 60,
              ),
            ),
            onTap: () => _pickTime(
              context,
              currentMinute: reminders.endMinuteOfDay,
              onPicked: (minute) => ref
                  .read(remindersProvider.notifier)
                  .setEndMinuteOfDay(minute),
            ),
          ),
          if (state.windowError != null) ...[
            const SizedBox(height: FlowSpacing.xs),
            Text(
              loc.onboardingRemindersWindowError,
              style: typography.caption.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: FlowSpacing.sm),
          SettingRow(
            label: loc.onboardingRemindersIntervalLabel,
            value: loc.onboardingRemindersIntervalOption(
              reminders.intervalMinutes,
            ),
            onTap: () => _pickInterval(context, ref, reminders.intervalMinutes),
          ),
          const SizedBox(height: FlowSpacing.lg),
          Text(
            loc.onboardingRemindersWeekdaysLabel,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var day = 1; day <= 7; day++)
                Semantics(
                  label: dayNames[day],
                  selected: reminders.activeWeekdays.contains(day),
                  child: ExcludeSemantics(
                    child: DayToggle(
                      dayLetter: dayLetters[day]!,
                      selected: reminders.activeWeekdays.contains(day),
                      onTap: () => ref
                          .read(remindersProvider.notifier)
                          .toggleWeekday(day),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FlowSpacing.lg),
          ReminderPreviewCard(reminders: reminders),
          const SizedBox(height: FlowSpacing.xs),
          Text(
            loc.onboardingRemindersPreviewNote,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      cta: CtaSection(
        primaryLabel: loc.onboardingRemindersCta,
        primaryLoading: state.isSubmitting,
        onPrimaryPressed: state.windowError == null && !state.isSubmitting
            ? () => _submit(context, ref, enabled: true)
            : null,
      ),
    );
  }
}
