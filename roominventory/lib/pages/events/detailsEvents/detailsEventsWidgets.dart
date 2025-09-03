import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsController.dart';

class EventHeader extends StatelessWidget {
  final dynamic event;

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

class ItemsList extends StatelessWidget {
  final List<dynamic> items;
  final detailsEventsController controller;
  final String eventId;
  final Function() onDataRefresh;

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

class ItemListTile extends StatelessWidget {
  final dynamic item;
  final detailsEventsController controller;
  final String eventId;
  final Function() onDataRefresh;

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

class EventActions extends StatelessWidget {
  final detailsEventsController controller;
  final dynamic event;
  final Function() onDeleteSuccess;

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
