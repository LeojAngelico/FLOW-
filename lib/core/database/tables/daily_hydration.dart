import 'package:drift/drift.dart';

/// Materialized aggregate, one row per local date — 08-data-model.md
/// ENT-03. `targetMl` is snapshotted on the first entry of the day and
/// never rewritten after.
class DailyHydration extends Table {
  TextColumn get date => text()();
  IntColumn get totalMl => integer().withDefault(const Constant(0))();
  IntColumn get targetMl => integer().customConstraint(
    'NOT NULL CHECK (target_ml BETWEEN 500 AND 4000)',
  )();
  BoolColumn get goalCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get goalCompletedAt => integer().nullable()();
  IntColumn get entryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('noData'))();

  @override
  Set<Column> get primaryKey => {date};
}
