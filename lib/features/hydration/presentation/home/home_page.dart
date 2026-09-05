import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/info_card.dart';
import '../../../../core/design/components/secondary_button.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/today_hydration.dart';
import 'home_notifier.dart';
import 'home_state.dart';
import 'today_hydration_provider.dart';
import 'widgets/hydration_summary.dart';
import 'widgets/quick_add_row.dart';
import 'widgets/todays_logs_section.dart';

/// `/home` — APP-01's core loop: today's progress, quick-add logging,
/// today's entries. Renders state only; all writes go through
/// [homeProvider] and all reads through [todayHydrationProvider] — see
/// the workplan's Decisions log #3 for why those are two providers
/// instead of one Notifier.
///
/// Maps the read stream's `AsyncValue` and [HomeState.writeFailure] to
/// APP-01's five product states:
/// - `firstRun` — the stream hasn't emitted yet (first load this
///   mount): [AsyncValue.loading].
/// - `empty` — loaded, zero entries today.
/// - `inProgress` — loaded, entries exist, goal not yet met.
/// - `complete`/`overTarget` — loaded, [TodayHydration.goalCompleted].
/// - `writeError` — [HomeState.writeFailure] is set. Rendered as an
///   inline banner *over* whichever of the above is current, not a
///   replacement — the displayed total must stay unchanged
///   (acceptance criteria).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final todayAsync = ref.watch(todayHydrationProvider);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.navHome)),
      body: SafeArea(
        child: todayAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(FlowSpacing.lg),
              child: InfoCard(
                message: loc.errorHydrationStorage,
                kind: InfoCardKind.caution,
              ),
            ),
          ),
          data: (today) => _HomeContent(today: today, homeState: homeState),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.today, required this.homeState});

  final TodayHydration today;
  final HomeState homeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FlowSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (homeState.writeFailure != null) ...[
            InfoCard(
              message: loc.errorHydrationStorage,
              kind: InfoCardKind.caution,
            ),
            const SizedBox(height: FlowSpacing.md),
          ],
          HydrationSummary(today: today, lastLogged: homeState.lastLogged),
          const SizedBox(height: FlowSpacing.lg),
          QuickAddRow(
            goalCompleted: today.goalCompleted,
            onQuickAdd: (amountMl) =>
                ref.read(homeProvider.notifier).quickAdd(amountMl),
          ),
          const SizedBox(height: FlowSpacing.md),
          SecondaryButton(
            label: loc.hydrationAddWaterCta,
            onPressed: () => context.push('/home/add'),
          ),
          const SizedBox(height: FlowSpacing.lg),
          TodaysLogsSection(entries: today.entries),
        ],
      ),
    );
  }
}
