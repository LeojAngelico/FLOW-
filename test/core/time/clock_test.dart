import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/environment/app_environment.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';

void main() {
  test('SystemClock.now() returns a value close to real time', () {
    const clock = SystemClock();
    final before = DateTime.now();
    final result = clock.now();
    final after = DateTime.now();

    expect(
      result.isAfter(before.subtract(const Duration(seconds: 1))) &&
          result.isBefore(after.add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('FixedClock.now() returns the fixed instant until set again', () {
    final fixed = DateTime(2026, 1, 1, 12);
    final clock = FixedClock(fixed);

    expect(clock.now(), fixed);

    final later = DateTime(2026, 6, 1);
    clock.set(later);

    expect(clock.now(), later);
  });

  test('clockProvider defaults to a SystemClock', () {
    AppEnvironment.initialize();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(clockProvider), isA<SystemClock>());
  });

  test(
    'clockProvider returns the override instant when clockOverrideProvider is set (dev flavor default)',
    () {
      AppEnvironment.initialize();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final overridden = DateTime(2030, 3, 3);
      container.read(clockOverrideProvider.notifier).set(overridden);

      expect(container.read(clockProvider).now(), overridden);
    },
  );
}
