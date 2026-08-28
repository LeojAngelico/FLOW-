import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md ENT-01.
class UserProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get displayName => text().nullable().customConstraint(
    'CHECK (length(display_name) <= 24)',
  )();
  IntColumn get age =>
      integer().customConstraint('NOT NULL CHECK (age BETWEEN 9 AND 120)')();
  TextColumn get sex => text()();
  RealColumn get weightKg => real().customConstraint(
    'NOT NULL CHECK (weight_kg BETWEEN 25.0 AND 250.0)',
  )();
  TextColumn get activityLevel => text()();
  TextColumn get environment => text()();
  TextColumn get specialCircumstances =>
      text().withDefault(const Constant(''))();
  IntColumn get dailyTargetMl => integer().customConstraint(
    'NOT NULL CHECK (daily_target_ml BETWEEN 500 AND 4000)',
  )();
  TextColumn get targetSource => text()();
  TextColumn get calculatorMethodId => text()();
  IntColumn get profileCreatedAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
