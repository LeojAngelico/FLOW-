import '../../../../core/database/app_database.dart' as db;

/// Every Drift statement for the onboarding feature lives here — no
/// other file issues SQL against `user_profiles` or `reminder_settings`.
///
/// `user_profiles` and `reminder_settings` are both singleton tables
/// (row id always `1`), so this is the only data source that ever
/// writes them. See `docs/workplans/2026-09-05-onboarding.md` § API
/// contract for why the Drift row/companion classes are imported under
/// the `db.` prefix (hydration Decisions #3) and why `reminder_settings`
/// is *updated*, never inserted (Decisions #11 — the row is already
/// seeded at `onCreate`).
class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._database);

  final db.AppDatabase _database;

  /// Commits the `user_profiles` row and the `reminder_settings` update
  /// in one `transaction()` — the only atomicity `FR-019` can actually
  /// get, since neither write can see the other store (see the
  /// repository's ordering of this call against the SharedPreferences
  /// write, Decisions #4).
  ///
  /// [profile] is written with `insertOnConflictUpdate` against `id: 1`
  /// — the singleton is enforced here, not by a schema constraint (the
  /// Drift table intentionally has no `CHECK (id = 1)`, see the API
  /// contract note 1). Running this twice therefore leaves exactly one
  /// row, satisfying the "double-tap the CTA" and "second completion
  /// after a mid-flow crash" acceptance criteria.
  ///
  /// [reminders] is written with a plain `update ... where id = 1`. A
  /// zero-row result means the seeded singleton row is missing, which is
  /// an invariant violation rather than a case to silently repair by
  /// inserting — it is surfaced as an error so the repository maps it to
  /// a [StorageFailure] instead of leaving a second `reminder_settings`
  /// row behind.
  Future<void> writeProfileAndReminders({
    required db.UserProfilesCompanion profile,
    required db.ReminderSettingsCompanion reminders,
  }) {
    return _database.transaction(() async {
      await _database
          .into(_database.userProfiles)
          .insertOnConflictUpdate(profile);

      final updatedRows = await (_database.update(
        _database.reminderSettings,
      )..where((row) => row.id.equals(1))).write(reminders);

      if (updatedRows == 0) {
        throw StateError(
          'reminder_settings row 1 is missing. It is seeded at onCreate '
          'and onboarding must only update it, never insert it.',
        );
      }
    });
  }
}
