import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:roominventory/events/addEvents.dart/addEventsUI.dart';
import 'package:roominventory/events/detailsEvents/detailsEventsUI.dart';

class menuEventosController {
  dynamic events = [];
  dynamic filteredEvents = [];
  bool isLoading = true;
  String errorMessage = '';

  // Function to fetch data from the API
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

  void filterItems(String query, dynamic events) {
    if (events == null) return;

    filteredEvents = events.where((item) {
      return item['IdEvent'].toLowerCase().contains(query.toLowerCase()) ||
          item['EventName'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Function to determine card icon based on event date
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

  Future<void> refreshData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    isLoading = true;
    await fetchData();
  }

  void navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddEventPage()),
    ).then((_) {
      refreshData();
    });
  }

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
