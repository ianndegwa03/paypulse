import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
);
