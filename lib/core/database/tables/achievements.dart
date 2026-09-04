import 'package:drift/drift.dart';

/// 08-data-model.md ENT-05. Name/description/group/threshold/XP live in
/// a const Dart catalogue (Phase 5), not this table — only unlock state
/// is persisted here.
class Achievements extends Table {
  TextColumn get key => text()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  IntColumn get unlockedAt => integer().nullable()();
  IntColumn get progressCurrent => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {key};
}
