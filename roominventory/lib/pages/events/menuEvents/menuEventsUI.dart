import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/menuEvents/menuEventsController.dart';
import 'package:roominventory/pages/events/menuEvents/menuEventsWidgets.dart';

/// A page that displays a list of events with search and navigation capabilities.
///
/// This page serves as the main events menu where users can:
/// - View all events in a list format
/// - Search/filter events by ID or name
/// - Navigate to create new events
/// - Navigate to view event details
/// - See visual indicators of event status (past, current, future)
///
/// The page uses a [menuEventosController] to manage data operations and
/// [menuEventsWidgets] for UI components.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => menuEventosPage()),
/// );
/// ```
class menuEventosPage extends StatefulWidget {
  @override
  _menuEventosPageState createState() => _menuEventosPageState();
}

/// The state class for [menuEventosPage] that manages the events list UI and interactions.
///
/// This state class handles:
/// - Controller initialization and data loading
/// - Search functionality and filtering
/// - UI state management based on loading and filtered states
/// - Navigation event handling
class _menuEventosPageState extends State<menuEventosPage> {
  /// Controller responsible for fetching and managing events data
  final menuEventosController _controller = menuEventosController();

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads events data when the widget is initialized
  ///
  /// This method is called automatically when the state is created.
  /// It triggers the controller to fetch events data and updates the UI.
  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  /// Filters the events list based on the search query
  ///
  /// This method is called when the search text changes and updates
  /// the filtered events list in the controller.
  ///
  /// [query]: The search string to filter events by
  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query, _controller.events);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      /// Custom navigation bar with title and add button
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
        previousPageTitle: 'Inventário',
        onAddPressed: () => _controller.navigateToAdd(context),
      ),
      child: Column(
        children: [
          /// Search bar for filtering events
          EventSearchBar(
            controller: _searchController,
            onChanged: _filterItems,
          ),

          /// Scrollable list of events with loading and empty states
          EventsListView(
            controller: _controller,
            searchController: _searchController,
          ),
        ],
      ),
    );
  }
}
