import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/items/addItem/addItemUI.dart';

import 'package:roominventory/pages/items/items/itemsController.dart';
import 'package:roominventory/pages/items/items/itemsWidgets.dart';

/// A page that displays a list of inventory items with management capabilities.
///
/// This page serves as the main inventory management interface where users can:
/// - View all inventory items in a list format
/// - Search/filter items by ID or name
/// - Navigate to add new items
/// - View item details via action sheets
/// - Generate and share QR codes for items
/// - Delete items from the inventory
/// - Refresh items data with pull-to-refresh
///
/// The page uses an [ItemsController] to manage data operations and
/// [itemsWidgets] for UI components.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => ItemsPage()),
/// );
/// ```
class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

/// The state class for [ItemsPage] that manages the items list UI and interactions.
///
/// This state class handles:
/// - Controller initialization and data loading
/// - Search functionality and filtering
/// - Navigation to add items page
/// - QR code generation and sharing
/// - Item deletion operations
/// - Action sheet management for item actions
/// - UI state management based on loading and filtered states
class _ItemsPageState extends State<ItemsPage> {
  /// Controller responsible for fetching and managing items data
  final ItemsController _controller = ItemsController();

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads items data when the widget is initialized
  ///
  /// This method is called automatically when the state is created.
  /// It triggers the controller to fetch items data and updates the UI.
  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  /// Filters the items list based on the search query
  ///
  /// This method is called when the search text changes and updates
  /// the filtered items list in the controller.
  ///
  /// [query]: The search string to filter items by
  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query, _controller.items ?? []);
    });
  }

  /// Navigates to the add item page and refreshes data upon return.
  ///
  /// Opens the item creation screen and automatically refreshes the items list
  /// when returning from that screen, ensuring new items are displayed.
  void _navigateToAdd() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddItemPage()),
    ).then((_) {
      _loadData();
    });
  }

  /// Shows a modal dialog displaying the QR code for an item.
  ///
  /// Displays a custom dialog that shows the QR code for the specified item
  /// with options to download or share the QR code.
  ///
  /// [itemId]: The unique identifier of the item
  /// [itemName]: The name of the item (for display purposes)
  void _showQRCodeDialog(String itemId, String itemName) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => QRCodeDialog(
        itemId: itemId,
        itemName: itemName,
        onDownloadQRCode: () => _saveQRCode(itemId, itemName),
      ),
    );
  }

  /// Generates and shares the QR code for an item.
  ///
  /// This method calls the controller to generate a QR code image
  /// and share it via the device's share sheet.
  ///
  /// [itemId]: The unique identifier of the item
  /// [itemName]: The name of the item (used in share text)
  Future<void> _saveQRCode(String itemId, String itemName) async {
    try {
      await _controller.saveAndShareQRCode(itemId, itemName);
    } catch (e) {
      _showMessage('Error', 'Failed to share QR code: $e');
    }
  }

  /// Shows a confirmation dialog for deleting an item.
  ///
  /// Displays a Cupertino-style alert dialog asking for confirmation
  /// before deleting an item from the inventory.
  ///
  /// [itemId]: The unique identifier of the item to delete
  /// [context]: The build context for showing the dialog
  void _showDeleteDialog(String itemId, BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        message: 'Tem Mesmo a certeza que quer eliminar?',
        onConfirm: () => _deleteItem(itemId),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// Deletes an item from the inventory.
  ///
  /// This method calls the controller to delete the specified item
  /// and handles the success/failure response with appropriate messages.
  ///
  /// [itemId]: The unique identifier of the item to delete
  void _deleteItem(String itemId) async {
    bool success = await _controller.deleteItem(itemId);
    if (success) {
      _showMessage('Sucesso', 'Item Eliminado com Sucesso', shouldPop: true);
      _loadData();
    } else {
      _showMessage('Erro', 'Erro ao Eliminar. Tente novamente');
    }
  }

  /// Shows a message dialog with custom title and message.
  ///
  /// Displays a Cupertino-style alert dialog that can optionally
  /// navigate back when dismissed.
  ///
  /// [title]: The title of the message dialog
  /// [message]: The message content to display
  /// [shouldPop]: Whether to navigate back after dismissing the dialog
  void _showMessage(String title, String message, {bool shouldPop = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        onOk: () {
          Navigator.pop(context);
          if (shouldPop) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// Shows an action sheet with available actions for an item.
  ///
  /// Displays a Cupertino-style action sheet with options to:
  /// - View QR code
  /// - Delete the item
  ///
  /// [item]: The item data to show actions for
  void _showItemActionSheet(dynamic item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ItemActionSheet(
        item: item,
        onShowQRCode: () {
          Navigator.pop(context);
          _showQRCodeDialog(item['IdItem'], item['ItemName']);
        },
        onDeleteItem: () {
          Navigator.pop(context);
          _showDeleteDialog(item['IdItem'], context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      /// Custom navigation bar with add functionality
      navigationBar: CustomNavigationBar(
        title: 'Itens',
        previousPageTitle: 'Inventário',
        onAddPressed: _navigateToAdd,
      ),
      child: _controller.isLoading
          ? Center(child: CupertinoActivityIndicator())
          : _controller.errorMessage.isNotEmpty
              ? Center(child: Text(_controller.errorMessage))
              : SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      /// Pull-to-refresh control
                      CupertinoSliverRefreshControl(
                        onRefresh: () async => _loadData(),
                      ),

                      /// Search bar section
                      SliverToBoxAdapter(
                        child: ItemSearchBar(
                          controller: _searchController,
                          onChanged: _filterItems,
                        ),
                      ),

                      /// Items list section
                      ItemsListView(
                        controller: _controller,
                        onItemTap: _showItemActionSheet,
                        onShowQRCode: _showQRCodeDialog,
                        onDeleteItem: _showDeleteDialog,
                      ),
                    ],
                  ),
                ),
    );
  }
}
