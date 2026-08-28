import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Overridden in main() with the real, already-`await`ed instance
/// before runApp — see Step 8 below. Values here are needed before the
/// database opens, so this can't be a FutureProvider the widget tree
/// waits on.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp.',
  );
}
