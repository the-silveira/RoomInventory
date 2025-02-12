import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
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
  dynamic items;
  bool isLoading = true;

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
        }
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
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBack(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : event == null
              ? Center(child: Text('No event details found'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event details in a scrollable view
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event!['EventName'] ?? 'No Name',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("📍 ${event!['EventPlace']}"),
                          Text("👤 ${event!['NameRep']}"),
                          Text("📧 ${event!['EmailRep']}"),
                          Text("🛠 ${event!['TecExt']}"),
                          Text("📅 Date: ${event!['Date']}"),
                          Divider(thickness: 2, height: 20),
                          Text(
                            "Itens Associados",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable list of associated items
                    Expanded(
                      child: items.isEmpty
                          ? Center(child: Text("No items associated with this event."))
                          : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                var item = items[index];

                                return ExpansionTile(
                                  title: Text(
                                    item['ItemName'] ?? 'Unknown Item',
                                    textAlign: TextAlign.left, // Align the title to the left
                                  ),
                                  subtitle: Text(
                                    "ID: ${item['IdItem']}",
                                    textAlign: TextAlign.left, // Align the subtitle to the left
                                  ),
                                  leading: Icon(
                                    CupertinoIcons.cube_box,
                                    color: Colors.blue,
                                  ),
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: (item['DetailsList'] as List<dynamic>)
                                            .map<Widget>(
                                              (detail) => Text(
                                                "${detail['DetailsName']}: ${detail['Details']}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 12), // Align each detail to the left
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20), // Remove padding inside ListTile
                                      title: Text(
                                        "Localização: ${item['PlaceName']}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 15), // Align the subtitle to the left
                                      ),
                                      subtitle: Text(
                                        "Zona: ${item['ZoneName']}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 12), // Align the title to the left
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    )
                  ],
                ),
    );
  }
}
