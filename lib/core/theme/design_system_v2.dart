import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PayPulse V2 Design System
/// Single Source of Truth for UI/UX
/// adheres to "Simple but Complex" philosophy
class PulseDesign {
  // ---------------------------------------------------------------------------
  // 1. COLORS (Strict Palette)
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color accent = Color(0xFF8B5CF6); // Violet 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500

  // Backgrounds - Modern Dark Theme Focus
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color bgDarkCard = Color(0xFF1E293B); // Slate 800

  // Light Mode - Warm, Comfortable Tones (not blinding white)
  static const Color bgLight = Color(0xFFF5F3EF); // Warm cream
  static const Color bgLightCard = Color(0xFFFAF9F7); // Soft off-white
  static const Color bgLightSurface =
      Color(0xFFFFFFFF); // Pure white (sparingly)
  static const Color bgLightMuted = Color(0xFFECE9E4); // Muted warm gray

  // Glassmorphism Base Colors
  static Color glassDark = const Color(0xFF1E293B).withOpacity(0.7);
  static Color glassLight = const Color(0xFFFAF9F7).withOpacity(0.8);

  // ---------------------------------------------------------------------------
  // 2. SPACING (Standard Grid - 4pt/8pt rule)
  // ---------------------------------------------------------------------------
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ---------------------------------------------------------------------------
  // 3. RADIUS (Soft, Modern Curves)
  // ---------------------------------------------------------------------------
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXl = 32.0; // Cards, Sheets
  static const double radiusFull = 999.0; // Pills, Avatars

  // ---------------------------------------------------------------------------
  // 4. TYPOGRAPHY (Google Fonts - Inter/Outfit)
  // ---------------------------------------------------------------------------
  static TextTheme getTextTheme(bool isDark) {
    final color =
        isDark ? Colors.white : const Color(0xFF2D3748); // Warmer dark gray
    final secondary =
        isDark ? Colors.white70 : const Color(0xFF718096); // Softer gray

    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: secondary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. THEME DATA (Material 3)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      canvasColor: bgLightCard,
      cardColor: bgLightCard,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: bgLightCard,
        background: bgLight,
        onBackground: const Color(0xFF2D3748),
        onSurface: const Color(0xFF2D3748),
        surfaceVariant: bgLightMuted,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        foregroundColor: Color(0xFF2D3748),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: bgLightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: Color(0xFFE2E0DB), width: 1),
        ),
      ),
      textTheme: getTextTheme(false),
      dividerColor: const Color(0xFFE2E0DB),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E0DB),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: bgDarkCard,
        error: error,
      ),
      textTheme: getTextTheme(true),
      dividerColor: Colors.white.withOpacity(0.1),
    );
  }
}
