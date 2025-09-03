import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/appbar/appbar_back.dart';

class AssociateItemsPage extends StatefulWidget {
  final String eventId;

  AssociateItemsPage({required this.eventId});

  @override
  _AssociateItemsPageState createState() => _AssociateItemsPageState();
}

class _AssociateItemsPageState extends State<AssociateItemsPage> {
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  List<dynamic> selectedItems = [];
  bool isLoading = true;
  String errorMessage = '';
  Barcode? result;
  QRViewController? controller;
  TextEditingController searchController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _fetchAllItems();
  }

  // Fetch all available items from the API
  Future<void> _fetchAllItems() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I4', 'IdEvent': widget.eventId},
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          allItems = json.decode(response.body);
          filteredItems = allItems;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load items';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to filter items based on search query
  void _filterItems(String query) {
    setState(() {
      filteredItems = allItems.where((item) {
        return item['ItemName'].toLowerCase().contains(query.toLowerCase()) ||
            item['IdItem'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Function to handle QR code scanning
  void _startQRScan() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Scan QR Code'),
        message: Text('Position the QR code within the frame'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showQRScanner();
            },
            child: Text('Open Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // Show QR scanner
  void _showQRScanner() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Scan QR Code'),
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: QRView(
                            key: qrKey, onQRViewCreated: _onQRViewCreated),
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
              ),
            ));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        // Found a QR code - process it and close the scanner
        controller.pauseCamera();
        Navigator.pop(context); // Close the scanner
        _processScannedQRCode(scanData.code!);
      }
    });
  }

  // Process the scanned QR code
  void _processScannedQRCode(String qrData) {
    // Try to find the item by ID in the QR code
    final scannedItemId = qrData.trim();

    // Look for the item in allItems
    final foundItem = allItems.firstWhere(
      (item) => item['IdItem'] == scannedItemId,
      orElse: () => null,
    );

    if (foundItem != null) {
      // Item found, select it
      setState(() {
        if (!selectedItems.contains(foundItem)) {
          selectedItems.add(foundItem);
          // Also filter to show this item
          searchController.text = foundItem['IdItem'];
          _filterItems(foundItem['IdItem']);
        }
      });

      // Show success message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Item Found'),
          content: Text('Item "${foundItem['ItemName']}" has been selected.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      // Item not found
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Item Not Found'),
          content: Text('No item found with ID: $scannedItemId'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // Function to associate selected items with the event
  Future<void> _associateItems() async {
    if (selectedItems.isEmpty) {
      setState(() {
        errorMessage = 'Please select at least one item';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E4',
          'IdEvent': widget.eventId,
          'Items': json.encode(selectedItems),
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Items associated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to associate items: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AddNavigationBar(
        title: 'Associate Items',
        previousPageTitle: 'Event Details',
        onAddPressed: _associateItems,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar with QR Code Button
              Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: searchController,
                      onChanged: _filterItems,
                      placeholder: 'Search items...',
                    ),
                  ),
                  SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.all(12),
                    onPressed: _startQRScan,
                    child: Icon(CupertinoIcons.qrcode_viewfinder, size: 24),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 14,
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No items available',
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              var item = filteredItems[index];
                              return CupertinoListTile(
                                title: Text(
                                  item['ItemName'] ?? 'Unknown Item',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  "ID: ${item['IdItem']}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                trailing: CupertinoCheckbox(
                                  value: selectedItems.contains(item),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedItems.add(item);
                                      } else {
                                        selectedItems.remove(item);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
