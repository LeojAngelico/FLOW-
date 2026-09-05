import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/time/clock_provider.dart';
import '../../data/providers/hydration_data_providers.dart';
import '../usecases/get_today_hydration.dart';
import '../usecases/log_water.dart';

part 'hydration_usecase_providers.g.dart';

/// `occurredAt` is read from `clockProvider` here, at the usecase layer
/// — not in `hydrationRepositoryProvider` — because "now" is an
/// application-layer concern the caller supplies; the repository takes
/// `occurredAt` as a parameter and has no independent need for a clock.
/// Confirms the workplan's Decisions log #13.
@riverpod
LogWater logWater(Ref ref) {
  return LogWater(
    ref.watch(hydrationRepositoryProvider),
    ref.watch(clockProvider),
  );
}

@riverpod
GetTodayHydration getTodayHydration(Ref ref) {
  return GetTodayHydration(ref.watch(hydrationRepositoryProvider));
}
