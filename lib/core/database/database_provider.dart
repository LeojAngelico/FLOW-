import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_provider.g.dart';

/// Overridden in main() with the real, already-opened instance before
/// runApp — see Step 8 below.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in main() before runApp.',
  );
}

/// True unless opening/migrating the database threw in main() — drives
/// the router's redirect-to-/recovery gate (Task 30).
@Riverpod(keepAlive: true)
bool databaseHealthy(Ref ref) {
  throw UnimplementedError(
    'databaseHealthyProvider must be overridden in main() before runApp.',
  );
}
