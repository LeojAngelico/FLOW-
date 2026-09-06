import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';

part 'onboarding_provider.g.dart';

/// Public so the data layer that *writes* this flag (the onboarding
/// feature) and the provider that *reads* it share one source of truth
/// for the key string — see `docs/workplans/2026-09-05-onboarding.md`
/// Decisions #5.
const onboardingCompleteKey = 'onboardingComplete';

@riverpod
bool onboardingComplete(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(onboardingCompleteKey) ?? false;
}
