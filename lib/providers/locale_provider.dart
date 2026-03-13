import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

const supportedLocales = [
  Locale('fr'),
  Locale('en'),
];

Future<Locale> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_kLocaleKey) ?? 'fr';
  return Locale(code);
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initialLocale);

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(const Locale('fr')), // overridden in main()
);
