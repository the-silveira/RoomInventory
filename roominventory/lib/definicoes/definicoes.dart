import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/appbar/appbar.dart';

import 'provider.dart'; // Import the ThemeProvider

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Definições',
      ),
      child: ListView(
        children: <Widget>[
          // Preferences Section
          CupertinoListSection.insetGrouped(
            header: Text(
              'Preferences',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
            children: [
              CupertinoListTile.notched(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                trailing: CupertinoSwitch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
