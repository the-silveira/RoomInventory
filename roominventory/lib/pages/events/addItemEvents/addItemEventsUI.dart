import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsController.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsWidgets.dart';

/// A page for associating items with events through manual selection or QR scanning.
///
/// This page provides an interface for selecting items to associate with a specific event.
/// Users can search for items manually or use QR code scanning to quickly add items.
/// The page integrates with [addItemEventsController] for business logic and manages
/// the entire item selection workflow.
///
/// Features:
/// - Search functionality for manual item selection
/// - QR code scanning for quick item addition
/// - Multi-item selection with visual feedback
/// - API integration for item-event association
/// - Error handling and user feedback
///
/// Route Parameters:
/// - Requires an `eventId` to specify which event to associate items with
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(
///     builder: (context) => addItemEventsPage(eventId: 'event123'),
///   ),
/// );
/// ```
class addItemEventsPage extends StatefulWidget {
  /// The unique identifier of the event to associate items with
  ///
  /// This ID is passed to the API endpoints to identify which event
  /// the selected items should be associated with.
  final String eventId;

  addItemEventsPage({required this.eventId});

  @override
  _addItemEventsPageState createState() => _addItemEventsPageState();
}

/// The state class for [addItemEventsPage] that manages the UI and item selection logic.
///
/// This state handles:
/// - Controller initialization and disposal
/// - Data loading and filtering
/// - QR code scanning workflow
/// - Item selection management
/// - API communication for item-event association
/// - User feedback through dialogs and snackbars
class _addItemEventsPageState extends State<addItemEventsPage> {
  /// Controller instance that manages item selection business logic
  ///
  /// Handles API communication, item filtering, QR processing, and selection state.
  final addItemEventsController _controller = addItemEventsController();

  /// Controller for the search text input field
  ///
  /// Manages the search query text and provides focus control for the search interface.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    /// Cleans up resources when the page is disposed
    ///
    /// Ensures proper disposal of the QR controller and search controller
    /// to prevent memory leaks and release camera resources.
    _controller.disposeQRController();
    _searchController.dispose();
    super.dispose();
  }

  /// Loads initial data for the page
  ///
  /// Fetches all available items that can be associated with the event
  /// and updates the UI state when complete.
  void _loadData() async {
    await _controller.fetchAllItems(widget.eventId);
    setState(() {});
  }

  /// Filters the items list based on the search query
  ///
  /// Parameters:
  ///   - `query`: The search string to filter items by
  ///
  /// Side effects:
  ///   - Updates the controller's filtered items list
  ///   - Triggers a UI rebuild to reflect the filtered results
  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query);
    });
  }

  /// Initiates the QR code scanning workflow
  ///
  /// Shows an action sheet with options to open the camera for QR scanning
  /// or cancel the operation.
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

  /// Displays the full-screen QR code scanner interface
  ///
  /// Shows a modal page with camera preview and QR scanning capabilities.
  /// Provides a navigation bar with back button for closing the scanner.
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
        child: QRScannerView(
          onQRViewCreated: _onQRViewCreated,
          onClosePressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  /// Callback when the QR scanner view is created and ready
  ///
  /// Parameters:
  ///   - `controller`: The QRViewController instance for managing the scanner
  ///
  /// Sets up the scanner to listen for scanned data and process QR codes automatically.
  void _onQRViewCreated(QRViewController controller) {
    _controller.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        controller.pauseCamera();
        Navigator.pop(context);
        _processScannedQRCode(scanData.code!);
      }
    });
  }

  /// Processes a successfully scanned QR code
  ///
  /// Parameters:
  ///   - `qrData`: The raw data extracted from the QR code
  ///
  /// This method:
  /// 1. Processes the QR data to find matching items
  /// 2. Updates the search field with the scanned data
  /// 3. Filters the items list to show the matched item
  /// 4. Shows a confirmation dialog to the user
  void _processScannedQRCode(String qrData) {
    setState(() {
      _controller.processScannedQRCode(qrData, _controller.allItems);
      _searchController.text = qrData;
      _filterItems(qrData);
    });

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('QR Code Scanned'),
        content: Text('Item ID: $qrData'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Handles item selection/deselection in the list
  ///
  /// Parameters:
  ///   - `item`: The item that was selected or deselected
  ///
  /// Toggles the item's selection state in the controller and updates the UI.
  void _onItemSelectionChanged(dynamic item) {
    setState(() {
      if (_controller.selectedItems.contains(item)) {
        _controller.selectedItems.remove(item);
      } else {
        _controller.selectedItems.add(item);
      }
    });
  }

  /// Associates the selected items with the event
  ///
  /// Calls the controller to persist the item-event associations and handles
  /// the result with appropriate user feedback.
  ///
  /// UI Effects:
  ///   - Shows success snackbar and navigates back on success
  ///   - Shows error snackbar on failure
  Future<void> _addItemEvents() async {
    bool success = await _controller.addItemEvents(widget.eventId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Items associated successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      /// Custom navigation bar with save functionality
      ///
      /// Includes:
      /// - Title: 'Associate Items'
      /// - Back button with 'Event Details' label
      /// - Save button that triggers item association
      navigationBar: AddNavigationBar(
        title: 'Associate Items',
        previousPageTitle: 'Event Details',
        onAddPressed: _addItemEvents,
      ),

      /// Main content area with search, error display, and item list
      ///
      /// Uses SafeArea to avoid system UI overlaps and provides
      /// a structured layout for the item selection interface.
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /// Search bar with QR scan button
              ///
              /// Provides text-based search functionality and quick access
              /// to QR code scanning for item selection.
              SearchBarWithQR(
                searchController: _searchController,
                onSearchChanged: _filterItems,
                onQRScanPressed: _startQRScan,
              ),
              SizedBox(height: 16),

              /// Error message display
              ///
              /// Shows validation errors or API error messages from the controller.
              ErrorMessage(message: _controller.errorMessage),

              /// Scrollable list of selectable items
              ///
              /// Displays filtered items with selection checkboxes and
              /// handles user selection interactions.
              Expanded(
                child: ItemsListView(
                  controller: _controller,
                  onItemSelectionChanged: _onItemSelectionChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
