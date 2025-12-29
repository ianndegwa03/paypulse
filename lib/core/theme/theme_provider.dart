import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/theme/theme_configuration.dart';

import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeConfiguration>((ref) {
  return ThemeNotifier(getIt<StorageService>());
});

class ThemeNotifier extends StateNotifier<ThemeConfiguration> {
  final StorageService _storage;
  static const _themeModeKey = 'theme_mode';
  static const _primaryColorKey = 'theme_primary_color';
  static const _useAnimationsKey = 'theme_use_animations';

  ThemeNotifier(this._storage) : super(const ThemeConfiguration()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final modeStr = await _storage.getString(_themeModeKey);
      final colorInt = await _storage.getInt(_primaryColorKey);
      final useAnimations = await _storage.getBool(_useAnimationsKey);

      ThemeMode mode = ThemeMode.system;
      if (modeStr != null) {
        mode = ThemeMode.values.firstWhere(
          (e) => e.toString() == modeStr,
          orElse: () => ThemeMode.system,
        );
      }

      Color primaryColor = const Color(0xFF000000);
      if (colorInt != null) {
        primaryColor = Color(colorInt);
      }

      state = ThemeConfiguration(
        mode: mode,
        primaryColor: primaryColor,
        useAnimations: useAnimations ?? true,
      );
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> _saveTheme() async {
    await _storage.saveString(_themeModeKey, state.mode.toString());
    await _storage.saveInt(_primaryColorKey, state.primaryColor.value);
    await _storage.saveBool(_useAnimationsKey, state.useAnimations);
  }

  void toggleTheme() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
    _saveTheme();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    _saveTheme();
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
    _saveTheme();
  }

  void setLightMode() {
    setThemeMode(ThemeMode.light);
  }

  void setDarkMode() {
    setThemeMode(ThemeMode.dark);
  }

  void setSystemMode() {
    setThemeMode(ThemeMode.system);
  }

  void toggleAnimations() {
    state = state.copyWith(useAnimations: !state.useAnimations);
    _saveTheme();
  }
}
