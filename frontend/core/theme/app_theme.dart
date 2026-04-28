import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusconnect/core/constants/app_constants.dart';

class AppTheme {
  // --- Couleurs Thème Clair (Existantes) ---
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightSurface = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF64748B);

  // --- Couleurs Thème Sombre (Nouveau Design Premium) ---
  static const Color _darkPrimary = Color(0xFF3B82F6);
  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color _darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color _darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color _darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lexend',
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        primary: _lightPrimary,
        background: _lightBackground,
        surface: _lightSurface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightSurface,
      
      iconTheme: const IconThemeData(
        color: _lightTextSecondary,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _lightTextPrimary),
        bodyMedium: TextStyle(color: _lightTextSecondary),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _lightTextSecondary),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lexend',
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightTextSecondary,
        elevation: 0,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        color: _lightSurface,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lexend',
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        primary: _darkPrimary,
        background: _darkBackground,
        surface: _darkSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkSurface,
      
      iconTheme: const IconThemeData(
        color: _darkTextSecondary,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkTextPrimary),
        bodyMedium: TextStyle(color: _darkTextSecondary),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _darkTextSecondary),
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lexend',
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _lightTextSecondary, // Keep same unselected color for consistency
        elevation: 0,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        color: _darkSurface,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
