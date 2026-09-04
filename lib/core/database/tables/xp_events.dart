import 'package:drift/drift.dart';

/// Append-only ledger — 08-data-model.md ENT-04. `totalXp` is always
/// `SUM(amount)`, never a mutable counter, so edits/deletes stay
/// reconcilable.
///
/// Deliberately no foreign key here (final-review schema-hardening
/// follow-up considered and scoped this out): `localDate` isn't
/// documented as requiring an existing `DailyHydration` row first (an
/// achievement/trivia event can land on a day with no water logged
/// yet), and `refId` is polymorphic by [type] — entry id, achievement
/// key, or trivia item id, three different tables — which SQL foreign
/// keys cannot express as a single constraint.
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
