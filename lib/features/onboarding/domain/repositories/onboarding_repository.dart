import '../../../../core/result/result.dart';
import '../../../hydration/domain/models/user_profile.dart';
import '../models/reminder_preferences.dart';

/// Onboarding's single write path.
///
/// One method still earns a repository, per `07 §5`'s general shape and
/// this workplan's own reasoning: it is the seam that lets
/// `complete_onboarding_test.dart` run against a fake instead of a real
/// database, and it keeps Drift and `SharedPreferences` out of `domain/`
/// entirely.
///
/// Implementations own `FR-019`'s ordering — the `user_profiles` row and
/// the `reminder_settings` update commit in one transaction, and
/// `onboardingComplete` is only set once that commit returns (see
/// `docs/workplans/2026-09-05-onboarding.md` Decisions #4). That ordering
/// is a repository/data-layer concern; the caller (`CompleteOnboarding`)
/// only needs to know it either fully succeeded or fully failed.
abstract class OnboardingRepository {
  Future<Result<void>> completeOnboarding({
    required UserProfile profile,
    required ReminderPreferences reminders,
  });
}
