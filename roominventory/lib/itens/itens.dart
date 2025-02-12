import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roominventory/appbar/appbar.dart';
import 'package:roominventory/drawer/drawer.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  // Variable to store the list of items
  dynamic items;
  List<dynamic> filteredItems = []; // For search functionality
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
      // Fetch item details for this event
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I1'},
      );

      if (response.statusCode == 200) {
        List<dynamic> rawItems = json.decode(response.body);

        // Group the details by IdItem
        Map<String, Map<String, dynamic>> groupedItems = {};

        for (var row in rawItems) {
          String idItem = row['IdItem'];
          String detailsName = row['DetailsName'];
          String detailValue = row['Details'];

          if (!groupedItems.containsKey(idItem)) {
            groupedItems[idItem] = {
              'IdItem': idItem,
              'ItemName': row['ItemName'],
              'ZoneName': row['ZoneName'],
              'PlaceName': row['PlaceName'],
              'DetailsList': [],
            };
          }

          // Add details to the item
          groupedItems[idItem]!['DetailsList'].add({
            'DetailsName': detailsName,
            'Details': detailValue,
          });
        }

        setState(() {
          items = groupedItems.values.toList();
          filteredItems = items; // Initialize filteredItems with all items
        });
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Function to filter items based on search query
  void _filterItems(String query) {
    setState(() {
      filteredItems = items.where((item) => item['IdItem'].toLowerCase().contains(query.toLowerCase()) || item['IdItem'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Itens', icon: "Drawer"),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.black,
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(CupertinoIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),

              onChanged: _filterItems, // Filter items as the user types
            ),
          ),
          // List of Items
          Expanded(
            child: items == null
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : filteredItems.isEmpty
                    ? Center(child: Text("No items found.")) // Show message if no items match the search
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          var item = filteredItems[index];

                          return ExpansionTile(
                            title: Text(
                              item['ItemName'] ?? 'Unknown Item',
                              textAlign: TextAlign.left,
                            ),
                            subtitle: Text(
                              "ID: ${item['IdItem']}",
                              textAlign: TextAlign.left,
                            ),
                            leading: Icon(
                              CupertinoIcons.cube_box,
                              color: Colors.blue,
                            ),
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (item['DetailsList'] as List<dynamic>)
                                      .map<Widget>(
                                        (detail) => Text(
                                          "${detail['DetailsName']}: ${detail['Details']}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                title: Text(
                                  "Localização: ${item['PlaceName']}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15),
                                ),
                                subtitle: Text(
                                  "Zona: ${item['ZoneName']}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
