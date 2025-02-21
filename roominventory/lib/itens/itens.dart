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
  final ScrollController _scrollController = ScrollController();

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

  Future<void> _deleteItemDB(String IdItem) async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I3', 'IdItem': IdItem},
      );
      if (response.statusCode == 200) {
        if (json.decode(response.body)['status'].toString() == 'success') {
          _showMessage("Item Eliminado com Sucesso", json.decode(response.body)['status'].toString());
        } else {
          _showMessage("Erro ao Eliminar. Tente novamente", json.decode(response.body)['status'].toString());
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
        return item['IdItem'].toLowerCase().contains(query.toLowerCase()) || item['ItemName'].toLowerCase().contains(query.toLowerCase());
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
          // "Não" button
          CupertinoDialogAction(
            child: Text('Não'),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
          ),
          // "Sim" button
          CupertinoDialogAction(
            child: Text('Sim'),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              print('delete'); // Print 'delete' when "Sim" is selected
              _deleteItemDB(IdItem);
            },
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, status) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(status == 'success' ? 'Sucesso' : 'Erro'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => {
              Navigator.pop(context),
              status == 'success' ? Navigator.pop(context) : null,
            },
          ),
        ],
      ),
    );
  }

  void _deleteItem(String IdItem, BuildContext context) {
    print(IdItem);
    _showDeleteDialog('Tem Mesmo a certeza que quer eliminar?', context, IdItem);
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
                        onRefresh: _fetchData, // Trigger refresh on pull-to-refresh
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
                              child: Center(child: CupertinoActivityIndicator()),
                            )
                          : filteredItems.isEmpty
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      "Não tem Itens Registados",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
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
                                                  TextButton(
                                                    onPressed: () {
                                                      _deleteItem(item['IdItem'], context); // Pass the context here
                                                    },
                                                    child: Text(
                                                      "Eliminar",
                                                      style: TextStyle(
                                                        color: CupertinoColors.destructiveRed,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
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
