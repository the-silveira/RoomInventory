import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/services/supabase_service.dart';

class addItemEventsController {
  List allItems = [];
  List filteredItems = [];
  List selectedItems = [];
  bool isLoading = true;
  String errorMessage = '';
  Barcode? result;
  QRViewController? qrController;

  Future fetchAllItems(String eventId) async {
    try {
      isLoading = true;
      errorMessage = '';

      allItems = await SupabaseService.getItemsAvailableForEvent(eventId);
      filteredItems = allItems;
    } catch (e) {
      errorMessage = 'Connection error: $e';
      allItems = [];
      filteredItems = [];
    } finally {
      isLoading = false;
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems = allItems;
      return;
    }

    filteredItems = allItems.where((item) {
      final name = (item['itemname'] ?? item['ItemName'] ?? '').toLowerCase();
      final id = (item['iditem'] ?? item['IdItem'] ?? '').toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();
  }

  void processScannedQRCode(String qrData, List allItems) {
    final scannedItemId = qrData.trim();

    final foundItem = allItems.firstWhere(
      (item) => (item['iditem'] ?? item['IdItem'] ?? '') == scannedItemId,
      orElse: () => null,
    );

    if (foundItem != null) {
      if (!selectedItems.contains(foundItem)) {
        selectedItems.add(foundItem);
      }
    }
  }

  Future<bool> addItemEvents(String eventId) async {
    if (selectedItems.isEmpty) {
      errorMessage = 'Please select at least one item';
      return false;
    }

    isLoading = true;
    errorMessage = '';

    try {
      for (final item in selectedItems) {
        final itemId = item['iditem'] ?? item['IdItem'] ?? '';
        if (itemId.isNotEmpty) {
          await SupabaseService.addItemToEvent(eventId, itemId);
        }
      }
      return true;
    } catch (e) {
      errorMessage = 'Connection error: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void disposeQRController() {
    qrController?.dispose();
  }
}
