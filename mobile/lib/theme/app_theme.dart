import 'package:flutter/material.dart';

class AppPalette {
  static const Color midnightNavy = Color(0xff0b0b0c);
  static const Color courtroomBlue = Color(0xff1f1f22);
  static const Color slateBlue = Color(0xff5a5d63);
  static const Color parchment = Color(0xfff2f2f2);
  static const Color parchmentAlt = Color(0xfffafafa);
  static const Color gold = Color(0xffb8bcc3);
  static const Color goldDark = Color(0xff6f737b);
  static const Color ink = Color(0xff121212);
  static const Color mutedInk = Color(0xff6f6f73);
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.ink,
      brightness: Brightness.light,
      primary: AppPalette.ink,
      secondary: AppPalette.goldDark,
      surface: Colors.white,
      error: const Color(0xffb3261e),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.parchment,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppPalette.ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: AppPalette.ink),
        bodyMedium: TextStyle(color: AppPalette.ink),
        bodySmall: TextStyle(color: AppPalette.mutedInk),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.mutedInk,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.parchmentAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppPalette.slateBlue.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppPalette.slateBlue.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.ink, width: 1.4),
        ),
        prefixIconColor: AppPalette.mutedInk,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppPalette.ink,
        unselectedItemColor: AppPalette.mutedInk,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
