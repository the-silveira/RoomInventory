import 'package:flutter/cupertino.dart';

import 'package:roominventory/pages/dimmers/dimmerUI.dart';

import 'package:roominventory/pages/events/menuEvents/menuEventsUI.dart';
import 'package:roominventory/pages/items/items/itemsUI.dart';

import 'package:roominventory/pages/places/places/placesUI.dart';
import 'package:roominventory/pages/settings/settingsUI.dart';

/// A controller class that handles navigation between different pages in the application.
///
/// This class provides methods to navigate to various sections of the app including:
/// - Events management
/// - Items inventory
/// - Places/locations
/// - DMX dimmers configuration
/// - Application settings
///
/// Each navigation method uses [CupertinoPageRoute] for iOS-style page transitions.
///
/// Example usage:
/// ```dart
/// final menuController = MenuPageController();
///
/// // Navigate to items page
/// menuController.navigateToItens(context);
///
/// // Navigate to settings
/// menuController.navigateToDefinicoes(context);
/// ```
class MenuPageController {
  /// Navigates to the Events management page.
  ///
  /// Pushes [menuEventosPage] onto the navigation stack with a Cupertino-style transition.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used for navigation
  void navigateToEventos(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => menuEventosPage()),
    );
  }

  /// Navigates to the Items inventory page.
  ///
  /// Pushes [ItemsPage] onto the navigation stack with a Cupertino-style transition.
  /// This page typically displays and manages inventory items.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used for navigation
  void navigateToItens(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ItemsPage()),
    );
  }

  /// Navigates to the Places/Locations management page.
  ///
  /// Pushes [PlacesPage] onto the navigation stack with a Cupertino-style transition.
  /// This page typically manages different physical locations or rooms.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used for navigation
  void navigateToLocais(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => PlacesPage()),
    );
  }

  /// Navigates to the DMX Dimmers configuration page.
  ///
  /// Pushes [DMXConfigPage] onto the navigation stack with a Cupertino-style transition.
  /// This page is used for configuring DMX lighting controls and dimmers.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used for navigation
  void navigateToDimmers(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => DMXConfigPage()),
    );
  }

  /// Navigates to the Application Settings page.
  ///
  /// Pushes [SettingsPage] onto the navigation stack with a Cupertino-style transition.
  /// This page typically contains application configuration and preferences.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used for navigation
  void navigateToDefinicoes(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SettingsPage()),
    );
  }
}
