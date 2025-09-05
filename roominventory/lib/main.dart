import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roominventory/pages/menu/menuUI.dart';
import 'package:roominventory/classes/themes.dart';
import 'classes/provider.dart'; // Import the ThemeProvider
import 'package:firebase_core/firebase_core.dart';
import 'classes/firebase_options.dart';

/// The main entry point of the Room Inventory application.
///
/// This function:
/// 1. Ensures Flutter widgets are properly initialized
/// 2. Initializes Firebase with platform-specific configuration
/// 3. Sets up the ThemeProvider for application-wide theme management
/// 4. Runs the application with the root widget
///
/// Firebase Configuration:
/// - Uses [DefaultFirebaseOptions.currentPlatform] for platform-specific setup
/// - Supports both iOS and Android Firebase configurations
///
/// Theme Management:
/// - Wraps the application with [ChangeNotifierProvider] for theme state
/// - Uses [ThemeProvider] to manage light/dark theme preferences
///
/// Example usage:
/// ```dart
/// void main() => runApp(MyApp());
/// ```
Future<void> main() async {
  // Ensure Flutter framework is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the application with theme provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

/// The root widget of the Room Inventory application.
///
/// This widget:
/// - Manages application-level state and configuration
/// - Provides theme management through [ThemeProvider]
/// - Serves as the entry point for the MaterialApp
/// - Handles initial theme loading on app startup
///
/// The application features:
/// - Firebase integration for authentication and services
/// - Dynamic theme switching (light/dark mode)
/// - Cupertino-style design for iOS platform consistency
/// - Responsive layout and navigation
///
/// Theme System:
/// - Uses [AppThemes.lightTheme] for light mode
/// - Uses [AppThemes.darkTheme] for dark mode
/// - Persists user theme preference across app restarts
///
/// Navigation:
/// - Starts with [MenuPage] as the home screen
/// - Provides inventory management navigation hub
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

/// The state class for [MyApp], managing application-level initialization.
///
/// This state class handles:
/// - Theme preference loading on application start
/// - Provider context access for theme management
/// - Application lifecycle-related initialization
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Load the theme preference when the app starts
    Provider.of<ThemeProvider>(context, listen: false).loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    /// Accesses the theme provider to get current theme mode.
    final themeProvider = Provider.of<ThemeProvider>(context);

    /// Builds the MaterialApp with configured theme and routing.
    ///
    /// Returns a [MaterialApp] configured with:
    /// - Application title and branding
    /// - Light and dark theme definitions
    /// - Dynamic theme mode based on user preference
    /// - [MenuPage] as the initial home screen
    ///
    /// The MaterialApp uses Cupertino-style components throughout
    /// for consistent iOS-style user experience.
    return MaterialApp(
      /// Application title displayed in task manager and app switcher
      title: 'Room Inventory',

      /// Light theme configuration using predefined AppThemes
      theme: AppThemes.lightTheme,

      /// Dark theme configuration using predefined AppThemes
      darkTheme: AppThemes.darkTheme,

      /// Current theme mode determined by user preference
      /// Can be: ThemeMode.light, ThemeMode.dark, or ThemeMode.system
      themeMode: themeProvider.themeMode,

      /// The initial home screen of the application
      /// [MenuPage] serves as the main navigation hub for the inventory system
      home: MenuPage(),
    );
  }
}
