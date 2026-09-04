import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/environment/app_environment.dart';
import 'core/preferences/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolves the active flavor (dev/alpha/prod) and build mode into
  // a single AppEnvironment.current, read everywhere else in the
  // app. Must run before anything reads AppEnvironment.current.
  AppEnvironment.initialize();

  final prefs = await SharedPreferences.getInstance();

  final database = AppDatabase();
  var databaseIsHealthy = true;
  try {
    await database.customStatement('PRAGMA user_version');
  } catch (_) {
    databaseIsHealthy = false;
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
        databaseHealthyProvider.overrideWithValue(databaseIsHealthy),
      ],
      child: const App(),
    ),
  );
}
