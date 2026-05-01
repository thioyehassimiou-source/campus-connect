import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Thème Clair (Inspiré de Stripe & Apple) ---
  static const Color _lightPrimary = Color(0xFF6366F1);    // Indigo 500
  static const Color _lightAccent = Color(0xFF8B5CF6);     // Violet 500
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _lightSurface = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color _lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color _lightBorder = Color(0xFFE2E8F0);    // Slate 200

  // --- Thème Sombre (Inspiré de GitHub & Vercel) ---
  static const Color _darkPrimary = Color(0xFF818CF8);      // Indigo 400
  static const Color _darkBackground = Color(0xFF020617);   // Slate 950
  static const Color _darkSurface = Color(0xFF0F172A);      // Slate 900
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);  // Slate 50
  static const Color _darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color _darkBorder = Color(0xFF1E293B);       // Slate 800

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        primary: _lightPrimary,
        secondary: _lightAccent,
        surface: _lightSurface,
        background: _lightBackground,
        error: const Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _lightTextPrimary),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: _lightTextPrimary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _lightTextPrimary),
        bodyLarge: GoogleFonts.inter(color: _lightTextPrimary),
        bodyMedium: GoogleFonts.inter(color: _lightTextSecondary),
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: _lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: _lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: _lightTextSecondary, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        primary: _darkPrimary,
        secondary: _darkPrimary,
        surface: _darkSurface,
        background: _darkBackground,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _darkTextPrimary),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: _darkTextPrimary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _darkTextPrimary),
        bodyLarge: GoogleFonts.inter(color: _darkTextPrimary),
        bodyMedium: GoogleFonts.inter(color: _darkTextSecondary),
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: _darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _darkPrimary,
          foregroundColor: _darkBackground,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: _darkTextSecondary, fontSize: 14),
      ),
    );
  }
}
