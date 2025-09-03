import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/items/addItem/addItemUI.dart';

import 'package:roominventory/pages/items/items/itemsController.dart';
import 'package:roominventory/pages/items/items/itemsWidgets.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final ItemsController _controller = ItemsController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query, _controller.items ?? []);
    });
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddItemPage()),
    ).then((_) {
      _loadData();
    });
  }

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

  Future<void> _saveQRCode(String itemId, String itemName) async {
    try {
      await _controller.saveAndShareQRCode(itemId, itemName);
    } catch (e) {
      _showMessage('Error', 'Failed to share QR code: $e');
    }
  }

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

  void _deleteItem(String itemId) async {
    bool success = await _controller.deleteItem(itemId);
    if (success) {
      _showMessage('Sucesso', 'Item Eliminado com Sucesso', shouldPop: true);
      _loadData();
    } else {
      _showMessage('Erro', 'Erro ao Eliminar. Tente novamente');
    }
  }

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
                      CupertinoSliverRefreshControl(
                        onRefresh: () async => _loadData(),
                      ),
                      SliverToBoxAdapter(
                        child: ItemSearchBar(
                          controller: _searchController,
                          onChanged: _filterItems,
                        ),
                      ),
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
