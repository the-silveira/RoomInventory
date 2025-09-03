import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class addItemEventsController {
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  List<dynamic> selectedItems = [];
  bool isLoading = true;
  String errorMessage = '';
  Barcode? result;
  QRViewController? qrController;

  // Fetch all available items from the API
  Future<void> fetchAllItems(String eventId) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I4', 'IdEvent': eventId},
      );

      if (response.statusCode == 200) {
        allItems = json.decode(response.body);
        filteredItems = allItems;
      } else {
        errorMessage = 'Failed to load items';
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  // Function to filter items based on search query
  void filterItems(String query) {
    filteredItems = allItems.where((item) {
      return item['ItemName'].toLowerCase().contains(query.toLowerCase()) ||
          item['IdItem'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Process the scanned QR code
  void processScannedQRCode(String qrData, List<dynamic> allItems) {
    final scannedItemId = qrData.trim();

    // Look for the item in allItems
    final foundItem = allItems.firstWhere(
      (item) => item['IdItem'] == scannedItemId,
      orElse: () => null,
    );

    if (foundItem != null) {
      // Item found, select it
      if (!selectedItems.contains(foundItem)) {
        selectedItems.add(foundItem);
      }
    }
  }

  // Function to associate selected items with the event
  Future<bool> addItemEvents(String eventId) async {
    if (selectedItems.isEmpty) {
      errorMessage = 'Please select at least one item';
      return false;
    }

    isLoading = true;

    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E4',
          'IdEvent': eventId,
          'Items':
              json.encode(selectedItems.map((item) => item['IdItem']).toList()),
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        errorMessage = 'Failed to connect to the server';
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void disposeQRController() {
    qrController?.dispose();
  }
}
