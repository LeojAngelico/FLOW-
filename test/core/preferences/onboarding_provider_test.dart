import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/core/preferences/shared_preferences_provider.dart';

void main() {
  test(
    'onboardingCompleteProvider reads false when the key is unset',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(onboardingCompleteProvider), isFalse);
    },
  );

  test('onboardingCompleteProvider reads true when the key is set', () async {
    SharedPreferences.setMockInitialValues({'onboardingComplete': true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingCompleteProvider), isTrue);
  });

  test('sharedPreferencesProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Riverpod 3 wraps synchronous provider-build errors in a
    // ProviderException (see riverpod CHANGELOG 3.0.0-dev.16); unwrap
    // it to assert on the actual UnimplementedError underneath.
    expect(
      () => container.read(sharedPreferencesProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<UnimplementedError>(),
        ),
      ),
    );
  });
}
