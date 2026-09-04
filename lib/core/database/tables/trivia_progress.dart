import 'package:drift/drift.dart';

/// 08-data-model.md ENT-06, keyed to the bundled trivia.json content.
class TriviaProgress extends Table {
  TextColumn get itemId => text()();
  TextColumn get type => text()();
  IntColumn get seenAt => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get answeredCorrectly => boolean().nullable()();
  BoolColumn get awardedXp => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {itemId};
}
