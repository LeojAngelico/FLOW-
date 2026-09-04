import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_local_datasource.dart';
import '../repositories/hydration_repository_impl.dart';

part 'hydration_data_providers.g.dart';

/// `keepAlive` — this is a long-lived infra binding, not per-screen
/// state, mirroring `core/database/database_provider.dart`.
@Riverpod(keepAlive: true)
HydrationLocalDataSource hydrationLocalDataSource(Ref ref) {
  return HydrationLocalDataSource(ref.watch(appDatabaseProvider));
}

/// Typed as the domain interface, not the implementation, so a test
/// can override this one provider and replace the whole data layer
/// with a fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `HydrationRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.
@Riverpod(keepAlive: true)
HydrationRepository hydrationRepository(Ref ref) {
  return HydrationRepositoryImpl(ref.watch(hydrationLocalDataSourceProvider));
}
