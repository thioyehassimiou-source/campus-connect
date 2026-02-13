import 'package:flutter/material.dart';

class CampusColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Role colors
  static const Color student = Color(0xFF2563EB);
  static const Color teacher = Color(0xFF10B981);
  static const Color admin = Color(0xFFDC2626);
}

class CampusTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: 'Lexend',
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: 'Lexend',
  );
}

class CampusSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class CampusBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 50.0;
}
