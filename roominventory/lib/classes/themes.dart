import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A comprehensive theme configuration class providing both light and dark themes.
///
/// The [AppThemes] class contains pre-configured Material 3 themes that follow
/// Cupertino design principles while maintaining Material Design compatibility.
/// It provides consistent theming across the entire application with proper
/// color schemes, typography, and component styling.
///
/// ## Features:
/// - **Material 3 Support**: Uses Material 3 design system with [useMaterial3: true]
/// - **Cupertino Integration**: Incorporates Cupertino colors and design patterns
/// - **Complete Theming**: Includes all major theme components (colors, text, inputs, etc.)
/// - **Consistent Design**: Maintains visual consistency across light and dark modes
///
/// ## Usage:
/// ```dart
/// MaterialApp(
///   theme: AppThemes.lightTheme,
///   darkTheme: AppThemes.darkTheme,
///   themeMode: ThemeMode.system, // Or use with ThemeProvider
///   // ... other app configuration
/// );
/// ```
///
/// ## Theme Components:
/// - Color schemes with proper semantic colors
/// - App bar styling with elevation and colors
/// - Input decoration themes for text fields
/// - Card themes with rounded corners and shadows
/// - SnackBar styling for notifications
/// - Chip themes for filter and choice chips
/// - Bottom navigation bar styling
/// - Comprehensive text theme hierarchy
///
/// ## Design Principles:
/// - Follows Cupertino color system with [CupertinoColors.activeBlue] as primary
/// - Uses rounded corners (12-16px radius) for modern look
/// - Maintains proper contrast ratios for accessibility
/// - Provides consistent spacing and elevation
class AppThemes {
  /// Light theme configuration with blue primary color and light backgrounds.
  ///
  /// This theme provides a clean, modern light interface with:
  /// - Primary color: [CupertinoColors.activeBlue]
  /// - Background: Light grey ([Colors.grey[50]])
  /// - Surface: White for cards and containers
  /// - Text: Black and dark gray for readability
  ///
  /// ## Color Scheme:
  /// - Primary: Cupertino Blue (#007AFF)
  /// - Surface: White (#FFFFFF)
  /// - Background: Light grey (#FAFAFA)
  /// - Error: Red (#FF0000)
  ///
  /// ## Component Styles:
  /// - App bars: White background with black text, no elevation
  /// - Cards: White with subtle shadow and 16px border radius
  /// - Inputs: Light grey filled background with blue focus border
  /// - Buttons: Blue background with white text
  /// - SnackBars: Blue floating notifications
  ///
  /// ## Typography:
  /// - Headline Large: 32px, bold, black
  /// - Headline Medium: 24px, semibold, black87
  /// - Body Large: 16px, black87
  /// - Body Medium: 14px, black54
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.activeBlue,
      primary: CupertinoColors.activeBlue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Colors.grey[50]!,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black87,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CupertinoColors.activeBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: Colors.black12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: CupertinoColors.activeBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black45),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: CupertinoColors.activeBlue,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blue.shade50,
      selectedColor: CupertinoColors.activeBlue,
      labelStyle: const TextStyle(color: Colors.black87),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: CupertinoColors.activeBlue,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      headlineMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  );

  /// Dark theme configuration with blue primary color and dark backgrounds.
  ///
  /// This theme provides a comfortable dark interface with:
  /// - Primary color: [CupertinoColors.activeBlue]
  /// - Background: True black (#000000)
  /// - Surface: Dark grey ([Colors.grey[900]]) for cards
  /// - Text: White and light gray for readability
  ///
  /// ## Color Scheme:
  /// - Primary: Cupertino Blue (#007AFF)
  /// - Surface: Dark grey (#121212)
  /// - Background: Black (#000000)
  /// - Error: Red accent (#FF5252)
  ///
  /// ## Component Styles:
  /// - App bars: Black background with white text
  /// - Cards: Dark grey with subtle shadow and 16px border radius
  /// - Inputs: Dark grey filled background with blue focus border
  /// - Buttons: Blue background with white text
  /// - SnackBars: Blue floating notifications
  ///
  /// ## Typography:
  /// - Headline Large: 32px, bold, white
  /// - Headline Medium: 24px, semibold, white70
  /// - Body Large: 16px, white70
  /// - Body Medium: 14px, white60
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.activeBlue,
      primary: CupertinoColors.activeBlue,
      secondary: Colors.blueAccent,
      surface: Colors.grey[900]!,
      background: Colors.black,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CupertinoColors.activeBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.grey[850],
      shadowColor: Colors.black54,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: CupertinoColors.activeBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: CupertinoColors.activeBlue,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blueGrey.shade700,
      selectedColor: CupertinoColors.activeBlue,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: CupertinoColors.activeBlue,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white70),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    ),
  );
}
