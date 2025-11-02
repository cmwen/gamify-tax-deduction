import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles persisting and broadcasting the user's theme preference.
class ThemeService extends ChangeNotifier {
  static const _storageKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _isLoaded;

  ThemeService() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_storageKey);
    if (modeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == modeName,
        orElse: () => ThemeMode.system,
      );
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }
}
