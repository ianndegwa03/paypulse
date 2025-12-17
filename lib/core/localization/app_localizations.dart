import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Provides localization configuration for the app
class AppLocalizations {
  /// Localization delegates for MaterialApp
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Supported locales for the app
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('sw'), // Swahili
  ];
}
