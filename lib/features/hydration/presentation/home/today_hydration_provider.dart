import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/time/today_provider.dart';
import '../../domain/models/today_hydration.dart';
import '../../domain/providers/hydration_usecase_providers.dart';

part 'today_hydration_provider.g.dart';

/// The *read* half of `/home` — see `home_notifier.dart` for the write
/// half and the workplan's Decisions log #3 for why they're split
/// rather than one Notifier holding both.
///
/// Re-subscribes to [GetTodayHydration] whenever [todayProvider] changes
/// (local midnight rollover, `FR-034`, and the app resuming across a
/// suspended midnight via `TodayRefreshListener`), since
/// `GetTodayHydration.call` takes the local-calendar-date as a plain
/// parameter rather than tracking "today" itself.
@riverpod
Stream<TodayHydration> todayHydration(Ref ref) {
  final localDate = ref.watch(todayProvider);
  return ref.watch(getTodayHydrationProvider).call(localDate);
}
