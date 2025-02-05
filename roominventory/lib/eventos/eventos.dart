import 'package:flutter/material.dart';
import '/appbar/appbar.dart';
import '/drawer/drawer.dart';

class EventosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: 'Eventos'),
      drawer: AppDrawer(),
      body: Center(
        child: Text(
          'Eventos Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
