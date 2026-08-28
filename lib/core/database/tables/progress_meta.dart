import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md, `bestStreak`
/// high-water mark that survives a partial data import/merge.
class ProgressMeta extends Table {
  IntColumn get id => integer()();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
