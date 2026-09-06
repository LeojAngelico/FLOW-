import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/preferences/shared_preferences_provider.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../datasources/onboarding_preferences_datasource.dart';
import '../repositories/onboarding_repository_impl.dart';

part 'onboarding_data_providers.g.dart';

/// `keepAlive` — long-lived infra bindings, mirroring
/// `hydration_data_providers.dart` and `core/database/database_provider.dart`.
@Riverpod(keepAlive: true)
OnboardingLocalDataSource onboardingLocalDataSource(Ref ref) {
  return OnboardingLocalDataSource(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
OnboardingPreferencesDataSource onboardingPreferencesDataSource(Ref ref) {
  return OnboardingPreferencesDataSource(ref.watch(sharedPreferencesProvider));
}

/// Typed as the domain interface, not the implementation, so a test can
/// override this one provider and replace the whole data layer with a
/// fake (`flutter-architecture-map` SKILL § Provider wiring).
///
/// Forward reference: `OnboardingRepository` (`domain/repositories/`)
/// did not exist yet when this file was written — see the workplan's
/// Decisions log.
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepositoryImpl(
    ref.watch(onboardingLocalDataSourceProvider),
    ref.watch(onboardingPreferencesDataSourceProvider),
  );
}
