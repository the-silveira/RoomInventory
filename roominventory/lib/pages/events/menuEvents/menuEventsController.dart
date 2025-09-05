import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsUI.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsUI.dart';

/// Controller class for managing the events menu and event operations.
///
/// This controller handles:
/// - Fetching events data from the API
/// - Filtering and searching events
/// - Determining event status icons based on dates
/// - Navigation to event creation and details pages
/// - Data refresh operations
///
/// The controller serves as the business logic layer for the events menu,
/// managing event data and providing methods for UI interactions.
///
/// Example usage:
/// ```dart
/// final controller = menuEventosController();
/// await controller.fetchData();
/// ```
class menuEventosController {
  /// List of all events fetched from the API
  dynamic events = [];

  /// List of events filtered by search queries
  dynamic filteredEvents = [];

  /// Loading state indicator - true when data is being fetched
  bool isLoading = true;

  /// Error message for displaying operation failures
  String errorMessage = '';

  /// Fetches events data from the API and initializes both events lists.
  ///
  /// This method:
  /// 1. Sends a POST request to the events API endpoint
  /// 2. Parses the JSON response into events list
  /// 3. Initializes filteredEvents with all events
  /// 4. Handles HTTP errors and exceptions
  /// 5. Updates loading state upon completion
  ///
  /// Throws exceptions for network errors and invalid responses.
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchData();
  /// ```
  Future<void> fetchData() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (response.statusCode == 200) {
        events = json.decode(response.body);
        filteredEvents = events; // Initialize filtered list with all events
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        errorMessage = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  /// Filters events based on a search query.
  ///
  /// This method filters the events list by matching the query against:
  /// - Event ID (IdEvent)
  /// - Event name (EventName)
  ///
  /// The search is case-insensitive and updates the filteredEvents list.
  ///
  /// [query]: The search string to filter events by
  /// [events]: The list of events to filter (typically the main events list)
  ///
  /// Example:
  /// ```dart
  /// controller.filterItems('conference', eventsList);
  /// ```
  void filterItems(String query, dynamic events) {
    if (events == null) return;

    filteredEvents = events.where((item) {
      return item['IdEvent'].toLowerCase().contains(query.toLowerCase()) ||
          item['EventName'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Determines the appropriate icon for an event card based on its date.
  ///
  /// This method compares the event date with the current date to determine
  /// the event status and returns the corresponding icon:
  /// - Past events: CupertinoIcons.checkmark_alt (completed)
  /// - Today's events: CupertinoIcons.exclamationmark_octagon (current/urgent)
  /// - Future events: CupertinoIcons.add (upcoming)
  ///
  /// [eventDate]: The event date string in "yyyy-MM-dd" format
  /// Returns: [IconData] representing the event status
  ///
  /// Example:
  /// ```dart
  /// IconData icon = controller.getCardIcon('2024-01-15');
  /// ```
  IconData getCardIcon(String eventDate) {
    try {
      DateTime eventDateTime = DateFormat("yyyy-MM-dd").parse(eventDate);
      DateTime today = DateTime.now();
      DateTime todayOnly = DateTime(today.year, today.month, today.day);

      if (eventDateTime.isBefore(todayOnly)) {
        return CupertinoIcons.checkmark_alt;
      } else if (eventDateTime.isAtSameMomentAs(todayOnly)) {
        return CupertinoIcons.exclamationmark_octagon;
      } else {
        return CupertinoIcons.add;
      }
    } catch (e) {
      print("Date parsing error: $e");
      return CupertinoIcons.checkmark_alt;
    }
  }

  /// Refreshes the events data with a brief delay for visual feedback.
  ///
  /// This method:
  /// 1. Shows a brief delay (1000ms) for pull-to-refresh visual feedback
  /// 2. Sets loading state to true
  /// 3. Re-fetches data from the API
  ///
  /// Returns: [Future<void>] that completes when refresh is done
  ///
  /// Example:
  /// ```dart
  /// await controller.refreshData();
  /// ```
  Future<void> refreshData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    isLoading = true;
    await fetchData();
  }

  /// Navigates to the add event page and refreshes data upon return.
  ///
  /// Opens the event creation screen and automatically refreshes the events list
  /// when returning from that screen, ensuring new events are displayed.
  ///
  /// [context]: The BuildContext for navigation
  ///
  /// Example:
  /// ```dart
  /// controller.navigateToAdd(context);
  /// ```
  void navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddEventPage()),
    ).then((_) {
      refreshData();
    });
  }

  /// Navigates to the event details page and refreshes data upon return.
  ///
  /// Opens the event details screen for a specific event and automatically
  /// refreshes the events list when returning, ensuring any changes made
  /// in the details screen are reflected.
  ///
  /// [context]: The BuildContext for navigation
  /// [eventId]: The unique identifier of the event to view details for
  ///
  /// Example:
  /// ```dart
  /// controller.navigateToDetails(context, 'event123');
  /// ```
  void navigateToDetails(BuildContext context, String eventId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => detailsEventsPage(eventId: eventId),
      ),
    ).then((_) {
      refreshData();
    });
  }
}
