import 'package:flutter/material.dart';
import '/appbar/appbar.dart';
import '/drawer/drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Home'),
      drawer: AppDrawer(), // Drawer should be here too!
      body: Center(
        child: Text(
          'Welcome to Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
