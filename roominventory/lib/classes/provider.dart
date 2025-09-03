import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A ChangeNotifier that manages the application's theme mode and persistence.
///
/// The [ThemeProvider] class handles:
/// - Storing and retrieving theme preferences using [SharedPreferences]
/// - Notifying listeners when the theme changes
/// - Supporting three theme modes: light, dark, and system default
///
/// ## Features:
/// - **Persistence**: Theme preferences are saved locally and restored on app launch
/// - **System Integration**: Respects the device's system theme setting
/// - **Change Notifications**: Automatically notifies widgets to rebuild on theme changes
///
/// ## Usage:
/// ```dart
/// // Wrap your app with ChangeNotifierProvider
/// ChangeNotifierProvider(
///   create: (context) => ThemeProvider()..loadTheme(),
///   child: MyApp(),
/// );
///
/// // Access the theme provider in widgets
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// themeProvider.setThemeMode(ThemeMode.dark);
/// ```
///
/// ## Theme Modes:
/// - [ThemeMode.light]: Force light theme
/// - [ThemeMode.dark]: Force dark theme
/// - [ThemeMode.system]: Follow system theme setting
///
/// ## Storage Format:
/// Theme preferences are stored as strings in SharedPreferences:
/// - "Light" for [ThemeMode.light]
/// - "Dark" for [ThemeMode.dark]
/// - "System" for [ThemeMode.system]
class ThemeProvider with ChangeNotifier {
  /// The current theme mode of the application.
  ///
  /// Defaults to [ThemeMode.system] until preferences are loaded.
  /// Use [themeMode] to get the current theme and [setThemeMode] to change it.
  ThemeMode _themeMode = ThemeMode.system;

  /// Gets the current theme mode.
  ///
  /// Returns the currently active [ThemeMode] which can be:
  /// - [ThemeMode.light]
  /// - [ThemeMode.dark]
  /// - [ThemeMode.system]
  ///
  /// This is typically used to configure the [Theme] widget:
  /// ```dart
  /// MaterialApp(
  ///   themeMode: themeProvider.themeMode,
  ///   theme: ThemeData.light(),
  ///   darkTheme: ThemeData.dark(),
  /// )
  /// ```
  ThemeMode get themeMode => _themeMode;

  /// Loads the theme preference from persistent storage.
  ///
  /// This method should be called during app initialization to restore
  /// the user's theme preference from the previous session.
  ///
  /// ## Implementation:
  /// 1. Reads from [SharedPreferences]
  /// 2. Parses the stored string value
  /// 3. Sets the appropriate [ThemeMode]
  /// 4. Notifies listeners to update the UI
  ///
  /// ## Storage Keys:
  /// Uses the key 'themeMode' in SharedPreferences
  ///
  /// ## Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   final themeProvider = ThemeProvider();
  ///   await themeProvider.loadTheme();
  ///   runApp(MyApp(themeProvider: themeProvider));
  /// }
  /// ```
  ///
  /// ## Throws:
  /// May throw [Exception] if SharedPreferences cannot be accessed
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

  /// Changes the application's theme mode and persists the preference.
  ///
  /// ## Parameters:
  /// [mode] - The new [ThemeMode] to apply
  ///
  /// ## Actions:
  /// 1. Updates the internal theme mode state
  /// 2. Saves the preference to [SharedPreferences] for persistence
  /// 3. Notifies all listeners to rebuild dependent widgets
  ///
  /// ## Storage:
  /// Saves the theme preference using the following mapping:
  /// - [ThemeMode.dark] → "Dark"
  /// - [ThemeMode.light] → "Light"
  /// - [ThemeMode.system] → "System"
  ///
  /// ## Example:
  /// ```dart
  /// // Change to dark theme
  /// themeProvider.setThemeMode(ThemeMode.dark);
  ///
  /// // Change to system default
  /// themeProvider.setThemeMode(ThemeMode.system);
  /// ```
  ///
  /// ## Throws:
  /// May throw [Exception] if SharedPreferences cannot be accessed
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
