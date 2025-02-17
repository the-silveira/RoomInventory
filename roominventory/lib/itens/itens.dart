import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roominventory/appbar/appbar.dart';
import 'package:roominventory/drawer/drawer.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  dynamic items;
  List<dynamic> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
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
              'DetailsList': [],
            };
          }

          groupedItems[idItem]!['DetailsList'].add({
            'DetailsName': detailsName,
            'Details': detailValue,
          });
        }

        setState(() {
          items = groupedItems.values.toList();
          filteredItems = items;
        });
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = items.where((item) => item['IdItem'].toLowerCase().contains(query.toLowerCase()) || item['ItemName'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Itens',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: _filterItems,
                placeholder: 'Search items...',
              ),
            ),
            Expanded(
                child: items == null
                    ? Center(child: CupertinoActivityIndicator())
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              "No items found.",
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: CupertinoListSection.insetGrouped(
                              header: Text(
                                "Todos os Items",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              children: filteredItems.map((item) {
                                return CupertinoListTile(
                                  title: Text(
                                    item['ItemName'] ?? 'Unknown Item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "ID: ${item['IdItem']}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  trailing: Icon(CupertinoIcons.chevron_forward),
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title: Text(
                                            item['ItemName'] ?? 'Unknown Item',
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                          message: Text(
                                            "ID: ${item['IdItem']}\n\nDetails:",
                                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary),
                                          ),
                                          actions: [
                                            ...item['DetailsList'].map((detail) {
                                              return CupertinoActionSheetAction(
                                                child: Text(
                                                  "${detail['DetailsName']}: ${detail['Details']}",
                                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            })
                                          ],
                                          cancelButton: CupertinoActionSheetAction(
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
                              }).toList(),
                            ),
                          )),
          ],
        ),
      ),
    );
  }
}
