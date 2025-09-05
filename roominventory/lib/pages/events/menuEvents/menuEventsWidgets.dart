import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/events/menuEvents/menuEventsController.dart';

/// A search bar widget specifically designed for filtering events.
///
/// This widget provides a Cupertino-style search text field that allows users
/// to search/filter events by their ID or name. It integrates with a controller
/// to handle the search functionality.
///
/// Example usage:
/// ```dart
/// EventSearchBar(
///   controller: _searchController,
///   onChanged: _filterEvents,
/// )
/// ```
class EventSearchBar extends StatelessWidget {
  /// Controller for managing the search text field content
  final TextEditingController controller;

  /// Callback function triggered when the search text changes
  final Function(String) onChanged;

  /// Creates an event search bar widget
  ///
  /// [controller]: The controller for the search text field
  /// [onChanged]: Callback for search text changes
  const EventSearchBar({
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
        placeholder: 'Search events...',
      ),
    );
  }
}

/// A list tile widget that displays detailed information about a single event.
///
/// This widget shows comprehensive event information in a visually organized
/// format, including:
/// - Event name (with truncation for long names)
/// - Status icon based on event date
/// - Event location
/// - Representative information
/// - Technical details
/// - Event date
/// - Event ID
///
/// The tile is tappable and navigates to the event details page.
///
/// Example usage:
/// ```dart
/// EventListTile(
///   event: eventData,
///   controller: _controller,
///   context: context,
/// )
/// ```
class EventListTile extends StatelessWidget {
  /// The event data to display, expected to contain:
  /// - EventName
  /// - EventPlace
  /// - NameRep
  /// - EmailRep
  /// - TecExt
  /// - Date
  /// - IdEvent
  final dynamic event;

  /// Controller for handling event operations and status determination
  final menuEventosController controller;

  /// The build context for navigation operations
  final BuildContext context;

  /// Creates an event list tile widget
  ///
  /// [event]: The event data to display
  /// [controller]: Controller for event operations and status icons
  /// [context]: Build context for navigation
  const EventListTile({
    Key? key,
    required this.event,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile.notched(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  event['EventName'].toString().isEmpty
                      ? 'Empty Name'
                      : event['EventName'].toString().length > 35
                          ? event['EventName'].toString().substring(0, 35) +
                              "..."
                          : event['EventName'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                controller.getCardIcon(event['Date']),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📍 ${event['EventPlace']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "👤 ${event['NameRep']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "📧 ${event['EmailRep']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "🛠 ${event['TecExt']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "📅 Date: ${event['Date']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "ID: ${event['IdEvent']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => controller.navigateToDetails(context, event['IdEvent']),
        ),
      ],
    );
  }
}

/// A scrollable list view widget that displays events with various states.
///
/// This widget handles multiple display states:
/// - Loading state (shows activity indicator)
/// - Error state (shows error message)
/// - Empty state (shows "no events" message)
/// - Populated state (shows list of filtered events)
///
/// Includes pull-to-refresh functionality and integrates with the search
/// controller to display filtered results.
///
/// Example usage:
/// ```dart
/// EventsListView(
///   controller: _controller,
///   searchController: _searchController,
/// )
/// ```
class EventsListView extends StatelessWidget {
  /// Controller for managing events data and operations
  final menuEventosController controller;

  /// Controller for the search functionality
  final TextEditingController searchController;

  /// Creates an events list view widget
  ///
  /// [controller]: Controller for events data and operations
  /// [searchController]: Controller for search functionality
  const EventsListView({
    Key? key,
    required this.controller,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Loading state - show activity indicator
    if (controller.isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    // Error state - show error message
    if (controller.errorMessage.isNotEmpty) {
      return Center(child: Text(controller.errorMessage));
    }

    // Empty state - show "no events" message
    if (controller.filteredEvents.isEmpty) {
      return Center(
        child: Text(
          "Não tem Eventos Registados",
          style: TextStyle(
            fontSize: 16,
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
        ),
      );
    }

    // Populated state - show list of filtered events with pull-to-refresh
    return Expanded(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: controller.refreshData,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var event = controller.filteredEvents[index];
                return EventListTile(
                  event: event,
                  controller: controller,
                  context: context,
                );
              },
              childCount: controller.filteredEvents.length,
            ),
          ),
        ],
      ),
    );
  }
}
