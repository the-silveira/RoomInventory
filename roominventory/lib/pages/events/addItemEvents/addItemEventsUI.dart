import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsController.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsWidgets.dart';

class addItemEventsPage extends StatefulWidget {
  final String eventId;

  addItemEventsPage({required this.eventId});

  @override
  _addItemEventsPageState createState() => _addItemEventsPageState();
}

class _addItemEventsPageState extends State<addItemEventsPage> {
  final addItemEventsController _controller = addItemEventsController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.disposeQRController();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() async {
    await _controller.fetchAllItems(widget.eventId);
    setState(() {});
  }

  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query);
    });
  }

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

  void _onItemSelectionChanged(dynamic item) {
    setState(() {
      if (_controller.selectedItems.contains(item)) {
        _controller.selectedItems.remove(item);
      } else {
        _controller.selectedItems.add(item);
      }
    });
  }

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
      navigationBar: AddNavigationBar(
        title: 'Associate Items',
        previousPageTitle: 'Event Details',
        onAddPressed: _addItemEvents,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchBarWithQR(
                searchController: _searchController,
                onSearchChanged: _filterItems,
                onQRScanPressed: _startQRScan,
              ),
              SizedBox(height: 16),
              ErrorMessage(message: _controller.errorMessage),
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
