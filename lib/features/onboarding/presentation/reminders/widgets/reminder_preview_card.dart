import 'package:flutter/material.dart';

import '../../../../../core/design/components/info_card.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/reminder_preferences.dart';

/// `ONB-08`'s live preview — recomputes on every window/interval change
/// via [ReminderPreferences.reminderMinutes] (`BR-30`), so there is
/// exactly one implementation of that rule to keep in sync (Decisions
/// #9). `liveRegion: true` announces the recomputed count/time list as
/// it changes, matching the conditional info cards on `ONB-06`/`ONB-07`.
class ReminderPreviewCard extends StatelessWidget {
  const ReminderPreviewCard({required this.reminders, super.key});

  final ReminderPreferences reminders;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final times = reminders
        .reminderMinutes()
        .map((minute) => TimeOfDay(hour: minute ~/ 60, minute: minute % 60))
        .map((time) => MaterialLocalizations.of(context).formatTimeOfDay(time))
        .join(', ');

    return Semantics(
      liveRegion: true,
      child: InfoCard(
        message: loc.onboardingRemindersPreviewCount(
          reminders.reminderMinutes().length,
          times,
        ),
      ),
    );
  }
}
