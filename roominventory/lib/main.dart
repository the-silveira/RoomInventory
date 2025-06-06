import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roominventory/drawer/drawer.dart';
import 'definicoes/provider.dart'; // Import the ThemeProvider
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
          seedColor: CupertinoColors.activeBlue,
          primary: CupertinoColors.activeBlue,
          brightness: Brightness.light, // Light theme
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Custom text color
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.activeBlue,
          primary: CupertinoColors.activeBlue,
          brightness: Brightness.dark, // Dark theme
        ),
        textTheme: TextTheme(
          bodyLarge:
              TextStyle(color: Colors.white), // Custom text color for dark mode
        ),
      ),
      themeMode: themeProvider.themeMode, // Use the selected theme mode
      home: OptionsPage(), // Directly navigate to OptionsPage
    );
  }
}
