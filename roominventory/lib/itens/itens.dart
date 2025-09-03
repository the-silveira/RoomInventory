import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

import 'package:roominventory/appbar/appbar.dart';
import 'package:roominventory/itens/item_add.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<dynamic>? items;
  List<dynamic> filteredItems = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  // Global key for capturing QR code
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
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

        setState(() {
          items = groupedItems.values.toList();
          filteredItems = items!;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteItemDB(String IdItem) async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I3', 'IdItem': IdItem},
      );
      if (response.statusCode == 200) {
        if (json.decode(response.body)['status'].toString() == 'success') {
          _showMessage("Item Eliminado com Sucesso",
              json.decode(response.body)['status'].toString());
        } else {
          _showMessage("Erro ao Eliminar. Tente novamente",
              json.decode(response.body)['status'].toString());
        }
      }
    } catch (e) {
      _showMessage("Erro Inseperado. Tente novamente", 'error');
    }
    _fetchData();
  }

  void _filterItems(String query) {
    if (items == null) return;

    setState(() {
      filteredItems = items!.where((item) {
        return item['IdItem'].toLowerCase().contains(query.toLowerCase()) ||
            item['ItemName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void NavigateAdd() {
    print("Navigating to Add Item Page");
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddItemPage()),
    );
  }

  void _showDeleteDialog(String message, BuildContext context, String IdItem) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('Não'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('Sim'),
            onPressed: () {
              Navigator.pop(context);
              print('delete');
              _deleteItemDB(IdItem);
            },
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, String status) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(status == 'success' ? 'Sucesso' : 'Erro'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (status == 'success') {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteItem(String IdItem, BuildContext context) {
    print(IdItem);
    _showDeleteDialog(
        'Tem Mesmo a certeza que quer eliminar?', context, IdItem);
  }

  void _showQRCodeDialog(String itemId, String itemName) {
    final GlobalKey qrKey = GlobalKey();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Code - $itemName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: CupertinoColors.label,
                  ),
                ),
                SizedBox(height: 16),
                RepaintBoundary(
                  key: qrKey,
                  child: _buildQRCode(itemId),
                ),
                SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: () => _saveQRCode(itemId, itemName),
                  child: Text('Download QR Code'),
                ),
                SizedBox(height: 8),
                CupertinoButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode(String itemId) {
    return Container(
      width: 220, // Ensures enough width for left alignment
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey3),
        borderRadius: BorderRadius.circular(8),
        color: CupertinoColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the left
        children: [
          Center(
            child: QrImageView(
              data: itemId,
              version: QrVersions.auto,
              size: 200.0,
              gapless: false,
              backgroundColor: CupertinoColors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: CupertinoColors.black,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: CupertinoColors.black,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ID: $itemId',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.left, // Ensures left alignment
          ),
        ],
      ),
    );
  }

  Future<void> _saveQRCode(String itemId, String itemName) async {
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
      canvas.translate(50, 50); // Adjust position as needed
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
        _showMessage('Failed to generate QR code image', 'error');
        return;
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
      print('Error sharing QR code: $e');
      _showMessage('Error sharing QR code: ${e.toString()}', 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Itens',
        previousPageTitle: 'Inventário',
        onAddPressed: NavigateAdd,
      ),
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SafeArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: _fetchData,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoSearchTextField(
                            controller: searchController,
                            onChanged: _filterItems,
                            placeholder: 'Search items...',
                          ),
                        ),
                      ),
                      items == null
                          ? SliverFillRemaining(
                              child:
                                  Center(child: CupertinoActivityIndicator()),
                            )
                          : filteredItems.isEmpty
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      "Não tem Itens Registados",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .color,
                                      ),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      var item = filteredItems[index];
                                      return CupertinoListTile(
                                        title: Text(
                                          item['ItemName'] ?? 'Unknown Item',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "ID: ${item['IdItem']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        trailing: Icon(
                                            CupertinoIcons.chevron_forward),
                                        onTap: () {
                                          showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoActionSheet(
                                                title: Text(
                                                  item['ItemName'] ??
                                                      'Unknown Item',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                message: Text(
                                                  "ID: ${item['IdItem']}\n\nDetails:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoActionSheetAction(
                                                    child: Text(
                                                      "Show QR Code",
                                                      style: TextStyle(
                                                        color: CupertinoColors
                                                            .activeBlue,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _showQRCodeDialog(
                                                          item['IdItem'],
                                                          item['ItemName']);
                                                    },
                                                  ),
                                                  ...item['DetailsList'].map<
                                                          CupertinoActionSheetAction>(
                                                      (detail) {
                                                    return CupertinoActionSheetAction(
                                                      child: Text(
                                                        "${detail['DetailsName']}: ${detail['Details']}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  }).toList(),
                                                  CupertinoActionSheetAction(
                                                    isDestructiveAction: true,
                                                    child: Text("Eliminar"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteItem(
                                                          item['IdItem'],
                                                          context);
                                                    },
                                                  ),
                                                ],
                                                cancelButton:
                                                    CupertinoActionSheetAction(
                                                  child: Text('Close'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    childCount: filteredItems.length,
                                  ),
                                ),
                    ],
                  ),
                ),
    );
  }
}
