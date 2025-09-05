import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsController.dart';

/// A widget that displays the header information for an event.
///
/// Shows key event details including:
/// - Event name
/// - Event location
/// - Representative information
/// - Technical external reference
/// - Event date
///
/// Example usage:
/// ```dart
/// EventHeader(event: eventData)
/// ```
class EventHeader extends StatelessWidget {
  /// The event data to display, expected to contain:
  /// - EventName
  /// - EventPlace
  /// - NameRep
  /// - EmailRep
  /// - TecExt
  /// - Date
  final dynamic event;

  /// Creates an event header widget
  ///
  /// [event]: The event data to display (should be a Map with event properties)
  const EventHeader({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event!['EventName'] ?? 'No Name',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          SizedBox(height: 8),
          Text(
            "📍 ${event!['EventPlace']}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            "👤 ${event!['NameRep']}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            "📧 ${event!['EmailRep']}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            "🛠 ${event!['TecExt']}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            "📅 Date: ${event!['Date']}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a list of items associated with an event.
///
/// Handles both empty states (showing a message when no items are present)
/// and populated states (showing a grouped list of items).
///
/// Example usage:
/// ```dart
/// ItemsList(
///   items: itemsList,
///   controller: _controller,
///   eventId: 'event123',
///   onDataRefresh: _refreshData,
/// )
/// ```
class ItemsList extends StatelessWidget {
  /// List of items to display
  final List<dynamic> items;

  /// Controller for handling item operations
  final detailsEventsController controller;

  /// The event ID associated with these items
  final String eventId;

  /// Callback function to refresh data after operations
  final Function() onDataRefresh;

  /// Creates an items list widget
  ///
  /// [items]: List of item data to display
  /// [controller]: Controller for item operations
  /// [eventId]: The event ID these items belong to
  /// [onDataRefresh]: Callback to refresh data after operations
  const ItemsList({
    Key? key,
    required this.items,
    required this.controller,
    required this.eventId,
    required this.onDataRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Não tem Itens Registados",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return CupertinoListSection.insetGrouped(
      header: Text(
        "Todos os Itens",
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ItemListTile(
              item: item,
              controller: controller,
              eventId: eventId,
              onDataRefresh: onDataRefresh,
            );
          },
        ),
      ],
    );
  }
}

/// A list tile widget that displays individual item information with interactive actions.
///
/// Each tile shows:
/// - Item name
/// - Item ID
/// - Chevron indicator for more actions
///
/// When tapped, shows a modal action sheet with:
/// - Item details
/// - Option to remove the item from the event
///
/// Example usage:
/// ```dart
/// ItemListTile(
///   item: itemData,
///   controller: _controller,
///   eventId: 'event123',
///   onDataRefresh: _refreshData,
/// )
/// ```
class ItemListTile extends StatelessWidget {
  /// The item data to display, expected to contain:
  /// - ItemName
  /// - IdItem
  /// - DetailsList (list of detail maps with DetailsName and Details)
  final dynamic item;

  /// Controller for handling item operations
  final detailsEventsController controller;

  /// The event ID this item belongs to
  final String eventId;

  /// Callback function to refresh data after operations
  final Function() onDataRefresh;

  /// Creates an item list tile widget
  ///
  /// [item]: The item data to display
  /// [controller]: Controller for item operations
  /// [eventId]: The event ID this item belongs to
  /// [onDataRefresh]: Callback to refresh data after operations
  const ItemListTile({
    Key? key,
    required this.item,
    required this.controller,
    required this.eventId,
    required this.onDataRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(
        item['ItemName'] ?? 'Unknown Item',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        "ID: ${item['IdItem']}",
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: CupertinoListTileChevron(),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text(
                item['ItemName'] ?? 'Unknown Item',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              message: Text(
                "ID: ${item['IdItem']}\n\nDetails:",
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).colorScheme.primary),
              ),
              actions: [
                ...item['DetailsList'].map<CupertinoActionSheetAction>(
                  (detail) {
                    return CupertinoActionSheetAction(
                      child: Text(
                        "${detail['DetailsName']}: ${detail['Details']}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                ).toList(),
                CupertinoActionSheetAction(
                  child: Text(
                    "Remover Item do Evento",
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteDialog(context, item['IdItem']);
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a confirmation dialog for deleting an item from the event
  ///
  /// [context]: The build context for showing the dialog
  /// [itemId]: The ID of the item to delete
  void _showDeleteDialog(BuildContext context, String itemId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Tem Mesmo a certeza que quer eliminar?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Não'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text('Sim'),
            onPressed: () async {
              Navigator.pop(context);
              bool success = await controller.deleteItem(itemId, eventId);
              if (success) {
                _showMessage(context, "Item Eliminado com Sucesso", 'success');
                onDataRefresh();
              } else {
                _showMessage(
                    context, "Erro ao Eliminar. Tente novamente", 'error');
              }
            },
          ),
        ],
      ),
    );
  }

  /// Shows a success or error message dialog
  ///
  /// [context]: The build context for showing the dialog
  /// [message]: The message to display
  /// [status]: Either 'success' or 'error' to determine the dialog title
  void _showMessage(BuildContext context, String message, String status) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(status == 'success' ? 'Sucesso' : 'Erro'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (status == 'success') {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// A widget that provides action buttons for event operations.
///
/// Includes buttons for:
/// - Editing the event
/// - Deleting the event
///
/// Example usage:
/// ```dart
/// EventActions(
///   controller: _controller,
///   event: eventData,
///   onDeleteSuccess: _handleDeleteSuccess,
/// )
/// ```
class EventActions extends StatelessWidget {
  /// Controller for handling event operations
  final detailsEventsController controller;

  /// The event data to perform operations on
  final dynamic event;

  /// Callback function triggered when event deletion is successful
  final Function() onDeleteSuccess;

  /// Creates an event actions widget
  ///
  /// [controller]: Controller for event operations
  /// [event]: The event data to operate on
  /// [onDeleteSuccess]: Callback for successful deletion
  const EventActions({
    Key? key,
    required this.controller,
    required this.event,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
      children: [
        CupertinoListTile.notched(
          title: Text(
            'Editar Evento',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onTap: () => controller.navigateToEditEvents(context, event),
        ),
        CupertinoListTile.notched(
          title: Text(
            'Eliminar Evento',
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
          onTap: () => _confirmDelete(context),
        ),
      ],
    );
  }

  /// Shows a confirmation dialog for deleting the entire event
  ///
  /// [context]: The build context for showing the dialog
  void _confirmDelete(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text(
              'Delete',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
            onPressed: () async {
              Navigator.pop(context);
              bool success = await controller.deleteEvent(event['IdEvent']);
              if (success) {
                onDeleteSuccess();
              } else {
                // Show error message
              }
            },
          ),
        ],
      ),
    );
  }
}
