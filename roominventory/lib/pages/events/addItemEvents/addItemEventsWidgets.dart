import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/events/addItemEvents/addItemEventsController.dart';

class SearchBarWithQR extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function() onQRScanPressed;

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

class ItemsListView extends StatelessWidget {
  final addItemEventsController controller;
  final Function(dynamic) onItemSelectionChanged;

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

class ItemListTile extends StatelessWidget {
  final dynamic item;
  final bool isSelected;
  final Function() onSelectionChanged;

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

class QRScannerView extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;
  final Function() onClosePressed;

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

class ErrorMessage extends StatelessWidget {
  final String message;

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
