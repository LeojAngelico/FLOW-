import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart';
import 'package:flow/core/database/database_provider.dart';

void main() {
  test('appDatabaseProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Riverpod 3 wraps synchronous provider-build errors in a
    // ProviderException (see riverpod CHANGELOG 3.0.0-dev.16); unwrap
    // it to assert on the actual UnimplementedError underneath.
    expect(
      () => container.read(appDatabaseProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<UnimplementedError>(),
        ),
      ),
    );
  });

  test('databaseHealthyProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(databaseHealthyProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<UnimplementedError>(),
        ),
      ),
    );
  });

  test('a healthy database can be read once overridden', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        databaseHealthyProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(appDatabaseProvider), db);
    expect(container.read(databaseHealthyProvider), isTrue);
  });
}
