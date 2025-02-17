import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Load theme preference from SharedPreferences
  Future<void> loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? themeData = prefs.getString('themeMode');
    if (themeData == "Dark") {
      _themeMode = ThemeMode.dark;
    } else if (themeData == "Light") {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system; // Default to system theme
    }
    notifyListeners();
  }

  // Save theme preference to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString('themeMode', 'Dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString('themeMode', 'Light');
    } else {
      await prefs.setString('themeMode', 'System');
    }
    notifyListeners(); // Notify listeners to rebuild the app
  }
}
