import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/preferences/onboarding_provider.dart';

/// Writes the `onboardingComplete` flag to `SharedPreferences`.
///
/// Kept separate from [OnboardingLocalDataSource] even though both are
/// "onboarding storage": the ordering between the Drift transaction and
/// this write is the entire `FR-019` guarantee (a crash between the two
/// must not leave `onboardingComplete == true` without a profile row),
/// and that ordering belongs to the repository — not to a data source
/// that happens to hold both handles and could reorder them internally
/// without anyone noticing. See
/// `docs/workplans/2026-09-05-onboarding.md` Decisions #4.
class OnboardingPreferencesDataSource {
  OnboardingPreferencesDataSource(this._prefs);

  final SharedPreferences _prefs;

  /// Sets the flag the router's redirect gate reads
  /// (`onboardingCompleteProvider`). The caller is responsible for
  /// invalidating that provider afterwards — a `SharedPreferences` write
  /// does not itself notify a Riverpod provider that already read a
  /// cached value (Decisions #5).
  Future<void> setOnboardingComplete() {
    return _prefs.setBool(onboardingCompleteKey, true);
  }
}
