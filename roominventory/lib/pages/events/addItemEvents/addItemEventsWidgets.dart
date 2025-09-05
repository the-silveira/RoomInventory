import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsController.dart';

/// A custom search bar widget with integrated QR code scanning functionality.
///
/// This widget combines a Cupertino-style search text field with a QR code
/// scanner button, providing both text-based and visual search capabilities.
///
/// Example usage:
/// ```dart
/// SearchBarWithQR(
///   searchController: _searchController,
///   onSearchChanged: (query) => _filterItems(query),
///   onQRScanPressed: _scanQRCode,
/// )
/// ```
class SearchBarWithQR extends StatelessWidget {
  /// Controller for managing the search text field's content
  final TextEditingController searchController;

  /// Callback function triggered when the search text changes
  final Function(String) onSearchChanged;

  /// Callback function triggered when the QR scan button is pressed
  final Function() onQRScanPressed;

  /// Creates a search bar with QR scanning capability
  ///
  /// [searchController]: The controller for the search text field
  /// [onSearchChanged]: Callback for search text changes
  /// [onQRScanPressed]: Callback for QR scan button press
  const SearchBarWithQR({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onQRScanPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: searchController,
            onChanged: onSearchChanged,
            placeholder: 'Search items...',
          ),
        ),
        SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.all(12),
          onPressed: onQRScanPressed,
          child: Icon(CupertinoIcons.qrcode_viewfinder, size: 24),
        ),
      ],
    );
  }
}

/// A list view widget that displays inventory items with selection capability.
///
/// This widget shows a scrollable list of items with checkboxes for selection.
/// It handles loading states and empty states automatically.
///
/// Example usage:
/// ```dart
/// ItemsListView(
///   controller: _controller,
///   onItemSelectionChanged: (item) => _toggleItemSelection(item),
/// )
/// ```
class ItemsListView extends StatelessWidget {
  /// The controller that manages the items data and selection state
  final addItemEventsController controller;

  /// Callback function triggered when an item's selection state changes
  final Function(dynamic) onItemSelectionChanged;

  /// Creates a list view for displaying selectable items
  ///
  /// [controller]: The controller providing items data and selection state
  /// [onItemSelectionChanged]: Callback for item selection changes
  const ItemsListView({
    Key? key,
    required this.controller,
    required this.onItemSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    if (controller.filteredItems.isEmpty) {
      return Center(
        child: Text(
          'No items available',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.filteredItems.length,
      itemBuilder: (context, index) {
        var item = controller.filteredItems[index];
        return ItemListTile(
          item: item,
          isSelected: controller.selectedItems.contains(item),
          onSelectionChanged: () => onItemSelectionChanged(item),
        );
      },
    );
  }
}

/// A custom list tile widget for displaying individual inventory items.
///
/// This widget shows item information with a checkbox for selection and
/// follows Cupertino design principles for iOS-style appearance.
///
/// Example usage:
/// ```dart
/// ItemListTile(
///   item: itemData,
///   isSelected: true,
///   onSelectionChanged: () => _selectItem(itemData),
/// )
/// ```
class ItemListTile extends StatelessWidget {
  /// The item data to display, expected to contain 'ItemName' and 'IdItem' keys
  final dynamic item;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Callback function triggered when the selection checkbox is toggled
  final Function() onSelectionChanged;

  /// Creates a list tile for an individual inventory item
  ///
  /// [item]: The item data to display (should be a Map with ItemName and IdItem)
  /// [isSelected]: Whether the item is currently selected
  /// [onSelectionChanged]: Callback for selection changes
  const ItemListTile({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(
        item['ItemName'] ?? 'Unknown Item',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        "ID: ${item['IdItem']}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: CupertinoCheckbox(
        value: isSelected,
        onChanged: (value) => onSelectionChanged(),
      ),
    );
  }
}

/// A full-screen QR code scanner view with instructions and close functionality.
///
/// This widget provides a dedicated screen for scanning QR codes using the
/// device's camera with visual guidance for users.
///
/// Example usage:
/// ```dart
/// QRScannerView(
///   onQRViewCreated: (controller) => _handleQRController(controller),
///   onClosePressed: () => Navigator.pop(context),
/// )
/// ```
class QRScannerView extends StatelessWidget {
  /// Callback function triggered when the QR view is created
  final Function(QRViewController) onQRViewCreated;

  /// Callback function triggered when the close button is pressed
  final Function() onClosePressed;

  /// Creates a QR scanner view
  ///
  /// [onQRViewCreated]: Callback for when the QR view controller is ready
  /// [onClosePressed]: Callback for when the user wants to close the scanner
  const QRScannerView({
    Key? key,
    required this.onQRViewCreated,
    required this.onClosePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: GlobalKey(debugLabel: 'QR'),
                onQRViewCreated: onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Position the QR code inside the frame',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying error messages with consistent styling.
///
/// This widget automatically hides itself when the message is empty and
/// displays error messages in a standardized red color scheme.
///
/// Example usage:
/// ```dart
/// ErrorMessage(message: 'An error occurred while loading items')
/// ```
class ErrorMessage extends StatelessWidget {
  /// The error message text to display
  final String message;

  /// Creates an error message widget
  ///
  /// [message]: The error text to display (widget hides itself if empty)
  const ErrorMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        style: TextStyle(
          color: CupertinoColors.destructiveRed,
          fontSize: 14,
        ),
      ),
    );
  }
}
