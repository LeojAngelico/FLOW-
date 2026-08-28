import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';

part 'onboarding_provider.g.dart';

const _onboardingCompleteKey = 'onboardingComplete';

@riverpod
bool onboardingComplete(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_onboardingCompleteKey) ?? false;
}
