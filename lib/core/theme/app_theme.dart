import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _ink = Color(0xFF101828);
  static const _blue = Color(0xFF2563EB);
  static const _surface = Color(0xFFF5F7FC);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'MomoTrustSans',
    scaffoldBackgroundColor: _surface,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _blue,
          surface: _surface,
          brightness: Brightness.light,
        ).copyWith(
          primary: _blue,
          onPrimary: Colors.white,
          secondary: const Color(0xFFFFC93D),
          onSecondary: _ink,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surface,
      foregroundColor: _ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: _ink,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      headlineSmall: TextStyle(
        color: _ink,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: _ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: _ink,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: _ink,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(color: Color(0xFF667085), fontSize: 12),
      bodyMedium: TextStyle(
        color: Color(0xFF667085),
        fontSize: 14,
        height: 1.45,
      ),
      bodyLarge: TextStyle(color: _ink, fontSize: 16, height: 1.5),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD9E6E3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD9E6E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        side: const BorderSide(color: Color(0xFFD8E2F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _blue,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
