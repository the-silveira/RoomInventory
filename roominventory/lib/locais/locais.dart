import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../appbar/appbar.dart';
import '../drawer/drawer.dart';

class LocaisPage extends StatefulWidget {
  @override
  _LocaisPageState createState() => _LocaisPageState();
}

class _LocaisPageState extends State<LocaisPage> {
  dynamic places;
  dynamic filteredPlaces = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'P2'},
      );

      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);
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

          if (!groupedData.containsKey(idPlace)) {
            groupedData[idPlace] = {
              'PlaceName': placeName,
              'Zones': {},
            };
          }

          if (!groupedData[idPlace]['Zones'].containsKey(idZone)) {
            groupedData[idPlace]['Zones'][idZone] = {
              'ZoneName': zoneName,
              'Items': {},
            };
          }

          if (!groupedData[idPlace]['Zones'][idZone]['Items'].containsKey(idItem)) {
            groupedData[idPlace]['Zones'][idZone]['Items'][idItem] = {
              'IdItem': idItem,
              'ItemName': itemName,
              'Details': [],
            };
          }

          groupedData[idPlace]['Zones'][idZone]['Items'][idItem]['Details'].add({
            'DetailsName': detailsName,
            'Details': detailsValue,
          });
        }

        setState(() {
          places = groupedData.values.toList();
          filteredPlaces = places;
        });
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Locais',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // If the search query is empty, show all places
                      filteredPlaces = places;
                    } else {
                      // Filter places based on the search query
                      filteredPlaces = places
                          .map((place) {
                            // Filter zones within the place
                            var filteredZones = place['Zones']
                                .entries
                                .map((zoneEntry) {
                                  var zone = zoneEntry.value;

                                  // Filter items within the zone
                                  var filteredItems = zone['Items'].entries.where((itemEntry) {
                                    var item = itemEntry.value;

                                    // Check if the search query matches ItemName or IdItem
                                    return item['ItemName'].toLowerCase().contains(value.toLowerCase()) || item['IdItem'].toLowerCase().contains(value.toLowerCase());
                                  }).toList();

                                  // Check if the search query matches ZoneName
                                  if (zone['ZoneName'].toLowerCase().contains(value.toLowerCase())) {
                                    // Include all items in the zone if the zone matches
                                    filteredItems = zone['Items'].entries.toList();
                                  }

                                  // Return the zone only if it has matching items or its name matches
                                  if (filteredItems.isNotEmpty) {
                                    return MapEntry(
                                      zoneEntry.key,
                                      {
                                        ...zone,
                                        'Items': Map.fromEntries(filteredItems),
                                      },
                                    );
                                  }
                                  return null;
                                })
                                .where((zone) => zone != null)
                                .toList();

                            // Explicitly cast filteredZones to List<MapEntry<dynamic, dynamic>>
                            var filteredZonesMap = Map.fromEntries(filteredZones.cast<MapEntry<dynamic, dynamic>>());

                            // Check if the search query matches PlaceName
                            if (place['PlaceName'].toLowerCase().contains(value.toLowerCase())) {
                              // Include all zones in the place if the place matches
                              filteredZonesMap = place['Zones'];
                            }

                            // Return the place only if it has matching zones or its name matches
                            if (filteredZonesMap.isNotEmpty) {
                              return {
                                ...place,
                                'Zones': filteredZonesMap,
                              };
                            }
                            return null;
                          })
                          .where((place) => place != null)
                          .toList();
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: places == null
                  ? Center(child: CupertinoActivityIndicator())
                  : filteredPlaces.isEmpty
                      ? Center(
                          child: Text(
                            "No items found.",
                            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredPlaces.length,
                          itemBuilder: (context, placeIndex) {
                            var place = filteredPlaces[placeIndex];
                            return CupertinoListSection(
                              header: Text(
                                place['PlaceName'] ?? 'Unknown Place',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              children: [
                                ...place['Zones'].entries.map((zoneEntry) {
                                  var zone = zoneEntry.value;
                                  return CupertinoListSection.insetGrouped(
                                    header: Text(
                                      zone['ZoneName'] ?? 'Unknown Zone',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                    children: [
                                      ...zone['Items'].entries.map((itemEntry) {
                                        var item = itemEntry.value;
                                        return CupertinoListTile(
                                          title: Text(item['ItemName'] ?? 'Unknown Item', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                          subtitle: Text(
                                            "ID: ${item['IdItem']}",
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                                          ),
                                          trailing: Icon(CupertinoIcons.chevron_forward),
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
