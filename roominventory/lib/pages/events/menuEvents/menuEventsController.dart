import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsUI.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsUI.dart';
import 'package:roominventory/services/supabase_service.dart';

class menuEventosController {
  dynamic events = [];
  dynamic filteredEvents = [];
  bool isLoading = true;
  String errorMessage = '';

  Future fetchData() async {
    try {
      isLoading = true;
      errorMessage = '';

      events = await SupabaseService.getEvents();
      filteredEvents = events;
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  void filterItems(String query, dynamic events) {
    if (events == null) return;
    filteredEvents = events.where((item) {
      return item['idevent'].toLowerCase().contains(query.toLowerCase()) ||
          item['eventname'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

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
      return CupertinoIcons.checkmark_alt;
    }
  }

  Future refreshData() async {
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
