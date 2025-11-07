import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
);
