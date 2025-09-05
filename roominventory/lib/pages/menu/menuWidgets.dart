import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/calendar/calendar.dart';
import 'package:roominventory/pages/menu/menuController.dart';

/// A section widget that provides navigation to main application features.
///
/// This widget displays a grouped list of navigation options including:
/// - Eventos (Events)
/// - Itens (Items)
/// - Locais (Places/Locations)
/// - Dimmers (DMX Controls)
///
/// Each option is represented as a [CupertinoListTile] with an icon and chevron indicator.
/// Tapping on any tile navigates to the corresponding page using the provided controller.
///
/// Example usage:
/// ```dart
/// NavigationSection(
///   controller: menuController,
///   context: context,
/// )
/// ```
class NavigationSection extends StatelessWidget {
  /// The controller responsible for handling navigation between pages.
  final MenuPageController controller;

  /// The build context used for navigation and theming.
  final BuildContext context;

  /// Creates a navigation section with main application features.
  ///
  /// Requires a [controller] for navigation and a [context] for building the widget.
  const NavigationSection({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        _buildListTile(
          context: context,
          title: 'Eventos',
          icon: CupertinoIcons.list_dash,
          onTap: () => controller.navigateToEventos(context),
        ),
        _buildListTile(
          context: context,
          title: 'Itens',
          icon: CupertinoIcons.cube_box_fill,
          onTap: () => controller.navigateToItens(context),
        ),
        _buildListTile(
          context: context,
          title: 'Locais',
          icon: CupertinoIcons.map_fill,
          onTap: () => controller.navigateToLocais(context),
        ),
        _buildListTile(
          context: context,
          title: 'Dimmers',
          icon: CupertinoIcons.cube_box_fill,
          onTap: () => controller.navigateToDimmers(context),
        ),
      ],
    );
  }

  /// Builds a standardized list tile for navigation items.
  ///
  /// Creates a [CupertinoListTile.notched] with consistent styling:
  /// - Title text colored according to the theme
  /// - Blue system icon
  /// - Standard chevron indicator
  /// - Tap handler for navigation
  ///
  /// Parameters:
  /// - [context]: The build context for theming
  /// - [title]: The text to display in the tile
  /// - [icon]: The icon to display on the left side
  /// - [onTap]: The callback function when the tile is tapped
  ///
  /// Returns a configured [CupertinoListTile] widget.
  Widget _buildListTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile.notched(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      leading: Icon(
        icon,
        color: CupertinoColors.systemBlue,
      ),
      trailing: CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}

/// A section widget for application preferences and settings.
///
/// This widget provides access to the application settings page through
/// a single [CupertinoListTile] with a settings icon.
///
/// Example usage:
/// ```dart
/// PreferencesSection(
///   controller: menuController,
///   context: context,
/// )
/// ```
class PreferencesSection extends StatelessWidget {
  /// The controller responsible for handling navigation to settings.
  final MenuPageController controller;

  /// The build context used for navigation and theming.
  final BuildContext context;

  /// Creates a preferences section with settings navigation.
  ///
  /// Requires a [controller] for navigation and a [context] for building the widget.
  const PreferencesSection({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile.notched(
          title: Text(
            'Definições',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          leading: Icon(
            CupertinoIcons.settings,
            color: CupertinoColors.systemBlue,
          ),
          trailing: CupertinoListTileChevron(),
          onTap: () => controller.navigateToDefinicoes(context),
        ),
      ],
    );
  }
}

/// A section widget that displays a calendar component.
///
/// This widget embeds a [CalendarWidget] within a fixed-height container
/// to show event calendar information. The calendar has a fixed height
/// of 700 logical pixels to ensure consistent layout.
///
/// Example usage:
/// ```dart
/// CalendarSection()
/// ```
class CalendarSection extends StatelessWidget {
  /// Creates a calendar section widget.
  const CalendarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        Container(
          height: 700,
          child: CalendarWidget(),
        ),
      ],
    );
  }
}
