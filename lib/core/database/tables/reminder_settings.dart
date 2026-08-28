import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md ENT-07.
class ReminderSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get startMinuteOfDay =>
      integer().withDefault(const Constant(480))();
  IntColumn get endMinuteOfDay => integer().withDefault(const Constant(1320))();
  IntColumn get intervalMinutes => integer().withDefault(const Constant(120))();
  TextColumn get activeWeekdays =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  TextColumn get messageStyle =>
      text().withDefault(const Constant('friendly'))();
  TextColumn get soundId => text().nullable()();
  BoolColumn get stopWhenGoalMet =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
