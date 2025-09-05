import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:roominventory/pages/items/items/itemsController.dart';

/// A search bar widget for filtering items in the inventory.
///
/// This widget provides a Cupertino-style search text field that allows users
/// to search through the list of items. It includes a clear button and search icon.
///
/// Example:
/// ```dart
/// ItemSearchBar(
///   controller: _searchController,
///   onChanged: (value) => _filterItems(value),
/// )
/// ```
class ItemSearchBar extends StatelessWidget {
  /// The controller for the search text field.
  final TextEditingController controller;

  /// Callback function called when the search text changes.
  ///
  /// The function receives the current search text as a parameter.
  final Function(String) onChanged;

  /// Creates a search bar for item filtering.
  ///
  /// Requires a [controller] to manage the text input and an [onChanged]
  /// callback to handle search text changes.
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

/// A scrollable list view that displays filtered items from an [ItemsController].
///
/// This widget handles different states including loading, empty results,
/// and displaying the filtered items. It uses a [SliverList] for efficient
/// scrolling within a CustomScrollView.
///
/// Example:
/// ```dart
/// ItemsListView(
///   controller: _itemsController,
///   onItemTap: (item) => _navigateToItemDetails(item),
///   onShowQRCode: (id, name) => _showQRCode(id, name),
///   onDeleteItem: (id, context) => _deleteItem(id, context),
/// )
/// ```
class ItemsListView extends StatelessWidget {
  /// The controller that manages the items data and filtering.
  final ItemsController controller;

  /// Callback function when an item is tapped.
  ///
  /// Receives the tapped item data as a parameter.
  final Function(dynamic) onItemTap;

  /// Callback function to show QR code for an item.
  ///
  /// Receives the item ID and name as parameters.
  final Function(String, String) onShowQRCode;

  /// Callback function to delete an item.
  ///
  /// Receives the item ID and build context as parameters.
  final Function(String, BuildContext) onDeleteItem;

  /// Creates a list view for displaying filtered items.
  ///
  /// Requires an [ItemsController] for data management and callback functions
  /// for item interactions.
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

/// A list tile widget that displays individual item information.
///
/// This widget shows the item name and ID in a Cupertino-style list tile
/// with a chevron indicator. It handles tap events and provides a visual
/// representation of an inventory item.
///
/// Example:
/// ```dart
/// ItemListTile(
///   item: itemData,
///   onTap: () => _handleItemTap(),
///   onShowQRCode: () => _showQRCode(),
///   onDeleteItem: () => _deleteItem(),
/// )
/// ```
class ItemListTile extends StatelessWidget {
  /// The item data to display.
  ///
  /// Expected to contain 'ItemName' and 'IdItem' keys.
  final dynamic item;

  /// Callback function when the tile is tapped.
  final Function() onTap;

  /// Callback function to show the QR code for this item.
  final Function() onShowQRCode;

  /// Callback function to delete this item.
  final Function() onDeleteItem;

  /// Creates a list tile for an individual item.
  ///
  /// Requires the item data and callback functions for user interactions.
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

/// An action sheet that displays detailed information about an item and actions.
///
/// This widget shows an item's name, ID, and additional details in a
/// Cupertino-style action sheet. It provides actions for showing QR code,
/// viewing details, and deleting the item.
///
/// Example:
/// ```dart
/// ItemActionSheet(
///   item: selectedItem,
///   onShowQRCode: () => _showQRCode(),
///   onDeleteItem: () => _deleteItem(),
/// )
/// ```
class ItemActionSheet extends StatelessWidget {
  /// The item data to display in the action sheet.
  ///
  /// Expected to contain 'ItemName', 'IdItem', and 'DetailsList' keys.
  final dynamic item;

  /// Callback function to show the QR code for this item.
  final Function() onShowQRCode;

  /// Callback function to delete this item.
  final Function() onDeleteItem;

  /// Creates an action sheet for item details and actions.
  ///
  /// Requires the item data and callback functions for actions.
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

/// A dialog that displays a QR code for an item with download functionality.
///
/// This widget shows a QR code generated from the item ID along with the
/// item name and provides options to download the QR code or close the dialog.
///
/// Example:
/// ```dart
/// QRCodeDialog(
///   itemId: '123',
///   itemName: 'Sample Item',
///   onDownloadQRCode: () => _downloadQRCode(),
/// )
/// ```
class QRCodeDialog extends StatelessWidget {
  /// The unique identifier of the item used to generate the QR code.
  final String itemId;

  /// The name of the item displayed in the dialog title.
  final String itemName;

  /// Callback function to handle QR code download.
  final Function() onDownloadQRCode;

  /// Creates a dialog for displaying and downloading item QR codes.
  ///
  /// Requires the item ID, name, and a download callback function.
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

  /// Builds the QR code visualization with the given item ID.
  ///
  /// Returns a container with the QR image and item ID text below it.
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

/// A confirmation dialog for delete operations.
///
/// This Cupertino-style alert dialog asks the user to confirm a delete action
/// with "Yes" and "No" options.
///
/// Example:
/// ```dart
/// DeleteConfirmationDialog(
///   message: 'Are you sure you want to delete this item?',
///   onConfirm: () => _confirmDelete(),
///   onCancel: () => _cancelDelete(),
/// )
/// ```
class DeleteConfirmationDialog extends StatelessWidget {
  /// The confirmation message to display to the user.
  final String message;

  /// Callback function when the user confirms the deletion.
  final Function() onConfirm;

  /// Callback function when the user cancels the deletion.
  final Function() onCancel;

  /// Creates a confirmation dialog for delete operations.
  ///
  /// Requires a confirmation message and callback functions for both outcomes.
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

/// A simple message dialog for displaying information to the user.
///
/// This Cupertino-style alert dialog shows a title and message with an OK button.
///
/// Example:
/// ```dart
/// MessageDialog(
///   title: 'Success',
///   message: 'Item deleted successfully',
///   onOk: () => _closeDialog(),
/// )
/// ```
class MessageDialog extends StatelessWidget {
  /// The title of the message dialog.
  final String title;

  /// The main message content of the dialog.
  final String message;

  /// Callback function when the OK button is pressed.
  final Function() onOk;

  /// Creates a message dialog for displaying information.
  ///
  /// Requires a title, message, and OK callback function.
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
