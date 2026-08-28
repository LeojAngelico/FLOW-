import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/environment/app_environment.dart';

void main() {
  // Resolves the active flavor (dev/alpha/prod) and build mode into
  // a single AppEnvironment.current, read everywhere else in the
  // app. Must run before anything reads AppEnvironment.current.
  AppEnvironment.initialize();

  runApp(const ProviderScope(child: App()));
}
