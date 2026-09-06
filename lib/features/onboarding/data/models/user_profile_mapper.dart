import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../hydration/domain/models/profile_enums.dart';
import '../../../hydration/domain/models/user_profile.dart';

/// The only place a domain [UserProfile] is turned into a
/// `user_profiles` row. Owns every encoding decision the API contract
/// pins down: the enum `.name` strings, the comma-joined
/// `specialCircumstances` string (written in stable, declaration order
/// so the same selection always produces the same string), the
/// `DateTime` → UTC epoch-millis conversion, and the defensive
/// round-to-one-decimal on `weightKg` (a value like `250.05` would
/// otherwise pass the domain's bound check but still satisfy the
/// `BETWEEN 25.0 AND 250.0` column CHECK while losing `FR-006`'s
/// one-decimal precision guarantee).
///
/// Write-direction only: nothing in this pass reads a `UserProfile` back
/// out of the database, so a `fromDb`/`toDomain` reader would be dead
/// code (hydration Decisions #15's precedent). Settings and `APP-08`
/// will add it when they need it.
extension UserProfileMapper on UserProfile {
  db.UserProfilesCompanion toCompanion() {
    return db.UserProfilesCompanion.insert(
      id: const Value(1),
      displayName: Value(displayName),
      age: age,
      sex: sex.name,
      weightKg: _roundToOneDecimal(weightKg),
      activityLevel: activityLevel.name,
      environment: environment.name,
      specialCircumstances: Value(
        _encodeSpecialCircumstances(specialCircumstances),
      ),
      dailyTargetMl: dailyTargetMl,
      targetSource: targetSource.name,
      calculatorMethodId: calculatorMethodId,
      profileCreatedAt: profileCreatedAt.toUtc().millisecondsSinceEpoch,
      updatedAt: updatedAt.toUtc().millisecondsSinceEpoch,
    );
  }
}

/// Declaration order, not insertion order — a `Set` does not guarantee
/// iteration order, and two onboarding sessions that pick the same
/// circumstances in a different tap order must still write the same
/// string.
String _encodeSpecialCircumstances(Set<SpecialCircumstance> circumstances) {
  return SpecialCircumstance.values
      .where(circumstances.contains)
      .map((circumstance) => circumstance.name)
      .join(',');
}

double _roundToOneDecimal(double value) => (value * 10).round() / 10;
