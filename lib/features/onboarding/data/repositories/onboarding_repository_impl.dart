import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../hydration/domain/models/user_profile.dart';
import '../../domain/models/reminder_preferences.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../datasources/onboarding_preferences_datasource.dart';
import '../models/user_profile_mapper.dart';

/// Implements `OnboardingRepository` (`domain/repositories/`).
///
/// Owns the `FR-019` ordering (Decisions #4): the Drift transaction
/// commits first, and the `SharedPreferences` flag is only set once that
/// returns without throwing. SQLite and `SharedPreferences` cannot share
/// one commit, so this ordering — not a shared transaction — is what
/// "atomically" means for this write. A crash between the two leaves
/// `onboardingComplete == false` and a harmless profile row that the
/// next completion overwrites via `insertOnConflictUpdate`, rather than
/// a user on `/home` with no profile row.
///
/// Forward references: `OnboardingRepository`, `UserProfile` and
/// `ReminderPreferences` did not exist yet when this file was written —
/// see the workplan's Decisions log for the assumed shape of
/// `ReminderPreferences.activeWeekdays` (`Set<int>`, weekday numbers
/// `1`–`7`).
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._localDataSource, this._preferencesDataSource);

  final OnboardingLocalDataSource _localDataSource;
  final OnboardingPreferencesDataSource _preferencesDataSource;

  @override
  Future<Result<void>> completeOnboarding({
    required UserProfile profile,
    required ReminderPreferences reminders,
  }) async {
    try {
      await _localDataSource.writeProfileAndReminders(
        profile: profile.toCompanion(),
        reminders: _toReminderSettingsCompanion(reminders),
      );

      // Only reached once the transaction above has actually committed —
      // this ordering, not a shared transaction, is the whole `FR-019`
      // guarantee (Decisions #4). Kept inside this same `try`: every
      // other write in this codebase wraps its whole body (see
      // `hydration_repository_impl.dart`), so a throw here is mapped to a
      // `Failure` and returned through the `Future<Result<T>>` contract
      // instead of escaping uncaught and leaving a caller's
      // `isSubmitting` flag stuck `true` forever. A failure here
      // (extremely unlikely — `SharedPreferences` is an in-memory-backed
      // cache) still leaves a valid, idempotent profile row behind, so a
      // retry that re-runs this whole method is safe.
      await _preferencesDataSource.setOnboardingComplete();
      return const Result.ok(null);
    } catch (error) {
      return Result.err(_mapException(error));
    }
  }

  /// Drift/SQLite exceptions (a CHECK-constraint violation, a disk
  /// error, the `reminder_settings` invariant check in the data source)
  /// become a [StorageFailure]. A CHECK violation reaching this layer
  /// means the domain already rejected the value and something bypassed
  /// it — still a [StorageFailure], not a [ValidationFailure], because
  /// by this point it is an invariant break rather than user input
  /// (API contract note, § Data).
  Failure _mapException(Object error) {
    if (error is Failure) return error;
    return StorageFailure('Could not save onboarding data: $error');
  }
}

/// The only conversion of [ReminderPreferences] into a
/// `reminder_settings` update. A plain (non-`.insert()`) companion is
/// used deliberately: leaving `messageStyle`, `soundId` and
/// `stopWhenGoalMet` as `Value.absent()` means the update statement
/// never touches those columns, keeping the seeded defaults untouched
/// (Decisions § Open product questions).
db.ReminderSettingsCompanion _toReminderSettingsCompanion(
  ReminderPreferences reminders,
) {
  return db.ReminderSettingsCompanion(
    enabled: Value(reminders.enabled),
    startMinuteOfDay: Value(reminders.startMinuteOfDay),
    endMinuteOfDay: Value(reminders.endMinuteOfDay),
    intervalMinutes: Value(reminders.intervalMinutes),
    activeWeekdays: Value(_encodeWeekdays(reminders.activeWeekdays)),
  );
}

/// Comma-joined in ascending weekday order (`1`–`7`), matching the
/// stable-ordering treatment `specialCircumstances` gets in
/// `user_profile_mapper.dart` — the same selection must always produce
/// the same string.
String _encodeWeekdays(Set<int> weekdays) {
  return [
    for (var day = 1; day <= 7; day++)
      if (weekdays.contains(day)) day,
  ].join(',');
}
