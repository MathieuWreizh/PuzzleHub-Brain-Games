import 'package:flutter/material.dart';

class AppTheme {
  // ── Core colors ───────────────────────────────────────────────────────────
  static const Color primary    = Color(0xFF6C63FF);
  static const Color secondary  = Color(0xFFFF6584);
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFE8E4FF);
  static const Color correct    = Color(0xFF10B981);
  static const Color wrong      = Color(0xFFEF4444);
  static const Color textPrimary    = Color(0xFF1E1B4B);
  static const Color textSecondary  = Color(0xFF8B8FA8);

  // ── Gradient presets ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFB06AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF9A9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFEEF2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Card / glass decorations ──────────────────────────────────────────────

  /// Carte principale : fond blanc, ombre douce teintée violet
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// Carte légèrement tintée (pour variante secondaire)
  static BoxDecoration tintedCard(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withValues(alpha: 0.18), width: 1.2),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Bouton / chip glass : fond très transparent + bordure lumineuse
  static BoxDecoration glassDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: border),
    drawerTheme: const DrawerThemeData(backgroundColor: surface),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
  );
}
