import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const navy = Color(0xFF0B132B);
  static const lime = Color(0xFF58E514);
  static const forest = Color(0xFF3F7F25);
  static const muted = Color(0xFFB7C3D5);
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: navy,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: lime,
          brightness: Brightness.dark,
        ).copyWith(
          primary: lime,
          onPrimary: navy,
          surface: navy,
          onSurface: Colors.white,
        ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 40,
        height: 1.14,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -.7,
      ),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .05),
      contentPadding: const EdgeInsets.all(18),
      labelStyle: const TextStyle(color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lime, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF445365)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    dividerColor: Colors.white.withValues(alpha: .1),
  );
}
