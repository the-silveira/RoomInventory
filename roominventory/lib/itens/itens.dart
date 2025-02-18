import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roominventory/appbar/appbar.dart';
import 'package:roominventory/drawer/drawer.dart';
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

  void _filterItems(String query) {
    if (items == null) return;

    setState(() {
      filteredItems = items!.where((item) {
        return item['IdItem'].toLowerCase().contains(query.toLowerCase()) || item['ItemName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void NavigateAdd() {
    print("aaaaaaaaaaaaa");
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddItemPage()),
    );
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
                                ? Scaffold(
                                    body: Center(
                                      child: Text(
                                        "Não tem Itens Registados",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                        ),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: CupertinoListSection.insetGrouped(
                                      header: Text(
                                        "Todos os Items",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
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
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  message: Text(
                                                    "ID: ${item['IdItem']}\n\nDetails:",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                  actions: [
                                                    ...item['DetailsList'].map<CupertinoActionSheetAction>((detail) {
                                                      return CupertinoActionSheetAction(
                                                        child: Text(
                                                          "${detail['DetailsName']}: ${detail['Details']}",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).colorScheme.primary,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      );
                                                    }).toList(),
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
                                  ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
