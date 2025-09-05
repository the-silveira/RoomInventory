import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:roominventory/globalWidgets/appbar/appbar.dart';

import 'package:roominventory/pages/places/addPlaces/addPlacesUI.dart';
import 'package:roominventory/pages/places/addZones/addZonesUI.dart';
import 'package:roominventory/pages/places/places/placesController.dart';
import 'package:roominventory/pages/places/places/placesWidgets.dart';

/// The main places management page that displays a hierarchical view of places, zones, and items.
///
/// This page provides:
/// - A searchable list of places with their associated zones and items
/// - Add functionality for both places and zones
/// - Real-time filtering across all hierarchy levels
/// - Loading states and empty state handling
///
/// The page uses a [PlacesController] to manage data fetching, processing, and filtering,
/// and displays the data using various widget components from [placesWidgets].
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => PlacesPage()),
/// );
/// ```
class PlacesPage extends StatefulWidget {
  @override
  _PlacesPageState createState() => _PlacesPageState();
}

/// The state class for [PlacesPage], managing the places data and user interactions.
///
/// This state class handles:
/// - Controller initialization and data loading
/// - Search filtering functionality
/// - Navigation to add place/zone pages
/// - UI state management (loading, empty, data states)
class _PlacesPageState extends State<PlacesPage> {
  /// Controller responsible for fetching, processing, and filtering places data.
  ///
  /// Manages the hierarchical data structure and provides filtering capabilities
  /// across places, zones, and items.
  final PlacesController _controller = PlacesController();

  /// Controller for the search text field.
  ///
  /// Manages the search input and works with [_filterPlaces] to provide
  /// real-time filtering of the places data.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads places data from the API and updates the UI.
  ///
  /// This method:
  /// 1. Calls the controller's [fetchData] method to retrieve data from the API
  /// 2. Triggers a UI rebuild with [setState] when data loading completes
  /// 3. Handles any errors through the controller's errorMessage property
  ///
  /// Typically called during initialization and after adding new places/zones.
  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  /// Filters the places data based on the provided search query.
  ///
  /// This method:
  /// 1. Delegates filtering to the controller's [filterPlaces] method
  /// 2. Triggers a UI rebuild to display the filtered results
  /// 3. Handles empty queries by resetting to show all data
  ///
  /// Parameters:
  /// - [query]: The search string to filter by
  ///
  /// The filtering is case-insensitive and searches across:
  /// - Place names
  /// - Zone names
  /// - Item names
  /// - Item IDs
  void _filterPlaces(String query) {
    setState(() {
      _controller.filterPlaces(query);
    });
  }

  /// Shows a modal bottom sheet with options to add a new place or zone.
  ///
  /// Displays a [CupertinoActionSheet] with two options:
  /// - "Add Place": Navigates to [AddPlacePage]
  /// - "Add Zone": Navigates to [AddZonePage]
  ///
  /// Uses [showCupertinoModalPopup] for iOS-style modal presentation.
  void _navigateToAdd() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddOptionsSheet(
        onAddPlace: () {
          Navigator.pop(context);
          _navigateToAddPlace();
        },
        onAddZone: () {
          Navigator.pop(context);
          _navigateToAddZone();
        },
      ),
    );
  }

  /// Navigates to the Add Place page and reloads data upon return.
  ///
  /// Uses [CupertinoPageRoute] for iOS-style page transition.
  /// After returning from the add page, calls [_loadData] to refresh the list.
  void _navigateToAddPlace() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddPlacePage()),
    ).then((_) => _loadData());
  }

  /// Navigates to the Add Zone page and reloads data upon return.
  ///
  /// Uses [CupertinoPageRoute] for iOS-style page transition.
  /// After returning from the add page, calls [_loadData] to refresh the list.
  void _navigateToAddZone() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddZonePage()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the places page interface with hierarchical data display.
    ///
    /// Returns a [CupertinoPageScaffold] containing:
    /// - Custom navigation bar with title and add button
    /// - Search bar for filtering data
    /// - Expandable list view with:
    ///   - Loading indicator during data fetch
    ///   - Empty state when no data is available
    ///   - Hierarchical list of places → zones → items when data is available
    ///
    /// The layout adapts to different states: loading, empty, and data states.
    return CupertinoPageScaffold(
      /// Custom navigation bar with title, back button, and add action
      navigationBar: CustomNavigationBar(
        title: 'Places',
        previousPageTitle: 'Inventário',
        onAddPressed: _navigateToAdd,
      ),

      /// Main content area with search and data display
      child: SafeArea(
        child: Column(
          children: [
            /// Search bar for filtering places, zones, and items
            SearchBar(
              controller: _searchController,
              onChanged: _filterPlaces,
            ),

            /// Expandable area for displaying data based on current state
            Expanded(
              child: _controller.isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : _controller.filteredPlaces.isEmpty
                      ? EmptyState()
                      : ListView.builder(
                          itemCount: _controller.filteredPlaces.length,
                          itemBuilder: (context, placeIndex) {
                            var place = _controller.filteredPlaces[placeIndex];
                            return PlaceSection(place: place);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
