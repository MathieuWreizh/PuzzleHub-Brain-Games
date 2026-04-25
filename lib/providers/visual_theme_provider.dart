import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/visual_theme.dart';

const _kThemeKey = 'visual_theme';

Future<VisualTheme> loadSavedVisualTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_kThemeKey) ?? VisualThemeId.default_.name;
  return VisualTheme.byName(name);
}

class VisualThemeNotifier extends StateNotifier<VisualTheme> {
  VisualThemeNotifier(super.initial);

  Future<void> setTheme(VisualTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, theme.id.name);
  }
}

final visualThemeProvider =
    StateNotifierProvider<VisualThemeNotifier, VisualTheme>(
  (ref) => VisualThemeNotifier(VisualTheme.defaultTheme),
);
