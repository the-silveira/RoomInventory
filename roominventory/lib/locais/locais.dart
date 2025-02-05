import 'package:flutter/material.dart';
import '/appbar/appbar.dart';
import '/drawer/drawer.dart';

class LocaisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Locais'),
      drawer: AppDrawer(),
      body: Center(
        child: Text(
          'Locais Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
