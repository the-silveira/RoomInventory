import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsUI.dart';
import 'package:roominventory/pages/events/editEvents/editEventsUI.dart';

/// Controller class for managing event details and associated items.
///
/// This controller handles fetching event information, managing related items,
/// performing deletion operations, and navigation to related pages.
/// It serves as the business logic layer for event detail views.
///
/// Example usage:
/// ```dart
/// final controller = detailsEventsController();
/// await controller.fetchData('VCCS_1');
/// ```
class detailsEventsController {
  /// The event data being displayed and managed
  dynamic event;

  /// List of items associated with the current event
  List<dynamic> items = [];

  /// Loading state indicator - true when data is being fetched
  bool isLoading = true;

  /// Error message for displaying operation failures
  String errorMessage = '';

  /// Fetches event details and associated items from the API.
  ///
  /// This method performs two main operations:
  /// 1. Fetches the specific event details by ID using GET /events/{eventId}
  /// 2. Fetches all items associated with that event using GET /events/{eventId}/items
  /// 3. Processes and groups item details into a structured format
  ///
  /// The method handles various API response scenarios including:
  /// - Successful data retrieval
  /// - Event not found errors
  /// - API error responses
  /// - Network failures
  ///
  /// Throws exceptions for network errors and invalid responses.
  ///
  /// [eventId]: The unique identifier of the event to fetch
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchData('VCCS_1');
  /// ```
  Future<void> fetchData(String eventId) async {
    try {
      isLoading = true;
      items.clear();
      errorMessage = '';

      // Fetch single event details using GET
      var eventResponse = await http.get(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (eventResponse.statusCode == 200) {
        event = json.decode(eventResponse.body);
      } else if (eventResponse.statusCode == 404) {
        errorMessage = 'Event not found';
        event = null;
      } else {
        errorMessage =
            'Failed to load event details (${eventResponse.statusCode})';
        event = null;
      }

      // If event exists, fetch its items
      if (event != null) {
        var itemsResponse = await http.get(
          Uri.parse(
              'https://services.interagit.com/API/roominventory/events/$eventId/items'),
          headers: {'Content-Type': 'application/json'},
        );

        if (itemsResponse.statusCode == 200) {
          List<dynamic> rawItems = json.decode(itemsResponse.body);

          // Group the details by IdItem (same logic as before)
          Map<String, Map<String, dynamic>> groupedItems = {};

          for (var row in rawItems) {
            String idItem = row['IdItem'];
            String detailsName = row['DetailsName'];
            String detailValue = row['Details'];

            if (!groupedItems.containsKey(idItem)) {
              groupedItems[idItem] = {
                'IdItem': idItem,
                'ItemName': row['ItemName'],
                'ZoneName': row['ZoneName'],
                'PlaceName': row['PlaceName'],
                'DetailsList': [],
              };
            }

            // Add details to the item
            groupedItems[idItem]!['DetailsList'].add({
              'DetailsName': detailsName,
              'Details': detailValue,
            });
          }

          items = groupedItems.values.toList();
        } else if (itemsResponse.statusCode == 404) {
          // No items found for this event
          items = [];
        } else {
          errorMessage =
              'Failed to load item details (${itemsResponse.statusCode})';
        }
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
      event = null;
      items = [];
    } finally {
      isLoading = false;
    }
  }

  /// Deletes an event from the system.
  ///
  /// Sends a DELETE request to the API to permanently delete the specified event.
  /// Returns true if the deletion was successful, false otherwise.
  ///
  /// [eventId]: The unique identifier of the event to delete
  /// Returns: [bool] indicating success (true) or failure (false)
  ///
  /// Example:
  /// ```dart
  /// bool success = await controller.deleteEvent('VCCS_1');
  /// if (success) {
  ///   // Event deleted successfully
  /// }
  /// ```
  Future<bool> deleteEvent(String eventId) async {
    try {
      var response = await http.delete(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        // Try to parse error message
        try {
          var errorResponse = json.decode(response.body);
          errorMessage = errorResponse['error'] ?? 'Failed to delete event';
        } catch (_) {
          errorMessage = 'Failed to delete event (${response.statusCode})';
        }
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
      return false;
    }
  }

  /// Removes an item from the current event.
  ///
  /// This operation disassociates an item from the event but does not
  /// delete the item itself from the system.
  ///
  /// [itemId]: The unique identifier of the item to remove
  /// [eventId]: The unique identifier of the event from which to remove the item
  /// Returns: [bool] indicating success (true) or failure (false)
  ///
  /// Example:
  /// ```dart
  /// bool success = await controller.deleteItem('XLR3_01', 'VCCS_1');
  /// ```
  Future<bool> deleteItem(String itemId, String eventId) async {
    try {
      var response = await http.delete(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/events/$eventId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Try to parse error message
        try {
          var errorResponse = json.decode(response.body);
          errorMessage = errorResponse['error'] ?? 'Failed to remove item';
        } catch (_) {
          errorMessage = 'Failed to remove item (${response.statusCode})';
        }
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
      return false;
    }
  }

  /// Navigates to the add items page for the current event.
  ///
  /// Opens a new screen where users can search for and add items to the event.
  ///
  /// [context]: The BuildContext for navigation
  /// [eventId]: The unique identifier of the event to add items to
  ///
  /// Example:
  /// ```dart
  /// controller.navigateToAddItems(context, 'VCCS_1');
  /// ```
  void navigateToAddItems(BuildContext context, String eventId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => addItemEventsPage(eventId: eventId),
      ),
    ).then((_) {
      // Refresh data when returning
      fetchData(eventId);
    });
  }

  /// Navigates to the edit event page.
  ///
  /// Opens a new screen where users can modify the event details.
  ///
  /// [context]: The BuildContext for navigation
  /// [event]: The event data to edit
  ///
  /// Example:
  /// ```dart
  /// controller.navigateToEditEvents(context, eventData);
  /// ```
  void navigateToEditEvents(BuildContext context, dynamic event) {
    if (event == null) return;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => editEventsPage(event: event),
      ),
    ).then((_) {
      // Refresh data when returning
      fetchData(event['IdEvent']);
    });
  }
}
