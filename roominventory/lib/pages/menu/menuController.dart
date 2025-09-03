import 'package:flutter/cupertino.dart';

import 'package:roominventory/pages/dimmers/dimmerUI.dart';

import 'package:roominventory/pages/events/menuEvents/menuEventsUI.dart';
import 'package:roominventory/pages/items/items/itemsUI.dart';

import 'package:roominventory/pages/places/places/placesUI.dart';
import 'package:roominventory/pages/settings/settingsUI.dart';

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
