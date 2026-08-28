import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's built-in [GlobalMaterialLocalizations] and
/// [GlobalCupertinoLocalizations] don't ship data for Cebuano ("ceb") —
/// it isn't one of the framework's officially supported locales.
///
/// Passing an explicit `locale:` to `MaterialApp` (as this app does, to
/// drive the in-app language toggle) skips Flutter's normal
/// supportedLocales negotiation, so without this fallback, selecting
/// Cebuano makes every Material widget throw "No MaterialLocalizations
/// found" — since nearly all of them depend on it internally.
///
/// These delegates claim support for "ceb" specifically and load
/// English's framework translations in its place, so built-in widget
/// chrome (date pickers, back-button semantics, etc.) falls back to
/// English instead of crashing. The app's own text — via
/// AppLocalizations — is unaffected and still shows real Cebuano.
class CebFallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CebFallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ceb';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(CebFallbackMaterialLocalizationsDelegate old) => false;
}

class CebFallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const CebFallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ceb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(CebFallbackCupertinoLocalizationsDelegate old) => false;
}
