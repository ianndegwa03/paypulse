import 'package:flutter/material.dart';

/// Premium color palette for PayPulse
/// Sophisticated, modern design with gradient support and glassmorphism-ready colors
class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS - Premium Gradient Palette
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary - Premium Black
  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF1A1A1A);
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryElevatedDark =
      Color(0xFF1E1E1E); // For visibility in Dark Mode

  /// Secondary - Sophisticated Slate
  static const Color secondary = Color(0xFF475569);
  static const Color secondaryLight = Color(0xFF64748B);
  static const Color secondaryDark = Color(0xFF334155);

  /// Accent - Emerald Green (Success/Income)
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF059669);

  /// Coral - Expense/Warning
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralLight = Color(0xFFFF9999);
  static const Color coralDark = Color(0xFFE63946);

  /// Error - Crimson Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFECACA);
  static const Color errorDark = Color(0xFFDC2626);

  /// On Primary Surface
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS - Sophisticated Light & Obsidian Dark
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light theme backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);

  /// Dark theme backgrounds - True OLED Black
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF0F0F0F);
  static const Color surfaceElevatedDark = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM & BLUR COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Glass effect backgrounds (use with BackdropFilter)
  static Color glassLight = Colors.white.withOpacity(0.72);
  static Color glassDark = Colors.black.withOpacity(0.65);
  static Color glassWhite = Colors.white.withOpacity(0.08);

  /// Glass borders
  static Color glassBorderLight = Colors.white.withOpacity(0.5);
  static Color glassBorderDark = Colors.white.withOpacity(0.12);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark =
      Color(0xFF334155); // More visible Slate border
  static const Color dividerLight = Color(0xFFF1F5F9);
  static const Color dividerDark = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Income / Positive
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFFD1FAE5);

  /// Expense / Negative
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFFEE2E2);

  /// Pending / Warning
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingLight = Color(0xFFFEF3C7);

  /// Info / Neutral
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main brand gradient - Black Sophistication
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vibrant card gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Income/success gradient
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Expense/alert gradient
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode subtle gradient
  static const LinearGradient darkSubtleGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  /// Sunset premium gradient
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFC857), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHART COLORS (for analytics visualizations)
  // ═══════════════════════════════════════════════════════════════════════════

  static const List<Color> chartColors = [
    Color(0xFF0066FF), // Primary Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  static const List<Color> chartColorsDark = [
    Color(0xFF4D94FF), // Lighter Blue
    Color(0xFFA78BFA), // Lighter Violet
    Color(0xFF34D399), // Lighter Emerald
    Color(0xFFFBBF24), // Lighter Amber
    Color(0xFFF87171), // Lighter Red
    Color(0xFF22D3EE), // Lighter Cyan
    Color(0xFFF472B6), // Lighter Pink
    Color(0xFFA78BFA), // Lighter Purple
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> coloredShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
