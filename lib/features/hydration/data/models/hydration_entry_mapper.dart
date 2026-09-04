import '../../../../core/database/app_database.dart' as db;
import '../../domain/models/hydration_entry.dart';

/// The only place `hydration_entries.source` is parsed or produced —
/// keeps [HydrationSource]'s string representation in one spot for
/// both the read path (this extension) and the write path
/// ([hydrationSourceToDb], used by the repository before it reaches
/// the data source).
extension HydrationEntryMapper on db.HydrationEntry {
  HydrationEntry toDomain() {
    return HydrationEntry(
      id: id,
      amountMl: amountMl,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        occurredAt,
        isUtc: true,
      ),
      localDate: localDate,
      source: _parseSource(source),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
    );
  }
}

/// Converts a domain [HydrationSource] to the string stored in
/// `hydration_entries.source`.
String hydrationSourceToDb(HydrationSource source) {
  return switch (source) {
    HydrationSource.quickAdd => 'quickAdd',
    HydrationSource.custom => 'custom',
    HydrationSource.imported => 'imported',
  };
}

/// Explicit unknown-value branch: a value that doesn't match any
/// known `HydrationSource` string is malformed data (`CLAUDE.md §9`),
/// not a case to silently coerce to a default — it throws so the
/// failure surfaces instead of misreporting an entry's origin.
HydrationSource _parseSource(String raw) {
  return switch (raw) {
    'quickAdd' => HydrationSource.quickAdd,
    'custom' => HydrationSource.custom,
    'imported' => HydrationSource.imported,
    _ => throw FormatException('Unknown hydration_entries.source: $raw'),
  };
}
