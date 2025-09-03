import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesController {
  dynamic places;
  dynamic filteredPlaces = [];
  bool isLoading = true;
  String errorMessage = '';

  // Fetch places data
  Future<void> fetchData() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
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

          if (!groupedData[idPlace]['Zones'][idZone]['Items']
              .containsKey(idItem)) {
            groupedData[idPlace]['Zones'][idZone]['Items'][idItem] = {
              'IdItem': idItem,
              'ItemName': itemName,
              'Details': [],
            };
          }

          groupedData[idPlace]['Zones'][idZone]['Items'][idItem]['Details']
              .add({
            'DetailsName': detailsName,
            'Details': detailsValue,
          });
        }

        places = groupedData.values.toList();
        filteredPlaces = places;
      } else {
        errorMessage = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  // Filter places based on search query
  void filterPlaces(String query) {
    if (query.isEmpty) {
      filteredPlaces = places;
      return;
    }

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
                  return item['ItemName']
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      item['IdItem']
                          .toLowerCase()
                          .contains(query.toLowerCase());
                }).toList();

                // Check if the search query matches ZoneName
                if (zone['ZoneName']
                    .toLowerCase()
                    .contains(query.toLowerCase())) {
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

          // Cast filteredZones to List<MapEntry<dynamic, dynamic>>
          var filteredZonesMap =
              Map.fromEntries(filteredZones.cast<MapEntry<dynamic, dynamic>>());

          // Check if the search query matches PlaceName
          if (place['PlaceName'].toLowerCase().contains(query.toLowerCase())) {
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
}
