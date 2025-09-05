import 'dart:convert';
import 'package:http/http.dart' as http;

/// A controller class for managing places data fetching, processing, and filtering.
///
/// This controller handles:
/// - Fetching hierarchical place-zone-item data from a REST API
/// - Processing raw API response into a structured hierarchical format
/// - Filtering data based on search queries across multiple levels
/// - Managing loading states and error handling
///
/// The controller transforms flat API data into a nested structure:
/// Places → Zones → Items → Details
///
/// Example usage:
/// ```dart
/// final placesController = PlacesController();
/// await placesController.fetchData();
///
/// // Filter places based on search query
/// placesController.filterPlaces('search query');
///
/// // Access filtered data
/// print(placesController.filteredPlaces);
/// ```
class PlacesController {
  /// The complete hierarchical list of places with their zones and items.
  ///
  /// Structure:
  /// ```dart
  /// [
  ///   {
  ///     'PlaceName': 'Place 1',
  ///     'Zones': {
  ///       'zoneId1': {
  ///         'ZoneName': 'Zone 1',
  ///         'Items': {
  ///           'itemId1': {
  ///             'IdItem': 'itemId1',
  ///             'ItemName': 'Item 1',
  ///             'Details': [
  ///               {'DetailsName': 'Detail 1', 'Details': 'Value 1'},
  ///               {'DetailsName': 'Detail 2', 'Details': 'Value 2'}
  ///             ]
  ///           }
  ///         }
  ///       }
  ///     }
  ///   }
  /// ]
  /// ```
  dynamic places;

  /// The filtered list of places based on search queries.
  ///
  /// Contains the same hierarchical structure as [places] but only includes
  /// places, zones, and items that match the current search filter.
  /// Initially contains all places until a filter is applied.
  dynamic filteredPlaces = [];

  /// Indicates whether data is currently being fetched from the API.
  ///
  /// When `true`, the UI should show a loading indicator.
  /// Automatically set to `false` when data fetching completes (successfully or not).
  bool isLoading = true;

  /// Stores error messages from API calls or data processing.
  ///
  /// Contains user-friendly error messages. Empty string indicates no errors.
  /// Updated during [fetchData] operation.
  String errorMessage = '';

  /// Fetches and processes places data from the remote API.
  ///
  /// Performs the following operations:
  /// 1. Sends POST request to the API endpoint with query parameter 'P2'
  /// 2. Processes the flat API response into hierarchical structure
  /// 3. Handles HTTP errors and exceptions
  /// 4. Updates loading state and error messages
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// Query Parameter: `query_param = 'P2'`
  ///
  /// Expected API Response Structure (flat):
  /// ```json
  /// [
  ///   {
  ///     "IdPlace": "1",
  ///     "PlaceName": "Office",
  ///     "IdZone": "1",
  ///     "ZoneName": "Reception",
  ///     "IdItem": "1",
  ///     "ItemName": "Computer",
  ///     "DetailsName": "Serial Number",
  ///     "Details": "SN12345"
  ///   }
  /// ]
  /// ```
  ///
  /// Transforms to hierarchical structure:
  /// Places → Zones → Items → Details
  ///
  /// Throws:
  /// - HTTP exceptions for network errors
  /// - JSON decoding exceptions for malformed responses
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.fetchData();
  ///   if (controller.errorMessage.isNotEmpty) {
  ///     // Handle error
  ///   }
  /// } catch (e) {
  ///   // Handle exception
  /// }
  /// ```
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

  /// Filters the places data based on a search query across multiple hierarchy levels.
  ///
  /// The search query is matched against:
  /// - Place names (PlaceName)
  /// - Zone names (ZoneName)
  /// - Item names (ItemName)
  /// - Item IDs (IdItem)
  ///
  /// Filtering logic:
  /// 1. If a place matches the query, all its zones and items are included
  /// 2. If a zone matches the query, all items in that zone are included
  /// 3. If an item matches the query, only that specific item is included
  /// 4. Empty query resets the filter to show all data
  ///
  /// The filtering is case-insensitive.
  ///
  /// Parameters:
  /// - [query]: The search string to filter by. Empty string shows all data.
  ///
  /// Example:
  /// ```dart
  /// // Filter for items containing "computer"
  /// controller.filterPlaces('computer');
  ///
  /// // Filter for places containing "office"
  /// controller.filterPlaces('office');
  ///
  /// // Reset to show all data
  /// controller.filterPlaces('');
  /// ```
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
