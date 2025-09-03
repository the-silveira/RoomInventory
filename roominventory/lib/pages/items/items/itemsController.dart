import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ItemsController {
  List<dynamic>? items;
  List<dynamic> filteredItems = [];
  bool isLoading = true;
  String errorMessage = '';

  // Fetch items data
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

  // Filter items based on search query
  void filterItems(String query, List<dynamic> items) {
    if (items == null) return;

    filteredItems = items.where((item) {
      return item['IdItem'].toLowerCase().contains(query.toLowerCase()) ||
          item['ItemName'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Delete item from database
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

  // Save QR code as image and share
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
