import 'package:drift/drift.dart';

/// 08-data-model.md ENT-02. `localDate` is assigned at creation and
/// never reassigned (DST/travel safety).
class HydrationEntries extends Table {
  TextColumn get id => text()();
  IntColumn get amountMl => integer().customConstraint(
    'NOT NULL CHECK (amount_ml BETWEEN 50 AND 2000)',
  )();
  IntColumn get occurredAt => integer()();
  TextColumn get localDate => text()();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
