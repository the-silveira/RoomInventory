import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roominventory/services/supabase_service.dart';

class PlacesController {
  dynamic places;
  dynamic filteredPlaces = [];
  bool isLoading = true;
  String errorMessage = '';

  Future fetchData() async {
    try {
      isLoading = true;
      errorMessage = '';

      final rawData = await SupabaseService.getItemsWithDetailsHierarchical();

      // O RPC devolve jsonb_agg que é sempre um array JSON = List<dynamic>
      places = (rawData as List<dynamic>?) ?? [];
      filteredPlaces = places ?? [];
    } catch (e) {
      errorMessage = 'Connection error: \$e';
      places = [];
      filteredPlaces = [];
    } finally {
      isLoading = false;
    }
  }

  void filterPlaces(String query) {
    if (places == null || places!.isEmpty) {
      filteredPlaces = [];
      return;
    }
    if (query.isEmpty) {
      filteredPlaces = places;
      return;
    }

    filteredPlaces = places
        .map((place) {
          var filteredZones = place['Zones']
              ?.entries
              .map((zoneEntry) {
                var zone = zoneEntry.value;
                var filteredItems = zone['Items']?.entries.where((itemEntry) {
                  var item = itemEntry.value;
                  return (item['ItemName'] ?? '')
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      (item['IdItem'] ?? '')
                          .toLowerCase()
                          .contains(query.toLowerCase());
                }).toList();

                if ((zone['ZoneName'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase())) {
                  filteredItems = zone['Items']?.entries.toList();
                }

                if (filteredItems != null && filteredItems.isNotEmpty) {
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

          var filteredZonesMap = Map.fromEntries(
              filteredZones?.cast<MapEntry<String, dynamic>>() ?? []);

          if ((place['PlaceName'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase())) {
            filteredZonesMap = place['Zones'] ?? {};
          }

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
