import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchBar({
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
        placeholder: 'Search places, zones, or items...',
      ),
    );
  }
}

class PlaceSection extends StatelessWidget {
  final dynamic place;

  const PlaceSection({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
      header: Text(
        place['PlaceName'] ?? 'Unknown Place',
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        ...place['Zones'].entries.map((zoneEntry) {
          var zone = zoneEntry.value;
          return ZoneSection(zone: zone);
        }).toList(),
      ],
    );
  }
}

class ZoneSection extends StatelessWidget {
  final dynamic zone;

  const ZoneSection({Key? key, required this.zone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        zone['ZoneName'] ?? 'Unknown Zone',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        ...zone['Items'].entries.map((itemEntry) {
          var item = itemEntry.value;
          return ItemListTile(item: item);
        }).toList(),
      ],
    );
  }
}

class ItemListTile extends StatelessWidget {
  final dynamic item;

  const ItemListTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(
        item['ItemName'] ?? 'Unknown Item',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        "ID: ${item['IdItem']}",
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Icon(CupertinoIcons.chevron_forward),
      onTap: () => _showItemDetails(context, item),
    );
  }

  void _showItemDetails(BuildContext context, dynamic item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          item['ItemName'] ?? 'Unknown Item',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        message: Text(
          "ID: ${item['IdItem']}\n\nDetails:",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          ...item['Details'].map((detail) {
            return CupertinoActionSheetAction(
              child: Text(
                "${detail['DetailsName']}: ${detail['Details']}",
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () => Navigator.pop(context),
            );
          }).toList(),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text(
        "Não tem Locais Registados",
        style: TextStyle(
          fontSize: 16,
          color: CupertinoTheme.of(context).textTheme.textStyle.color,
        ),
      ),
    ));
  }
}

class AddOptionsSheet extends StatelessWidget {
  final Function() onAddPlace;
  final Function() onAddZone;

  const AddOptionsSheet({
    Key? key,
    required this.onAddPlace,
    required this.onAddZone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Add New'),
      message: Text('What would you like to add?'),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Add Place'),
          onPressed: onAddPlace,
        ),
        CupertinoActionSheetAction(
          child: Text('Add Zone'),
          onPressed: onAddZone,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
