import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roominventory/appbar/appbar.dart';
import 'dart:convert';

import '../appbar/appbar_back.dart';

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Relatório',
        previousPageTitle: 'Eventos',
      ),
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event!['EventName'] ?? 'No Name',
                                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                              ),
                              SizedBox(height: 8),
                              Text("📍 ${event!['EventPlace']}"),
                              Text("👤 ${event!['NameRep']}"),
                              Text("📧 ${event!['EmailRep']}"),
                              Text("🛠 ${event!['TecExt']}"),
                              Text("📅 Date: ${event!['Date']}"),
                            ],
                          ),
                        ),
                        // Scrollable List of Items
                        items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                  "Todos os Itens",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                  ),
                                ),
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      var item = items[index];
                                      return CupertinoListTile(
                                        title: Text(
                                          item['ItemName'] ?? 'Unknown Item',
                                        ),
                                        subtitle: Text(
                                          "ID: ${item['IdItem']}",
                                        ),
                                        leading: Icon(
                                          CupertinoIcons.cube_box,
                                          color: CupertinoColors.activeBlue,
                                        ),
                                        trailing: CupertinoListTileChevron(),
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
                                    },
                                  ),
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }
}
