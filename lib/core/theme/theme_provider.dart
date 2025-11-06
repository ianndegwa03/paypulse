import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/theme/dark_theme.dart';
import 'package:paypulse/core/theme/light_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme);

  void toggleTheme() {
    if (state == lightTheme) {
      state = darkTheme;
    } else {
      state = lightTheme;
    }
  }
}
