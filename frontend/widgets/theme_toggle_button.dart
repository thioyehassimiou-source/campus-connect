import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    
    print('🎨 ThemeToggleButton rebuild - thème actuel: ${themeService.currentThemeMode}');
    
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        print('🔄 ValueListenableBuilder - thème: $themeMode');
        
        return IconButton(
          icon: Icon(themeService.themeIcon),
          onPressed: () async {
            print('🔘 Clic sur le bouton thème');
            await themeService.toggleTheme();
          },
          tooltip: 'Basculer vers le mode ${themeService.themeLabel}',
          iconSize: 24,
          color: Theme.of(context).iconTheme.color,
        );
      },
    );
  }
}
