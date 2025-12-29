import 'package:flutter/material.dart';

class ThemeConfiguration {
  final ThemeMode mode;
  final Color primaryColor;
  final bool useAnimations;

  const ThemeConfiguration({
    this.mode = ThemeMode.system,
    this.primaryColor = const Color(0xFF000000), // Default to Black
    this.useAnimations = true,
  });

  ThemeConfiguration copyWith({
    ThemeMode? mode,
    Color? primaryColor,
    bool? useAnimations,
  }) {
    return ThemeConfiguration(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      useAnimations: useAnimations ?? this.useAnimations,
    );
  }
}
