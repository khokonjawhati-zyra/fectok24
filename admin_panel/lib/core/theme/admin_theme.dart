import 'package:flutter/material.dart';

class AdminTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF00FF), // Neon Pink for Admin
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    hintColor: const Color(0xFF00FFFF),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Color(0xFFFF00FF), fontWeight: FontWeight.bold),
    ),
  );
}
class SovereignColors {
  static const Color pink = Color(0xFFFF00FF);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color deepBackground = Color(0xFF0D0D0D);
}
