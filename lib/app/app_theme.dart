import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const String appTitle = 'ころころ果樹園';
  static const Color surface = Color(0xFFF2F3E9);
  static const Color ink = Color(0xFF263A35);
  static const Color muted = Color(0xFF728078);
  static const Color coral = Color(0xFFCB654C);
  static const Color fruitAccent = Color(0xFFF2CF76);
  static const Color gameArea = Color(0xFFDCE5D5);
  static const Color controlSurface = Color(0xFFE3E8DB);
  static const Color cardSurface = Colors.white;
  static const Color fruitOutline = Color(0xFF536A5D);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: coral, surface: surface),
    scaffoldBackgroundColor: surface,
  );
}
