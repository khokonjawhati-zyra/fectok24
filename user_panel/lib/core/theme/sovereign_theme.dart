import 'package:flutter/material.dart';

class SovereignColors {
  static const Color cyan = Color(0xFF00FFFF);
  static const Color background = Color(0xFF0D0D0D);
  static const Color glassBase = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color neonPink = Color(0xFFFF00FF);
}

class SovereignTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: SovereignColors.cyan,
      scaffoldBackgroundColor: SovereignColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: SovereignColors.cyan,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: SovereignColors.cyan,
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
