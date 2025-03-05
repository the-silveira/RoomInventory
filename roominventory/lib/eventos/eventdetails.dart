import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roominventory/appbar/appbar.dart';

import 'package:roominventory/eventos/eventos_items_add.dart';
import 'dart:convert';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  EventDetailsPage({required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  dynamic event;
  List<dynamic> items = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch event details
      var eventResponse = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (eventResponse.statusCode == 200) {
        List<dynamic> allEvents = json.decode(eventResponse.body);
        var selectedEvent = allEvents.firstWhere(
          (e) => e['IdEvent'] == widget.eventId,
          orElse: () => null,
        );

        if (selectedEvent != null) {
          setState(() {
            event = selectedEvent;
          });
        } else {
          setState(() {
            errorMessage = 'Event not found';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load event details';
        });
      }

      // Fetch item details for this event
      var itemsResponse = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E2', 'IdEvent': widget.eventId},
      );

      if (itemsResponse.statusCode == 200) {
        dynamic responseBody = json.decode(itemsResponse.body);

        if (responseBody is Map && responseBody.containsKey('status') && responseBody['status'] == 'error') {
          print("Error");
        } else {
          print(itemsResponse.body.toString());

          List<dynamic> rawItems = json.decode(itemsResponse.body);

          // Group the details by IdItem
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

            // Add details to the item
            groupedItems[idItem]!['DetailsList'].add({
              'DetailsName': detailsName,
              'Details': detailValue,
            });
          }

          setState(() {
            items = groupedItems.values.toList();
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load item details';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteEvent() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E5', // Assuming 'E3' is the API parameter for deleting an event
          'IdEvent': widget.eventId,
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          // Event deleted successfully
          Navigator.pop(context); // Navigate back to the previous page
        } else {
          setState(() {
            errorMessage = 'Failed to delete event: ${responseBody['message']}';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to delete event: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
    }
  }

  void _confirmDelete() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text(
              'Delete',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteEvent(); // Delete the event
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      isLoading = true; // Show loading indicator
    });
    await _fetchData(); // Re-fetch data from the API
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  void NavigateAdd() {
    print("Navigating to Add Item Page");
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AssociateItemsPage(eventId: widget.eventId),
        ));
  }

  Future<void> _deleteItemDB(String IdItem) async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E6', 'IdItem': IdItem, 'IdEvent': widget.eventId},
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Relatório',
        previousPageTitle: 'Eventos',
        onAddPressed: NavigateAdd,
      ),
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: _refreshData, // Trigger refresh when pulled
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event!['EventName'] ?? 'No Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    )),
                                SizedBox(height: 8),
                                Text(
                                  "📍 ${event!['EventPlace']}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  "👤 ${event!['NameRep']}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  "📧 ${event!['EmailRep']}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  "🛠 ${event!['TecExt']}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  "📅 Date: ${event!['Date']}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          items.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "Não tem Itens Registados",
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    CupertinoListSection.insetGrouped(
                                      header: Text(
                                        "Todos os Itens",
                                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            var item = items[index];
                                            return CupertinoListTile(
                                              title: Text(
                                                item['ItemName'] ?? 'Unknown Item',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                              ),
                                              subtitle: Text(
                                                "ID: ${item['IdItem']}",
                                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                              ),
                                              trailing: CupertinoListTileChevron(),
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
                                                        ...item['DetailsList'].map<CupertinoActionSheetAction>((detail) {
                                                          return CupertinoActionSheetAction(
                                                            child: Text(
                                                              "${detail['DetailsName']}: ${detail['Details']}",
                                                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
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
                                                            "Remover Item do Evento",
                                                            style: TextStyle(
                                                              color: CupertinoColors.destructiveRed,
                                                              fontSize: 12,
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
                                        ),
                                      ],
                                    ),
                                    CupertinoListSection(
                                      children: [
                                        CupertinoListTile.notched(
                                          title: Text(
                                            'Eliminar Evento',
                                            style: TextStyle(color: CupertinoColors.destructiveRed),
                                          ),
                                          onTap: _confirmDelete,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }
}
/*  TextButton(
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
                                                  
                                                  
                                                  
*/
