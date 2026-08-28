// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in main() with the real, already-opened instance before
/// runApp — see Step 8 below.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Overridden in main() with the real, already-opened instance before
/// runApp — see Step 8 below.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Overridden in main() with the real, already-opened instance before
  /// runApp — see Step 8 below.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'47c448710415a79313c2ceafcdc68d9e188cfcc9';

/// True unless opening/migrating the database threw in main() — drives
/// the router's redirect-to-/recovery gate (Task 30).

@ProviderFor(databaseHealthy)
final databaseHealthyProvider = DatabaseHealthyProvider._();

/// True unless opening/migrating the database threw in main() — drives
/// the router's redirect-to-/recovery gate (Task 30).

final class DatabaseHealthyProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True unless opening/migrating the database threw in main() — drives
  /// the router's redirect-to-/recovery gate (Task 30).
  DatabaseHealthyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseHealthyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHealthyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return databaseHealthy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$databaseHealthyHash() => r'd032141d1c23a947af3b3da0de90fca92ea4cb9a';
