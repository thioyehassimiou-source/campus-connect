import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Vibrant Blue from Design)
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue
  static const Color primaryLight = Color(0xFF60A5FA); 
  static const Color primaryDark = Color(0xFF1E40AF); 

  // Secondary/Accent Colors (Teal/Green from Design)
  static const Color secondary = Color(0xFF10B981); // Emerald/Teal
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Backgrounds
  static const Color background = Color(0xFFF3F4F6); // Light Gray
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1F2937); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textLight = Color(0xFF9CA3AF); // Gray 400

  // Status
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color info = Color(0xFF2563EB); // Blue 600
}

class AppConstants {
  static const String appName = 'CampusConnect';
  static const String universityName = 'Université de Labé';
  
  // Storage Buckets
  static const String documentsBucket = 'documents';
  static const String avatarsBucket = 'avatars';
}
