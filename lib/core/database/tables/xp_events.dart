import 'package:drift/drift.dart';

/// Append-only ledger — 08-data-model.md ENT-04. `totalXp` is always
/// `SUM(amount)`, never a mutable counter, so edits/deletes stay
/// reconcilable.
class XpEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amount =>
      integer().customConstraint('NOT NULL CHECK (amount >= 0)')();
  TextColumn get localDate => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get refId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
