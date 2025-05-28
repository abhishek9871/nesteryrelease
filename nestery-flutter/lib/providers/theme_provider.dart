import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider to manage app theme
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    // Load saved theme on initialization
    _loadTheme();
  }

  // Load theme from shared preferences
  void _loadTheme() {
    final themeString = _prefs.getString('theme_mode');
    if (themeString != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  // Set theme and save to shared preferences
  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    await _prefs.setString('theme_mode', themeMode.toString());
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
}

// Provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  // This will be initialized when the app starts
  final prefs = SharedPreferences.getInstance();
  return ThemeNotifier(prefs as SharedPreferences);
});
