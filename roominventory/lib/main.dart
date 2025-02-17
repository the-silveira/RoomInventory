import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roominventory/drawer/drawer.dart';
import 'definicoes/provider.dart'; // Import the ThemeProvider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Load the theme preference when the app starts
    Provider.of<ThemeProvider>(context, listen: false).loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Room Inventory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Light theme
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Custom text color
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark, // Dark theme
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Custom text color for dark mode
        ),
      ),
      themeMode: themeProvider.themeMode, // Use the selected theme mode
      home: OptionsPage(), // Directly navigate to OptionsPage
    );
  }
}
