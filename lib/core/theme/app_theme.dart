import 'package:flutter/material.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:paypulse/core/theme/text_styles.dart';

class AppTheme {
  static ThemeData lightTheme({Color? primaryColor}) {
    final color = primaryColor ?? AppColors.primary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: color,
      colorScheme: ColorScheme.light(
        primary: color,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        surfaceContainerHighest: Color(0xFFE1E2E9),
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextStyles.textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData darkTheme({Color? primaryColor}) {
    final color = primaryColor ?? AppColors.primary;
    const darkBackground = Color(0xFF000000); // Obsidian
    const darkSurface = Color(0xFF1C1C1E); // Charcoal

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: color,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: color,
        secondary: AppColors.secondary,
        surface: darkSurface,
        onSurface: Colors.white,
        error: AppColors.error,
        surfaceContainerHighest: Color(0xFF2C2C2E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextStyles.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }
}
