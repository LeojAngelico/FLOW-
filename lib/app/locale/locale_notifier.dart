import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/storage_providers.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('en');
  }

  /// Restores the persisted locale, if any.
  ///
  /// Called by the Splash Screen when the application starts.
  Future<void> initialize() async {
    final storage = ref.read(secureStorageProvider);

    final code = await storage.getLocaleCode();

    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;

    final storage = ref.read(secureStorageProvider);

    await storage.saveLocaleCode(locale.languageCode);
  }
}

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
