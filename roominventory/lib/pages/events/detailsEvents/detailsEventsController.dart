import 'package:flutter/cupertino.dart';
import 'package:roominventory/services/supabase_service.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsUI.dart';
import 'package:roominventory/pages/events/editEvents/editEventsUI.dart';

class detailsEventsController {
  dynamic event;
  List items = [];
  bool isLoading = true;
  String errorMessage = '';

  Future fetchData(String eventId) async {
    try {
      isLoading = true;
      items.clear();
      errorMessage = '';

      final eventDetails = await SupabaseService.getEventDetails(eventId);

      if (eventDetails != null) {
        event = eventDetails;

        final rawItems = eventDetails['items'] as List<dynamic>? ?? [];

        Map<String, Map<String, dynamic>> groupedItems = {};

        for (var row in rawItems) {
          String idItem = row['IdItem'] ?? row['iditem'] ?? '';

          if (!groupedItems.containsKey(idItem)) {
            groupedItems[idItem] = {
              'IdItem': idItem,
              'ItemName': row['ItemName'] ?? row['itemname'] ?? '',
              'ZoneName': row['ZoneName'] ?? row['zonename'] ?? '',
              'PlaceName': row['PlaceName'] ?? row['placename'] ?? '',
              'DetailsList': [],
            };
          }
        }

        items = groupedItems.values.toList();
      } else {
        errorMessage = 'Event not found';
        event = null;
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
      event = null;
      items = [];
    } finally {
      isLoading = false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      // 1. Primeiro apagar todos os item_event associados (FK constraint)
      final itemEvents = await SupabaseService.getItemEvents(eventId);
      for (var ie in itemEvents) {
        await SupabaseService.removeItemFromEvent(ie['idie']);
      }

      // 2. Depois apagar o evento
      await SupabaseService.deleteEvent(eventId);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete event: $e';
      return false;
    }
  }

  Future<bool> deleteItem(String itemId, String eventId) async {
    try {
      final itemEvents = await SupabaseService.getItemEvents(eventId);
      final match = itemEvents.firstWhere(
        (ie) => (ie['fk_iditem'] ?? ie['FK_IdItem'] ?? '') == itemId,
        orElse: () => null,
      );

      if (match != null) {
        await SupabaseService.removeItemFromEvent(match['idie']);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = 'Connection error: $e';
      return false;
    }
  }

  void navigateToAddItems(BuildContext context, String eventId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => addItemEventsPage(eventId: eventId),
      ),
    ).then((_) {
      fetchData(eventId);
    });
  }

  void navigateToEditEvents(BuildContext context, dynamic event) {
    if (event == null) return;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => editEventsPage(event: event),
      ),
    ).then((_) {
      fetchData(event['idevent'] ?? event['IdEvent'] ?? '');
    });
  }
}
