import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roominventory/appbar/appbar_back.dart';

class AssociateItemsPage extends StatefulWidget {
  final String eventId;

  AssociateItemsPage({required this.eventId});

  @override
  _AssociateItemsPageState createState() => _AssociateItemsPageState();
}

class _AssociateItemsPageState extends State<AssociateItemsPage> {
  List<dynamic> allItems = []; // List of all available items
  List<dynamic> filteredItems = []; // List of filtered items based on search
  List<dynamic> selectedItems = []; // List of selected items to associate
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    _fetchAllItems();
  }

  // Fetch all available items from the API
  Future<void> _fetchAllItems() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'I4', 'IdEvent': widget.eventId}, // Assuming 'I1' fetches all items
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          allItems = json.decode(response.body);
          filteredItems = allItems; // Initialize filtered list with all items
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load items';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to filter items based on search query
  void _filterItems(String query) {
    setState(() {
      filteredItems = allItems.where((item) {
        return item['ItemName'].toLowerCase().contains(query.toLowerCase()) || item['IdItem'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Function to associate selected items with the event
  Future<void> _associateItems() async {
    if (selectedItems.isEmpty) {
      setState(() {
        errorMessage = 'Please select at least one item';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });
    print(json.encode(selectedItems));

    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E4', // Assuming 'E3' associates items with an event
          'IdEvent': widget.eventId,
          'Items': json.encode(selectedItems), // Send selected items as JSON
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Items associated successfully!')),
          );
          Navigator.pop(context); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to associate items: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AddNavigationBar(
        title: 'Associate Items',
        previousPageTitle: 'Event Details',
        onAddPressed: _associateItems,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              CupertinoSearchTextField(
                controller: searchController,
                onChanged: _filterItems,
                placeholder: 'Search items...',
              ),
              SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 14,
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No items available',
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              var item = filteredItems[index];
                              return CupertinoListTile(
                                title: Text(
                                  item['ItemName'] ?? 'Unknown Item',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  "ID: ${item['IdItem']}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                trailing: CupertinoCheckbox(
                                  value: selectedItems.contains(item),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedItems.add(item);
                                      } else {
                                        selectedItems.remove(item);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
