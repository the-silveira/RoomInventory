import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:roominventory/eventos/eventdetails.dart';
import '../appbar/appbar.dart';
import '../drawer/drawer.dart';

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  dynamic events = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Function to fetch data from the API
  Future<void> _fetchData() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Function to determine card background color
  Color _getCardColor(String eventDate) {
    try {
      DateTime eventDateTime = DateFormat("yyyy-MM-dd").parse(eventDate);
      DateTime today = DateTime.now();
      DateTime todayOnly = DateTime(today.year, today.month, today.day);

      if (eventDateTime.isBefore(todayOnly)) {
        return CupertinoColors.systemGrey; // Past event (Grey)
      } else if (eventDateTime.isAtSameMomentAs(todayOnly)) {
        return CupertinoColors.systemBlue; // Today's event (Blue)
      } else {
        return CupertinoColors.systemGreen; // Future event (Green)
      }
    } catch (e) {
      print("Date parsing error: $e");
      return CupertinoColors.systemGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
      ),
      child: events.toString().isEmpty || events == null
          ? Center(child: CupertinoActivityIndicator()) // Show Cupertino loader
          : events != 0
              ? ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    Color cardColor = _getCardColor(event['Date']);

                    return CupertinoListSection.insetGrouped(
                      children: [
                        CupertinoListTile.notched(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.2), // Subtle background color
                              borderRadius: BorderRadius.circular(20), // Circular shape
                            ),
                            child: Icon(
                              CupertinoIcons.calendar,
                              color: cardColor,
                              size: 20,
                            ),
                          ),
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 4), // Add padding below the title
                            child: Text(
                              event['EventName'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4), // Add padding above the subtitle
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "📍 ${event['EventPlace']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2), // Add spacing between lines
                                Text(
                                  "👤 ${event['NameRep']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2), // Add spacing between lines
                                Text(
                                  "📧 ${event['EmailRep']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2), // Add spacing between lines
                                Text(
                                  "🛠 ${event['TecExt']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2), // Add spacing between lines
                                Text(
                                  "📅 Date: ${event['Date']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2), // Add spacing between lines
                                Text(
                                  "ID: ${event['IdEvent']}",
                                  style: TextStyle(
                                    color: CupertinoColors.secondaryLabel,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: CupertinoListTileChevron(),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => EventDetailsPage(eventId: event['IdEvent']),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                )
              : Center(child: Text("Não tem Eventos Registados")),
    );
  }
}
