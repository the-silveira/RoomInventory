import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:roominventory/eventos/eventdetails.dart';
import '../appbar/appbar.dart';

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  dynamic events = [];
  dynamic filteredEvents = []; // List for search results
  TextEditingController searchController = TextEditingController(); // Search controller
  bool isLoading = true;
  String errorMessage = '';

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
          filteredEvents = events; // Initialize filtered list with all events
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
    if (events == null) return;

    setState(() {
      filteredEvents = events!.where((item) {
        return item['IdEvent'].toLowerCase().contains(query.toLowerCase()) || item['EventName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Function to determine card background color
  IconData _getCardColor(String eventDate) {
    try {
      DateTime eventDateTime = DateFormat("yyyy-MM-dd").parse(eventDate);
      DateTime today = DateTime.now();
      DateTime todayOnly = DateTime(today.year, today.month, today.day);

      if (eventDateTime.isBefore(todayOnly)) {
        return CupertinoIcons.checkmark_alt;
      } else if (eventDateTime.isAtSameMomentAs(todayOnly)) {
        return CupertinoIcons.exclamationmark_octagon;
      } else {
        return CupertinoIcons.add;
      }
    } catch (e) {
      print("Date parsing error: $e");
      return CupertinoIcons.checkmark_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
        previousPageTitle: 'Inventário',
      ),
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
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
                      child: filteredEvents.isEmpty
                          ? Scaffold(
                              body: Center(
                                child: Text(
                                  "Não tem Eventos Registados",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: CupertinoListSection(
                                header: Text(
                                  "Todos os Eventos",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                  ),
                                ),
                                children: filteredEvents.map<Widget>((event) {
                                  // Corrected mapping to List<Widget>

                                  return CupertinoListSection.insetGrouped(
                                    children: [
                                      CupertinoListTile.notched(
                                        title: Row(
                                          children: [
                                            Text(
                                              event['EventName'].toString().isEmpty
                                                  ? 'Empty Name'
                                                  : event['EventName'].toString().length > 35
                                                      ? event['EventName'].toString().substring(0, 35) + "..."
                                                      : event['EventName'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Icon(_getCardColor(event['Date']))
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: EdgeInsets.only(bottom: 10), // Add padding above the subtitle
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
                                              SizedBox(height: 2),
                                              Text(
                                                "📧 ${event['EmailRep']}",
                                                style: TextStyle(
                                                  color: CupertinoColors.secondaryLabel,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "🛠 ${event['TecExt']}",
                                                style: TextStyle(
                                                  color: CupertinoColors.secondaryLabel,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "📅 Date: ${event['Date']}",
                                                style: TextStyle(
                                                  color: CupertinoColors.secondaryLabel,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 2),
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
                                }).toList(), // Make sure this is List<Widget>
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
