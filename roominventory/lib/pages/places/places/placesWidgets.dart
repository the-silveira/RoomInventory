import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A search bar widget for filtering places, zones, and items in the inventory.
///
/// This widget provides a Cupertino-style search text field that allows users
/// to search across all hierarchy levels (places, zones, and items) in real-time.
///
/// Features:
/// - iOS-style search interface with clear button
/// - Placeholder text indicating search scope
/// - Real-time filtering as user types
///
/// Example usage:
/// ```dart
/// SearchBar(
///   controller: _searchController,
///   onChanged: (query) => _filterPlaces(query),
/// )
/// ```
class SearchBar extends StatelessWidget {
  /// The controller for the search text field.
  ///
  /// Manages the text input and provides methods for controlling the search field.
  final TextEditingController controller;

  /// Callback function called when the search text changes.
  ///
  /// The function receives the current search text as a parameter and should
  /// handle the filtering logic for places, zones, and items.
  final Function(String) onChanged;

  /// Creates a search bar for filtering inventory data.
  ///
  /// Requires a [controller] to manage the text input and an [onChanged]
  /// callback to handle search text changes and filtering.
  const SearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        controller: controller,
        onChanged: onChanged,
        placeholder: 'Search places, zones, or items...',
      ),
    );
  }
}

/// A section widget that displays a place and its associated zones.
///
/// This widget represents the top level of the hierarchical structure,
/// showing a place name as the section header and containing all the
/// zones within that place.
///
/// Structure:
/// - Header: Place name with emphasized styling
/// - Content: List of ZoneSection widgets for each zone in the place
///
/// Example usage:
/// ```dart
/// PlaceSection(place: placeData)
/// ```
class PlaceSection extends StatelessWidget {
  /// The place data to display.
  ///
  /// Expected structure:
  /// ```dart
  /// {
  ///   'PlaceName': 'Place Name',
  ///   'Zones': {
  ///     'zoneId1': { ...zoneData },
  ///     'zoneId2': { ...zoneData }
  ///   }
  /// }
  /// ```
  final dynamic place;

  /// Creates a place section with its associated zones.
  ///
  /// Requires [place] data containing the place name and zones map.
  const PlaceSection({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
      header: Text(
        place['PlaceName'] ?? 'Unknown Place',
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        ...place['Zones'].entries.map((zoneEntry) {
          var zone = zoneEntry.value;
          return ZoneSection(zone: zone);
        }).toList(),
      ],
    );
  }
}

/// A section widget that displays a zone and its associated items.
///
/// This widget represents the middle level of the hierarchical structure,
/// showing a zone name as the section header and containing all the
/// items within that zone.
///
/// Uses inset grouping for visual distinction from the place level.
///
/// Structure:
/// - Header: Zone name with secondary styling
/// - Content: List of ItemListTile widgets for each item in the zone
///
/// Example usage:
/// ```dart
/// ZoneSection(zone: zoneData)
/// ```
class ZoneSection extends StatelessWidget {
  /// The zone data to display.
  ///
  /// Expected structure:
  /// ```dart
  /// {
  ///   'ZoneName': 'Zone Name',
  ///   'Items': {
  ///     'itemId1': { ...itemData },
  ///     'itemId2': { ...itemData }
  ///   }
  /// }
  /// ```
  final dynamic zone;

  /// Creates a zone section with its associated items.
  ///
  /// Requires [zone] data containing the zone name and items map.
  const ZoneSection({Key? key, required this.zone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        zone['ZoneName'] ?? 'Unknown Zone',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        ...zone['Items'].entries.map((itemEntry) {
          var item = itemEntry.value;
          return ItemListTile(item: item);
        }).toList(),
      ],
    );
  }
}

/// A list tile widget that displays individual item information and handles tap actions.
///
/// This widget represents the lowest level of the hierarchical structure,
/// showing item details and providing interaction through tap actions.
///
/// Features:
/// - Item name as primary text
/// - Item ID as secondary text
/// - Chevron indicator for action availability
/// - Tap action to show detailed item information
///
/// Example usage:
/// ```dart
/// ItemListTile(item: itemData)
/// ```
class ItemListTile extends StatelessWidget {
  /// The item data to display.
  ///
  /// Expected structure:
  /// ```dart
  /// {
  ///   'IdItem': 'item123',
  ///   'ItemName': 'Item Name',
  ///   'Details': [
  ///     {'DetailsName': 'Detail 1', 'Details': 'Value 1'},
  ///     {'DetailsName': 'Detail 2', 'Details': 'Value 2'}
  ///   ]
  /// }
  /// ```
  final dynamic item;

  /// Creates an item list tile with tap-to-detail functionality.
  ///
  /// Requires [item] data containing item identification and details.
  const ItemListTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(
        item['ItemName'] ?? 'Unknown Item',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        "ID: ${item['IdItem']}",
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Icon(CupertinoIcons.chevron_forward),
      onTap: () => _showItemDetails(context, item),
    );
  }

  /// Shows a modal bottom sheet with detailed item information.
  ///
  /// Displays a [CupertinoActionSheet] containing:
  /// - Item name as title
  /// - Item ID as message header
  /// - List of all item details with name-value pairs
  /// - Close button to dismiss the modal
  ///
  /// Parameters:
  /// - [context]: The build context for showing the modal
  /// - [item]: The item data to display in the details modal
  void _showItemDetails(BuildContext context, dynamic item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          item['ItemName'] ?? 'Unknown Item',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        message: Text(
          "ID: ${item['IdItem']}\n\nDetails:",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          ...item['Details'].map((detail) {
            return CupertinoActionSheetAction(
              child: Text(
                "${detail['DetailsName']}: ${detail['Details']}",
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () => Navigator.pop(context),
            );
          }).toList(),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

/// A widget that displays an empty state message when no places are available.
///
/// This widget is shown when the places list is empty, providing user feedback
/// that no locations have been registered in the system.
///
/// Features:
/// - Centered layout
/// - Informative message text
/// - Theme-appropriate styling
///
/// Example usage:
/// ```dart
/// EmptyState()
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget for the places page.
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text(
        "Não tem Locais Registados",
        style: TextStyle(
          fontSize: 16,
          color: CupertinoTheme.of(context).textTheme.textStyle.color,
        ),
      ),
    ));
  }
}

/// A modal action sheet that provides options for adding new inventory elements.
///
/// This widget presents users with a choice between adding a new place or a new zone
/// using a Cupertino-style action sheet.
///
/// Features:
/// - Title and message explaining the options
/// - Separate actions for adding places and zones
/// - Cancel button to dismiss without action
///
/// Example usage:
/// ```dart
/// AddOptionsSheet(
///   onAddPlace: () => _navigateToAddPlace(),
///   onAddZone: () => _navigateToAddZone(),
/// )
/// ```
class AddOptionsSheet extends StatelessWidget {
  /// Callback function for the "Add Place" action.
  ///
  /// Typically navigates to the add place page.
  final Function() onAddPlace;

  /// Callback function for the "Add Zone" action.
  ///
  /// Typically navigates to the add zone page.
  final Function() onAddZone;

  /// Creates an action sheet with options for adding places or zones.
  ///
  /// Requires callback functions for both add actions.
  const AddOptionsSheet({
    Key? key,
    required this.onAddPlace,
    required this.onAddZone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Add New'),
      message: Text('What would you like to add?'),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Add Place'),
          onPressed: onAddPlace,
        ),
        CupertinoActionSheetAction(
          child: Text('Add Zone'),
          onPressed: onAddZone,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
