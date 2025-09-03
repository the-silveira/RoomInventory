import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:roominventory/items/items/itemsController.dart';

class ItemSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const ItemSearchBar({
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
        placeholder: 'Search items...',
      ),
    );
  }
}

class ItemsListView extends StatelessWidget {
  final ItemsController controller;
  final Function(dynamic) onItemTap;
  final Function(String, String) onShowQRCode;
  final Function(String, BuildContext) onDeleteItem;

  const ItemsListView({
    Key? key,
    required this.controller,
    required this.onItemTap,
    required this.onShowQRCode,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (controller.filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "Não tem Itens Registados",
            style: TextStyle(
              fontSize: 16,
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var item = controller.filteredItems[index];
          return ItemListTile(
            item: item,
            onTap: () => onItemTap(item),
            onShowQRCode: () => onShowQRCode(item['IdItem'], item['ItemName']),
            onDeleteItem: () => onDeleteItem(item['IdItem'], context),
          );
        },
        childCount: controller.filteredItems.length,
      ),
    );
  }
}

class ItemListTile extends StatelessWidget {
  final dynamic item;
  final Function() onTap;
  final Function() onShowQRCode;
  final Function() onDeleteItem;

  const ItemListTile({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onShowQRCode,
    required this.onDeleteItem,
  }) : super(key: key);

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
      onTap: onTap,
    );
  }
}

class ItemActionSheet extends StatelessWidget {
  final dynamic item;
  final Function() onShowQRCode;
  final Function() onDeleteItem;

  const ItemActionSheet({
    Key? key,
    required this.item,
    required this.onShowQRCode,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
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
        CupertinoActionSheetAction(
          child: Text(
            "Show QR Code",
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontSize: 14,
            ),
          ),
          onPressed: onShowQRCode,
        ),
        ...item['DetailsList'].map<CupertinoActionSheetAction>((detail) {
          return CupertinoActionSheetAction(
            child: Text(
              "${detail['DetailsName']}: ${detail['Details']}",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }).toList(),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text("Eliminar"),
          onPressed: onDeleteItem,
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Close'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class QRCodeDialog extends StatelessWidget {
  final String itemId;
  final String itemName;
  final Function() onDownloadQRCode;

  const QRCodeDialog({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.onDownloadQRCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code - $itemName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CupertinoColors.label,
                ),
              ),
              SizedBox(height: 16),
              _buildQRCode(itemId),
              SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: onDownloadQRCode,
                child: Text('Download QR Code'),
              ),
              SizedBox(height: 8),
              CupertinoButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode(String itemId) {
    return Container(
      width: 220,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey3),
        borderRadius: BorderRadius.circular(8),
        color: CupertinoColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: QrImageView(
              data: itemId,
              version: QrVersions.auto,
              size: 200.0,
              gapless: false,
              backgroundColor: CupertinoColors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: CupertinoColors.black,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: CupertinoColors.black,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ID: $itemId',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String message;
  final Function() onConfirm;
  final Function() onCancel;

  const DeleteConfirmationDialog({
    Key? key,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(message),
      actions: [
        CupertinoDialogAction(
          child: Text('Não'),
          onPressed: onCancel,
        ),
        CupertinoDialogAction(
          child: Text('Sim'),
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final Function() onOk;

  const MessageDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: onOk,
        ),
      ],
    );
  }
}
