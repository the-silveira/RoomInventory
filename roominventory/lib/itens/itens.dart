import 'package:flutter/material.dart';
import '/appbar/appbar.dart';
import '/drawer/drawer.dart';

class ItensPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Itens'),
      drawer: AppDrawer(),
      body: Center(
        child: Text(
          'Itens Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
