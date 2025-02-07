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
  List<dynamic> events = [];

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
        return Colors.grey[300]!; // Past event (Darker)
      } else if (eventDateTime.isAtSameMomentAs(todayOnly)) {
        return Colors.blue[100]!; // Today's event (Blue)
      } else {
        return Colors.white; // Future event (White)
      }
    } catch (e) {
      print("Date parsing error: $e");
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Eventos'),
      drawer: AppDrawer(),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                Color cardColor = _getCardColor(event['Date']);

                return Card(
                  color: cardColor,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.event, color: Colors.blue),
                    title: Text(event['EventName'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 ${event['EventPlace']}"),
                        Text("👤 ${event['NameRep']} - 📧 ${event['EmailRep']}"),
                        Text("🛠 ${event['TecExt']}"),
                        Text("📅 Date: ${event['Date']}"),
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
            ),
    );
  }
}
