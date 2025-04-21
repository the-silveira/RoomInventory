import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:roominventory/eventos/eventdetails.dart';
import '../appbar/appbar.dart';
import 'eventos_add.dart';

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  dynamic events = [];
  dynamic filteredEvents = []; // List for search results
  TextEditingController searchController =
      TextEditingController(); // Search controller
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
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
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
        return item['IdEvent'].toLowerCase().contains(query.toLowerCase()) ||
            item['EventName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Function to determine card background color
  IconData _getCardIcon(String eventDate) {
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

  Future<void> _refreshData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      isLoading = true; // Show loading indicator
    });
    await _fetchData(); // Re-fetch data from the API
  }

  void NavigateAdd() {
    print("Navigating to Add Item Page");
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddEventPage()),
    ).then((_) {
      // This will run when the AddEventPage pops
      _refreshData(); // Refresh your data
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
        previousPageTitle: 'Inventário',
        onAddPressed: NavigateAdd,
      ),
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
          isLoading
              ? Center(child: CupertinoActivityIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : Expanded(
                      child: filteredEvents.isEmpty
                          ? Scaffold(
                              body: Center(
                                child: Text(
                                  "Não tem Eventos Registados",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .color,
                                  ),
                                ),
                              ),
                            )
                          : CustomScrollView(
                              slivers: [
                                CupertinoSliverRefreshControl(
                                  onRefresh:
                                      _refreshData, // Trigger refresh when pulled
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      var event = filteredEvents[index];
                                      return CupertinoListSection.insetGrouped(
                                        children: [
                                          CupertinoListTile.notched(
                                            title: Row(
                                              children: [
                                                Text(
                                                  event['EventName']
                                                          .toString()
                                                          .isEmpty
                                                      ? 'Empty Name'
                                                      : event['EventName']
                                                                  .toString()
                                                                  .length >
                                                              35
                                                          ? event['EventName']
                                                                  .toString()
                                                                  .substring(
                                                                      0, 35) +
                                                              "..."
                                                          : event['EventName'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                Icon(
                                                  _getCardIcon(event['Date']),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ],
                                            ),
                                            subtitle: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom:
                                                      10), // Add padding above the subtitle
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "📍 ${event['EventPlace']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          2), // Add spacing between lines
                                                  Text(
                                                    "👤 ${event['NameRep']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "📧 ${event['EmailRep']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "🛠 ${event['TecExt']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "📅 Date: ${event['Date']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "ID: ${event['IdEvent']}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EventDetailsPage(
                                                          eventId:
                                                              event['IdEvent']),
                                                ),
                                              ).then((_) {
                                                _fetchData(); // Only refresh if needed
                                              });
                                              ;
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                    childCount: filteredEvents.length,
                                  ),
                                ),
                              ],
                            ),
                    ),
        ],
      ),
    );
  }
}
