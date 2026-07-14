import 'package:flutter/material.dart';

class AppPalette {
  static const Color midnightNavy = Color(0xff0a1b33);
  static const Color courtroomBlue = Color(0xff14304f);
  static const Color slateBlue = Color(0xff647083);
  static const Color parchment = Color(0xfff6f5f1);
  static const Color parchmentAlt = Color(0xfffbfaf7);
  static const Color gold = Color(0xffc9a86a);
  static const Color goldDark = Color(0xff9a7b3f);
  static const Color ink = Color(0xff11192a);
  static const Color mutedInk = Color(0xff5b6573);

  static const Color success = Color(0xff1e7a4d);
  static const Color successBg = Color(0xffe8f3ee);
  static const Color errorBg = Color(0xfffbecea);
  static const Color hairline = Color(0xffe7e4dc);
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.midnightNavy,
      brightness: Brightness.light,
      primary: AppPalette.midnightNavy,
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
          backgroundColor: AppPalette.midnightNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.midnightNavy,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.parchmentAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.midnightNavy, width: 1.4),
        ),
        prefixIconColor: AppPalette.mutedInk,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppPalette.midnightNavy,
        unselectedItemColor: AppPalette.mutedInk,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
