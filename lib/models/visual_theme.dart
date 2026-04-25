import 'package:flutter/material.dart';

enum VisualThemeId { default_, forest, desert, beach, canyon, space }

class VisualTheme {
  final VisualThemeId id;
  final String label;
  final String emoji;
  final LinearGradient backgroundGradient;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final LinearGradient primaryGradient;

  const VisualTheme({
    required this.id,
    required this.label,
    required this.emoji,
    required this.backgroundGradient,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryGradient,
  });

  static const VisualTheme defaultTheme = VisualTheme(
    id: VisualThemeId.default_,
    label: 'Défaut',
    emoji: '🎮',
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFFFF6584),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE8E4FF),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF8B8FA8),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFF5F3FF), Color(0xFFEEF2FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFFB06AFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const VisualTheme forest = VisualTheme(
    id: VisualThemeId.forest,
    label: 'Forêt',
    emoji: '🌿',
    primary: Color(0xFF2D7D46),
    secondary: Color(0xFF81C784),
    surface: Color(0xFFF1F8F2),
    border: Color(0xFFBCE0C4),
    textPrimary: Color(0xFF1B3A24),
    textSecondary: Color(0xFF5A8A64),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFE8F5E9), Color(0xFFDCEDC8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF2D7D46), Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const VisualTheme desert = VisualTheme(
    id: VisualThemeId.desert,
    label: 'Désert',
    emoji: '🏜️',
    primary: Color(0xFFD4853A),
    secondary: Color(0xFFFFB74D),
    surface: Color(0xFFFFF8F0),
    border: Color(0xFFFFCCA0),
    textPrimary: Color(0xFF3E2000),
    textSecondary: Color(0xFF9E6B30),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFD4853A), Color(0xFFFF8F00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const VisualTheme beach = VisualTheme(
    id: VisualThemeId.beach,
    label: 'Plage',
    emoji: '🏖️',
    primary: Color(0xFF0288D1),
    secondary: Color(0xFF00BCD4),
    surface: Color(0xFFF0FAFF),
    border: Color(0xFFB2EBF2),
    textPrimary: Color(0xFF003A52),
    textSecondary: Color(0xFF4A8FA8),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFE0F7FA), Color(0xFFB3E5FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0288D1), Color(0xFF00BCD4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const VisualTheme canyon = VisualTheme(
    id: VisualThemeId.canyon,
    label: 'Canyon',
    emoji: '🏔️',
    primary: Color(0xFFB5451B),
    secondary: Color(0xFFFF7043),
    surface: Color(0xFFFFF5F2),
    border: Color(0xFFFFCCBC),
    textPrimary: Color(0xFF3E1200),
    textSecondary: Color(0xFF9E4520),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFFBE9E7), Color(0xFFFFCCBC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFB5451B), Color(0xFFFF7043)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const VisualTheme space = VisualTheme(
    id: VisualThemeId.space,
    label: 'Espace',
    emoji: '🚀',
    primary: Color(0xFF7C4DFF),
    secondary: Color(0xFF00E5FF),
    surface: Color(0xFF0D1B2A),
    border: Color(0xFF1E3A5F),
    textPrimary: Color(0xFFE8F0FE),
    textSecondary: Color(0xFF8EACCD),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0D1B2A), Color(0xFF1A1A3E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const List<VisualTheme> all = [
    defaultTheme,
    forest,
    desert,
    beach,
    canyon,
    space,
  ];

  static VisualTheme byId(VisualThemeId id) =>
      all.firstWhere((t) => t.id == id, orElse: () => defaultTheme);

  static VisualTheme byName(String name) => all.firstWhere(
        (t) => t.id.name == name,
        orElse: () => defaultTheme,
      );
}
