import 'package:flutter/material.dart';
import 'package:paypulse/core/theme/app_colors.dart';

/// Premium theme configuration for PayPulse
/// Modern, sophisticated design with glassmorphism and smooth animations
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // DESIGN TOKENS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Border radii
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusFull = 100.0;

  /// Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  /// Get adjusted duration based on global animation setting
  static Duration getDuration(Duration duration, bool useAnimations) {
    return useAnimations ? duration : Duration.zero;
  }

  /// Animation curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.easeOutBack;

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme get _baseTextTheme => const TextTheme(
        // Display styles - Hero text
        displayLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.0,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          height: 1.2,
        ),

        // Headlines - Section headers
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.35,
        ),

        // Titles - Card headers
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
        ),

        // Body text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
        ),

        // Labels - Buttons, chips
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          height: 1.2,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData lightTheme({Color? primaryColor}) {
    final color = primaryColor ?? AppColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: color,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: color,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.accent,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
        surfaceContainerHigh: AppColors.surfaceElevatedLight,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.dividerLight,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Text Theme
      textTheme: _baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          side: BorderSide(color: color),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: color,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textTertiary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
        ),
        dragHandleColor: AppColors.borderLight,
        dragHandleSize: const Size(40, 4),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        elevation: 0,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 0,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return color;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return color.withOpacity(0.3);
          }
          return AppColors.borderLight;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: color,
        inactiveTrackColor: color.withOpacity(0.2),
        thumbColor: color,
        overlayColor: color.withOpacity(0.1),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: color,
        linearTrackColor: color.withOpacity(0.1),
      ),

      shadowColor: Colors.black.withOpacity(0.05),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData darkTheme({Color? primaryColor}) {
    // If primary color is pure black, use primaryElevatedDark for UI components in Dark Mode
    // to distinguish them from the pure black scaffold background.
    final color =
        (primaryColor == const Color(0xFF000000) || primaryColor == null)
            ? AppColors.primaryElevatedDark
            : primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: color,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: color,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.textPrimary,
        tertiary: AppColors.accentLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHigh: AppColors.surfaceElevatedDark,
        error: AppColors.errorLight,
        onError: AppColors.textPrimary,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.dividerDark,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),

      // Text Theme
      textTheme: _baseTextTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: AppColors.borderDark.withOpacity(0.8)),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          side: BorderSide(color: color),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: color,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textTertiaryDark),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
        ),
        dragHandleColor: AppColors.borderDark,
        dragHandleSize: const Size(40, 4),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        elevation: 0,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 0,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        contentTextStyle: TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return color;
          return AppColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return color.withOpacity(0.3);
          }
          return AppColors.borderDark;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: color,
        inactiveTrackColor: color.withOpacity(0.3),
        thumbColor: color,
        overlayColor: color.withOpacity(0.15),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: color,
        linearTrackColor: color.withOpacity(0.2),
      ),

      shadowColor: Colors.black.withOpacity(0.4),
    );
  }
}
