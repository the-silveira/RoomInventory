import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../appbar/appbar.dart'; // Import the MyAppBar widget
import '../drawer/drawer.dart';

class LocaisPage extends StatefulWidget {
  @override
  _LocaisPageState createState() => _LocaisPageState();
}

class _LocaisPageState extends State<LocaisPage> {
  // Variable to store the list of places, zones, items, and details
  dynamic places;
  List<dynamic> filteredPlaces = []; // For search functionality
  TextEditingController searchController = TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    _fetchData();
  }

  // Function to fetch data from the API
  Future<void> _fetchData() async {
    try {
      // Fetch data for places, zones, items, and details
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'P2'},
      );

      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);
        print(rawData);

        // Group data by Place, Zone, Item, and Details
        Map<String, dynamic> groupedData = {};

        for (var row in rawData) {
          String idPlace = row['IdPlace'];
          String placeName = row['PlaceName'];
          String idZone = row['IdZone'];
          String zoneName = row['ZoneName'];
          String idItem = row['IdItem'];
          String itemName = row['ItemName'];
          String detailsName = row['DetailsName'];
          String detailsValue = row['Details'];

          // Initialize place if not already in the map
          if (!groupedData.containsKey(idPlace)) {
            groupedData[idPlace] = {
              'PlaceName': placeName,
              'Zones': {},
            };
          }

          // Initialize zone if not already in the place
          if (!groupedData[idPlace]['Zones'].containsKey(idZone)) {
            groupedData[idPlace]['Zones'][idZone] = {
              'ZoneName': zoneName,
              'Items': {},
            };
          }

          // Initialize item if not already in the zone
          if (!groupedData[idPlace]['Zones'][idZone]['Items'].containsKey(idItem)) {
            groupedData[idPlace]['Zones'][idZone]['Items'][idItem] = {
              'IdItem': idItem,
              'ItemName': itemName,
              'Details': [],
            };
          }

          // Add details to the item
          groupedData[idPlace]['Zones'][idZone]['Items'][idItem]['Details'].add({
            'DetailsName': detailsName,
            'Details': detailsValue,
          });
        }

        setState(() {
          places = groupedData.values.toList();
          filteredPlaces = places;
          print(filteredPlaces); // Initialize filteredPlaces with all places
        });
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use MyAppBar here
      appBar: MyAppBar(
        title: 'Locais',
        icon: 'Drawer', // Use 'Drawer' to show the drawer icon
      ),
      drawer: AppDrawer(), // Include the drawer
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    filteredPlaces = places.where((place) => place['PlaceName'].toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
              ),
            ),
            // List of Places
            Expanded(
              child: places == null
                  ? Center(child: CupertinoActivityIndicator()) // Show loading indicator
                  : filteredPlaces.isEmpty
                      ? Center(
                          child: Text(
                            "No places found.",
                            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 20),
                          ),
                        ) // Show message if no places match the search
                      : ListView.builder(
                          itemCount: filteredPlaces.length,
                          itemBuilder: (context, placeIndex) {
                            var place = filteredPlaces[placeIndex];
                            return CupertinoListSection(
                              header: Text(
                                place['PlaceName'] ?? 'Unknown Place',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: [
                                // List of Zones in the Place
                                ...place['Zones'].entries.map((zoneEntry) {
                                  var zone = zoneEntry.value;
                                  return CupertinoListSection.insetGrouped(
                                    header: Text(
                                      zone['ZoneName'] ?? 'Unknown Zone',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    children: [
                                      // List of Items in the Zone
                                      ...zone['Items'].entries.map((itemEntry) {
                                        var item = itemEntry.value;
                                        return CupertinoListTile(
                                          title: Text(item['ItemName'] ?? 'Unknown Item', style: TextStyle(fontSize: 14)),
                                          subtitle: Text(
                                            "ID: ${item['IdItem']}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          trailing: Icon(CupertinoIcons.chevron_forward),
                                          onTap: () {
                                            // Show details in a modal
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoActionSheet(
                                                  title: Text(item['ItemName'] ?? 'Unknown Item'),
                                                  message: Text(
                                                    "ID: ${item['IdItem']}\n\nDetails:",
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                  actions: [
                                                    ...item['Details'].map((detail) {
                                                      return CupertinoActionSheetAction(
                                                        child: Text(
                                                          "${detail['DetailsName']}: ${detail['Details']}",
                                                          style: TextStyle(fontSize: 12),
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
                                    ],
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
