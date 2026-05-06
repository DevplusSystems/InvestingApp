import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<ThemePreference> {
  ThemeNotifier() : super(ThemePreference.system) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      
      if (savedTheme != null) {
        state = ThemePreference.values.firstWhere(
          (theme) => theme.name == savedTheme,
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setTheme(ThemePreference theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', theme.name);
    } catch (e) {
      // Keep UI state even if persistence fails.
    }
  }

  ThemeMode getThemeMode() {
    switch (state) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  ThemeData getTheme(BuildContext context) {
    switch (state) {
      case ThemePreference.light:
        return ThemeData.light();
      case ThemePreference.dark:
        return ThemeData.dark();
      case ThemePreference.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light();
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreference>((ref) {
  return ThemeNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final preference = ref.watch(themeProvider);
  switch (preference) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
});

final themeIconProvider = Provider<IconData>((ref) {
  final preference = ref.watch(themeProvider);
  switch (preference) {
    case ThemePreference.light:
      return Icons.light_mode;
    case ThemePreference.dark:
      return Icons.dark_mode;
    case ThemePreference.system:
      return Icons.brightness_auto;
  }
});
