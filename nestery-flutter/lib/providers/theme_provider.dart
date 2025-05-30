import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider to manage app theme
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    // Load saved theme on initialization
    _loadTheme();
  }

  // Constructor for when SharedPreferences is not available (e.g., during loading or error)
  ThemeNotifier._withoutPrefs() : _prefs = null, super(ThemeMode.system);

  // Load theme from shared preferences
  void _loadTheme() {
    if (_prefs == null) return;

    final themeString = _prefs!.getString('theme_mode');
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
    if (_prefs != null) {
      await _prefs!.setString('theme_mode', themeMode.toString());
    }
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

// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  // Watch the SharedPreferences provider
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  // Return a default ThemeNotifier while SharedPreferences is loading
  return prefsAsync.when(
    data: (prefs) => ThemeNotifier(prefs),
    loading: () => ThemeNotifier._withoutPrefs(),
    error: (_, __) => ThemeNotifier._withoutPrefs(),
  );
});
