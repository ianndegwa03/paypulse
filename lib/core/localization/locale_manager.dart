import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages locale state for the application
final localeManagerProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  /// Set a specific locale
  void setLocale(Locale locale) {
    state = locale;
  }

  /// Set locale by language code
  void setLanguage(String languageCode) {
    state = Locale(languageCode);
  }

  /// Reset to default locale
  void resetToDefault() {
    state = const Locale('en');
  }

  /// Get current language code
  String get currentLanguageCode => state.languageCode;
}
