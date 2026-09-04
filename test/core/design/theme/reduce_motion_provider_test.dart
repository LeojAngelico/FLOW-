import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/reduce_motion_provider.dart';

void main() {
  test('reduceMotionProvider defaults to false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(reduceMotionProvider), isFalse);
  });

  test('sync updates the state when the value changes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(reduceMotionProvider.notifier).sync(true);

    expect(container.read(reduceMotionProvider), isTrue);
  });

  test('sync is a no-op when the value is unchanged', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var rebuildCount = 0;
    container.listen(reduceMotionProvider, (previous, next) => rebuildCount++);

    container.read(reduceMotionProvider.notifier).sync(false);

    expect(rebuildCount, 0);
  });
}
