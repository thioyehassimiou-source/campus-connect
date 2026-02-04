import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  static const String _themeKey = 'theme_mode';
  
  // Notifier pour écouter les changements de thème
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  /// Initialise le service et charge le thème sauvegardé
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
      print('🎨 Thème initialisé: ${themeModeNotifier.value}');
    } catch (e) {
      print('Erreur lors du chargement du thème: $e');
    }
  }

  /// Bascule entre le mode clair et sombre
  Future<void> toggleTheme() async {
    final oldMode = themeModeNotifier.value;
    final newMode = oldMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    print('🔄 Changement de thème: $oldMode → $newMode');
    
    themeModeNotifier.value = newMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
      print('✅ Thème sauvegardé: $newMode');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du thème: $e');
    }
  }

  /// Retourne le mode actuel
  ThemeMode get currentThemeMode => themeModeNotifier.value;
  
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  /// Obtenir l'icône appropriée
  IconData get themeIcon => isDarkMode ? Icons.light_mode : Icons.dark_mode;
  
  /// Obtenir le libellé du thème
  String get themeLabel => isDarkMode ? 'Clair' : 'Sombre';
}
