import 'package:flutter/material.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  ThemeMode get themeMode => themeModeNotifier.value;
  
  String get currentThemeMode => themeMode.toString();
  
  IconData get themeIcon => themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode;
  
  String get themeLabel => themeMode == ThemeMode.dark ? 'clair' : 'sombre';

  Future<void> init() async {
    return;
  }

  Future<void> toggleTheme() async {
    if (themeModeNotifier.value == ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
}
