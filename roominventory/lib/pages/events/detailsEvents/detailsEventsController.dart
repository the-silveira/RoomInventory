import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:roominventory/pages/events/addItemEvents/addItemEventsUI.dart';
import 'package:roominventory/pages/events/editEvents/editEventsUI.dart';

class detailsEventsController {
  dynamic event;
  List<dynamic> items = [];
  bool isLoading = true;
  String errorMessage = '';

  // Fetch event and item details
  Future<void> fetchData(String eventId) async {
    try {
      items.clear();

      // Fetch event details
      var eventResponse = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (eventResponse.statusCode == 200) {
        List<dynamic> allEvents = json.decode(eventResponse.body);
        event = allEvents.firstWhere(
          (e) => e['IdEvent'] == eventId,
          orElse: () => null,
        );

        if (event == null) {
          errorMessage = 'Event not found';
        }
      } else {
        errorMessage = 'Failed to load event details';
      }

      // Fetch item details for this event
      var itemsResponse = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E2', 'IdEvent': eventId},
      );

      if (itemsResponse.statusCode == 200) {
        dynamic responseBody = json.decode(itemsResponse.body);

        if (responseBody is Map &&
            responseBody.containsKey('status') &&
            responseBody['status'] == 'error') {
          // Handle API error response
        } else {
          List<dynamic> rawItems = json.decode(itemsResponse.body);

          // Group the details by IdItem
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
        }
      } else {
        errorMessage = 'Failed to load item details';
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E5',
          'IdEvent': eventId,
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        return responseBody['status'] == 'success';
      }
      return false;
    } catch (e) {
      errorMessage = 'Exception: $e';
      return false;
    }
  }

  // Delete item from event
  Future<bool> deleteItem(String itemId, String eventId) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E6', 'IdItem': itemId, 'IdEvent': eventId},
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        return responseBody['status'] == 'success';
      }
      return false;
    } catch (e) {
      errorMessage = 'Exception: $e';
      return false;
    }
  }

  // Navigate to add items page
  void navigateToAddItems(BuildContext context, String eventId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => addItemEventsPage(eventId: eventId),
      ),
    );
  }

  // Navigate to edit event page
  void navigateToEditEvents(BuildContext context, dynamic event) {
    if (event == null) return;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => editEventsPage(event: event),
      ),
    );
  }
}
