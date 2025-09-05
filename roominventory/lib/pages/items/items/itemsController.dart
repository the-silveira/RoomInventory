import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Controller class for managing inventory items operations and data.
///
/// This controller handles:
/// - Fetching items data from the API with grouped details
/// - Filtering and searching items
/// - Deleting items from the database
/// - Generating and sharing QR codes for items
///
/// The controller processes raw item data from the API and groups
/// item details into a structured format for easier display and management.
///
/// Example usage:
/// ```dart
/// final controller = ItemsController();
/// await controller.fetchData();
/// ```
class ItemsController {
  /// List of all items fetched from the API with grouped details
  List<dynamic>? items;

  /// List of items filtered by search queries
  List<dynamic> filteredItems = [];

  /// Loading state indicator - true when data is being fetched
  bool isLoading = true;

  /// Error message for displaying operation failures
  String errorMessage = '';

  /// Fetches items data from the API and processes it into a grouped format.
  ///
  /// This method:
  /// 1. Sends a POST request to the items API endpoint (query_param: 'I1')
  /// 2. Processes the raw response to group item details by item ID
  /// 3. Creates a structured format with item information and details list
  /// 4. Handles HTTP errors and exceptions
  /// 5. Updates loading state upon completion
  ///
  /// The grouped format includes:
  /// - Item ID, name, zone, and place information
  /// - List of detail maps with detail names and values
  ///
  /// Throws exceptions for network errors and invalid responses.
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchData();
  /// ```
  Future<void> fetchData() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I1'},
      );

      if (response.statusCode == 200) {
        List<dynamic> rawItems = json.decode(response.body);
        Map<String, Map<String, dynamic>> groupedItems = {};

        for (var row in rawItems) {
          String idItem = row['IdItem'];
          String detailsName = row['DetailsName'];
          String detailValue = row['Details'];

          if (!groupedItems.containsKey(idItem)) {
            groupedItems[idItem] = {
              'IdItem': idItem,
              'ItemName': row['ItemName'],
              'ZoneName': row['ZoneName'],
              'PlaceName': row['PlaceName'],
              'DetailsList': <Map<String, String>>[],
            };
          }

          groupedItems[idItem]!['DetailsList'].add({
            'DetailsName': detailsName,
            'Details': detailValue,
          });
        }

        items = groupedItems.values.toList();
        filteredItems = items!;
      } else {
        errorMessage = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  /// Filters items based on a search query.
  ///
  /// This method filters the items list by matching the query against:
  /// - Item ID (IdItem)
  /// - Item name (ItemName)
  ///
  /// The search is case-insensitive and updates the filteredItems list.
  ///
  /// [query]: The search string to filter items by
  /// [items]: The list of items to filter (typically the main items list)
  ///
  /// Example:
  /// ```dart
  /// controller.filterItems('laptop', itemsList);
  /// ```
  void filterItems(String query, List<dynamic> items) {
    filteredItems = items.where((item) {
      return item['IdItem'].toLowerCase().contains(query.toLowerCase()) ||
          item['ItemName'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Deletes an item from the database.
  ///
  /// Sends a request to the API to permanently delete the specified item.
  /// Returns true if the deletion was successful, false otherwise.
  ///
  /// [idItem]: The unique identifier of the item to delete
  /// Returns: [bool] indicating success (true) or failure (false)
  ///
  /// Example:
  /// ```dart
  /// bool success = await controller.deleteItem('item123');
  /// if (success) {
  ///   // Item deleted successfully
  /// }
  /// ```
  Future<bool> deleteItem(String idItem) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I3', 'IdItem': idItem},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      }
      return false;
    } catch (e) {
      errorMessage = 'Exception: $e';
      return false;
    }
  }

  /// Generates a QR code for an item and shares it via the device's share sheet.
  ///
  /// This method:
  /// 1. Creates a custom QR code image with the item ID and branding
  /// 2. Saves the image to a temporary file
  /// 3. Opens the device's share sheet to allow saving or sharing the QR code
  /// 4. Cleans up the temporary file after sharing
  ///
  /// The QR code includes:
  /// - A white background with border
  /// - The QR code itself (encoding the item ID)
  /// - The item ID displayed below the QR code
  ///
  /// [itemId]: The unique identifier of the item to generate QR code for
  /// [itemName]: The name of the item (used in share text)
  /// Throws: Exception if QR code generation or sharing fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.saveAndShareQRCode('item123', 'Laptop');
  /// } catch (e) {
  ///   print('Error sharing QR code: $e');
  /// }
  /// ```
  Future<void> saveAndShareQRCode(String itemId, String itemName) async {
    try {
      // Create a picture recorder to draw the custom UI
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTRB(0, 0, 300, 350));

      // Draw white background with border
      final paint = Paint()
        ..color = CupertinoColors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = CupertinoColors.systemGrey3
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw background rectangle
      final backgroundRect = Rect.fromLTWH(16, 16, 268, 318);
      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(16)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(16)),
        borderPaint,
      );

      // Draw QR code
      final qrPainter = QrPainter(
        data: itemId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      // Position the QR code
      canvas.save();
      canvas.translate(50, 50);
      qrPainter.paint(canvas, Size(200, 200));
      canvas.restore();

      // Draw ID text
      final textStyle = ui.TextStyle(
        color: CupertinoColors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
      ))
        ..pushStyle(textStyle)
        ..addText('ID: $itemId');

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: 268));

      canvas.drawParagraph(paragraph, Offset(16, 275));

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 350);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate QR code image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/qr_code_$itemId.png');
      await tempFile.writeAsBytes(pngBytes);

      // Use share to let user choose where to save
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'QR Code for Item $itemName',
        subject: 'QR Code',
      );

      // Clean up
      await tempFile.delete();
    } catch (e) {
      throw Exception('Error sharing QR code: $e');
    }
  }
}
