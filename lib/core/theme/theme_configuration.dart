import 'package:flutter/material.dart';

class ThemeConfiguration {
  final ThemeMode mode;
  final Color primaryColor;

  const ThemeConfiguration({
    this.mode = ThemeMode.system,
    this.primaryColor = const Color(0xFF6200EE), // Default primary
  });

  ThemeConfiguration copyWith({
    ThemeMode? mode,
    Color? primaryColor,
  }) {
    return ThemeConfiguration(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}
