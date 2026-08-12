import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:roominventory/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemsController {
  List? items;
  List filteredItems = [];
  bool isLoading = true;
  String errorMessage = '';

  Future fetchData() async {
    try {
      isLoading = true;
      errorMessage = '';

      final rawItems = await SupabaseService.getItems();

      items = rawItems.map((row) {
        final detailsList = (row['detailslist'] as List<dynamic>?) ?? [];
        return {
          'IdItem': row['iditem'],
          'ItemName': row['itemname'],
          'ZoneName': row['zonename'] ?? '',
          'PlaceName': row['placename'] ?? '',
          'DetailsList': detailsList
              .map((d) => {
                    'DetailsName': d['DetailsName'] ?? '',
                    'Details': d['Details'] ?? '',
                  })
              .toList(),
        };
      }).toList();

      filteredItems = items ?? [];
    } catch (e) {
      errorMessage = 'Connection error: $e';
      items = [];
      filteredItems = [];
    } finally {
      isLoading = false;
    }
  }

  void filterItems(String query, List items) {
    if (query.isEmpty) {
      filteredItems = items;
      return;
    }
    filteredItems = items.where((item) {
      final idMatch =
          item['IdItem']?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final nameMatch =
          item['ItemName']?.toLowerCase().contains(query.toLowerCase()) ??
              false;
      return idMatch || nameMatch;
    }).toList();
  }

  Future<bool> deleteItem(String idItem) async {
    if (idItem.isEmpty) {
      errorMessage = 'ID do item inválido';
      return false;
    }

    try {
      isLoading = true;

      await SupabaseService.deleteItem(idItem);

      // Atualiza as listas locais para refletir na UI
      items?.removeWhere((item) => item['IdItem'] == idItem);
      filteredItems.removeWhere((item) => item['IdItem'] == idItem);

      errorMessage = '';
      return true;
    } on PostgrestException catch (e) {
      // Erro específico do Supabase/PostgreSQL
      errorMessage = 'Erro na base de dados: ${e.message}';
      return false;
    } catch (e) {
      errorMessage = 'Erro ao eliminar: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future saveAndShareQRCode(String itemId, String itemName) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTRB(0, 0, 300, 350));

      final paint = Paint()
        ..color = CupertinoColors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = CupertinoColors.systemGrey3
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final backgroundRect = Rect.fromLTWH(16, 16, 268, 318);
      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(16)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(16)),
        borderPaint,
      );

      final qrPainter = QrPainter(
        data: itemId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      canvas.save();
      canvas.translate(50, 50);
      qrPainter.paint(canvas, Size(200, 200));
      canvas.restore();

      final textStyle = ui.TextStyle(
        color: CupertinoColors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
      ))
        ..pushStyle(textStyle)
        ..addText('ID: ' + itemId);

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: 268));

      canvas.drawParagraph(paragraph, Offset(16, 275));

      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 350);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate QR code image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(tempDir.path + '/qr_code_' + itemId + '.png');
      await tempFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'QR Code for Item ' + itemName,
        subject: 'QR Code',
      );

      await tempFile.delete();
    } catch (e) {
      throw Exception('Error sharing QR code: $e');
    }
  }
}
