import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:roominventory/eventos/eventdetails.dart';
import 'package:flutter/cupertino.dart';

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
        return const Color.fromARGB(255, 2, 2, 2)!; // Past event (Darker)
      } else if (eventDateTime.isAtSameMomentAs(todayOnly)) {
        return Colors.blue; // Today's event (Blue)
      } else {
        return const Color.fromARGB(255, 134, 134, 134); // Future event (White)
      }
    } catch (e) {
      print("Date parsing error: $e");
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: 'Eventos', icon: "Drawer"),
        drawer: AppDrawer(),
        body: events.toString().isEmpty || events == null
            ? Center(child: CircularProgressIndicator()) // Show loader while fetching
            : events != 0
                ? ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var event = events[index];
                      Color cardColor = _getCardColor(event['Date']);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            CupertinoIcons.calendar,
                            color: cardColor,
                          ),
                          title: Text(event['EventName'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📍 ${event['EventPlace']}"),
                              Text("👤 ${event['NameRep']}"),
                              Text("📧 ${event['EmailRep']}"),
                              Text("🛠 ${event['TecExt']}"),
                              Text("📅 Date: ${event['Date']}"),
                              Text("ID: ${event['IdEvent']}"),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsPage(eventId: event['IdEvent']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : Center(child: Text("Não tem Eventos Registados")));
  }
}
