import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFFB3D9);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryPink,
        secondary: primaryPink,
        surface: darkCard,
        background: darkBackground,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIconColor: Colors.grey,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        labelLarge: TextStyle(color: primaryPink, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: Colors.black,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        secondary: primaryPink,
        surface: lightCard,
        background: lightBackground,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIconColor: Colors.grey.shade600,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
        labelLarge: TextStyle(color: primaryPink, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: Colors.black,
      ),
    );
  }
}
