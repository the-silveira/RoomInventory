import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

/// Controller class for managing item selection and association with events.
///
/// This controller handles the business logic for adding items to events through
/// both manual selection and QR code scanning. It manages item fetching, filtering,
/// selection, and association with specific events.
///
/// Features:
/// - Fetching available items from API
/// - Item filtering based on search queries
/// - QR code scanning and processing
/// - Item selection management
/// - Event-item association API calls
/// - Loading state management
/// - Error handling and message propagation
///
/// API Endpoints:
/// - I4: Fetch items available for event association
/// - E4: Associate selected items with an event
///
/// Example usage:
/// ```dart
/// final controller = addItemEventsController();
/// await controller.fetchAllItems('event123');
/// ```
class addItemEventsController {
  /// Complete list of all items available for association
  ///
  /// Contains all items fetched from the API endpoint. Each item is a Map
  /// containing at least 'IdItem' and 'ItemName' properties.
  List<dynamic> allItems = [];

  /// Filtered list of items based on search queries
  ///
  /// This list is updated when [filterItems] is called and contains
  /// only items that match the current search criteria.
  List<dynamic> filteredItems = [];

  /// List of items currently selected for event association
  ///
  /// Contains items that have been selected either manually or through
  /// QR code scanning. This list is used when associating items with events.
  List<dynamic> selectedItems = [];

  /// Loading state indicator for asynchronous operations
  ///
  /// Set to `true` during API calls and `false` when operations complete.
  /// Used to show loading indicators in the UI.
  bool isLoading = true;

  /// Error message for operation failures
  ///
  /// Contains descriptive error messages for API communication errors
  /// or validation failures. Empty string when no errors are present.
  String errorMessage = '';

  /// The most recent QR/Barcode scan result
  ///
  /// Stores the result of the last successful QR code scan operation.
  /// Used for processing scanned item identifiers.
  Barcode? result;

  /// Controller for managing the QR code scanner
  ///
  /// Provides control over the QR scanner camera and scan operations.
  /// Must be properly disposed when no longer needed.
  QRViewController? qrController;

  /// Fetches all available items that can be associated with an event.
  ///
  /// Makes a POST request to the API endpoint to retrieve items available
  /// for association with the specified event.
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// API Parameter: `query_param = 'I4'` (Fetch items for event)
  ///
  /// Parameters:
  ///   - `eventId`: The unique identifier of the event to fetch items for
  ///
  /// Side effects:
  ///   - Sets [isLoading] to true during the API call
  ///   - Updates [allItems] and [filteredItems] with fetched data
  ///   - Sets [errorMessage] on failure
  ///   - Sets [isLoading] to false when operation completes
  ///
  /// Throws:
  ///   - HttpException for network-related errors
  ///   - FormatException for JSON parsing errors
  Future<void> fetchAllItems(String eventId) async {
    try {
      isLoading = true;
      errorMessage = '';

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

  /// Filters the items list based on a search query.
  ///
  /// Searches through [allItems] for items that match the query string
  /// in either the 'ItemName' or 'IdItem' fields. The search is case-insensitive.
  ///
  /// Parameters:
  ///   - `query`: The search string to filter items by
  ///
  /// Side effects:
  ///   - Updates [filteredItems] with the matching items
  ///   - If query is empty, [filteredItems] contains all items
  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems = allItems;
      return;
    }

    filteredItems = allItems.where((item) {
      return item['ItemName'].toLowerCase().contains(query.toLowerCase()) ||
          item['IdItem'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Processes a scanned QR code and adds the matching item to selection.
  ///
  /// Extracts the item ID from the QR code data and searches for a matching
  /// item in the [allItems] list. If found, adds the item to [selectedItems].
  ///
  /// Parameters:
  ///   - `qrData`: The raw data string from the QR code scan
  ///   - `allItems`: The complete list of items to search through
  ///
  /// Side effects:
  ///   - Adds found items to [selectedItems] if not already present
  ///   - Does nothing if no matching item is found
  ///
  /// Note: The QR code data is expected to contain an item ID that matches
  /// the 'IdItem' field in the items list.
  void processScannedQRCode(String qrData, List<dynamic> allItems) {
    final scannedItemId = qrData.trim();

    // Look for the item in allItems
    final foundItem = allItems.firstWhere(
      (item) => item['IdItem'] == scannedItemId,
      orElse: () => null,
    );

    if (foundItem != null) {
      // Item found, select it if not already selected
      if (!selectedItems.contains(foundItem)) {
        selectedItems.add(foundItem);
      }
    }
  }

  /// Associates the selected items with the specified event.
  ///
  /// Makes a POST request to the API endpoint to associate all items in
  /// [selectedItems] with the given event. Validates that at least one
  /// item is selected before making the API call.
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// API Parameter: `query_param = 'E4'` (Associate items with event)
  ///
  /// Parameters:
  ///   - `eventId`: The unique identifier of the event to associate items with
  ///
  /// Returns:
  ///   - `true` if the association was successful
  ///   - `false` if the operation failed
  ///
  /// Side effects:
  ///   - Sets [isLoading] to true during the API call
  ///   - Sets [errorMessage] on validation or API failures
  ///   - Sets [isLoading] to false when operation completes
  Future<bool> addItemEvents(String eventId) async {
    // Validate that at least one item is selected
    if (selectedItems.isEmpty) {
      errorMessage = 'Please select at least one item';
      return false;
    }

    isLoading = true;
    errorMessage = '';

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

  /// Disposes of the QR controller resources.
  ///
  /// This method should be called when the controller is no longer needed
  /// to prevent memory leaks and release camera resources.
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   controller.disposeQRController();
  ///   super.dispose();
  /// }
  /// ```
  void disposeQRController() {
    // ignore: deprecated_member_use
    qrController?.dispose();
  }
}
