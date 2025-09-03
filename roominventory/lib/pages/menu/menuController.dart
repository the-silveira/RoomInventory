import 'package:flutter/cupertino.dart';

import 'package:roominventory/dimmers/dimmerUI.dart';

import 'package:roominventory/events/menuEvents/menuEventsUI.dart';
import 'package:roominventory/items/items/itemsUI.dart';

import 'package:roominventory/places/places/placesUI.dart';
import 'package:roominventory/settings/settingsUI.dart';

class MenuPageController {
  // Navigation functions
  void navigateToEventos(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => menuEventosPage()),
    );
  }

  void navigateToItens(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ItemsPage()),
    );
  }

  void navigateToLocais(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => PlacesPage()),
    );
  }

  void navigateToDimmers(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => DMXConfigPage()),
    );
  }

  void navigateToDefinicoes(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SettingsPage()),
    );
  }
}
