import 'package:drift/drift.dart';

import 'daily_hydration.dart';

/// 08-data-model.md ENT-02. `localDate` is assigned at creation and
/// never reassigned (DST/travel safety).
///
/// `localDate` has a foreign key to [DailyHydration.localDate] (the
/// "aggregates" edge in 08-data-model.md §2's entity diagram) —
/// `initiallyDeferred: true` so a transaction that creates a day's
/// first `DailyHydration` row and its `HydrationEntries` row together
/// can insert either one first, checked only at commit. `onDelete:
/// restrict` because the relationship runs the other way round from
/// what SQL's default `CASCADE` intuition suggests: `DailyHydration`
/// is *derived from* these entries (ENT-03, "rebuilt transactionally
/// whenever that date's entries change"), so deleting the aggregate
/// row must never cascade into deleting the real logged entries it
/// summarizes.
class HydrationEntries extends Table {
  TextColumn get id => text()();
  IntColumn get amountMl => integer().customConstraint(
    'NOT NULL CHECK (amount_ml BETWEEN 50 AND 2000)',
  )();
  IntColumn get occurredAt => integer()();
  TextColumn get localDate => text().references(
    DailyHydration,
    #localDate,
    onDelete: KeyAction.restrict,
    initiallyDeferred: true,
  )();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
