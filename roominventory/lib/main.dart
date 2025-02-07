import 'package:flutter/material.dart';

import 'eventos/eventos.dart'; // Import the EventosPage

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
      home: EventosPage(), // Change this to navigate directly to EventosPage
    );
  }
}
