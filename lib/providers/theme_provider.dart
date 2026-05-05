import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme');
    
    if (savedTheme != null) {
      state = AppTheme.values.firstWhere(
        (theme) => theme.name == savedTheme,
        orElse: () => AppTheme.system,
      );
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case AppTheme.light:
        await setTheme(AppTheme.dark);
        break;
      case AppTheme.dark:
        await setTheme(AppTheme.light);
        break;
      case AppTheme.system:
        await setTheme(AppTheme.light);
        break;
    }
  }

  ThemeData getTheme(BuildContext context) {
    switch (state) {
      case AppTheme.light:
        return ThemeData.light();
      case AppTheme.dark:
        return ThemeData.dark();
      case AppTheme.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light();
    }
  }

  ThemeMode getThemeMode() {
    switch (state) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    switch (state) {
      case AppTheme.light:
        return false;
      case AppTheme.dark:
        return true;
      case AppTheme.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  IconData getThemeIcon() {
    switch (state) {
      case AppTheme.light:
        return Icons.dark_mode;
      case AppTheme.dark:
        return Icons.light_mode;
      case AppTheme.system:
        return Icons.brightness_auto;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider.notifier).getThemeMode();
});

final themeIconProvider = Provider<IconData>((ref) {
  return ref.watch(themeProvider.notifier).getThemeIcon();
});
