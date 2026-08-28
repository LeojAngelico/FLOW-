import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../environment/app_environment.dart';
import 'clock.dart';

part 'clock_provider.g.dart';

/// Only meaningful in the `dev` flavor — lets a future debug UI move
/// the app's clock forward/backward to test streaks, reminders, and
/// day-rollover logic without waiting in real time.
@riverpod
class ClockOverride extends _$ClockOverride {
  @override
  DateTime? build() => null;

  void set(DateTime? value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  if (AppEnvironment.current.flavor == AppFlavor.dev) {
    final override = ref.watch(clockOverrideProvider);
    if (override != null) {
      return FixedClock(override);
    }
  }

  return const SystemClock();
}
