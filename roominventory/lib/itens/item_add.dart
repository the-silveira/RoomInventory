import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  AddItemPage({
    Key? key,
  }) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _itemController = TextEditingController();
  String? _selectedZoneId; // Selected zone ID from the dropdown

  // List to store multiple details
  final List<Map<String, String>> _detailsList = [];

  // Controllers for the current detail input
  final TextEditingController _detailsNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Item'),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Item Name Input
              CupertinoTextField(
                controller: _itemController,
                placeholder: 'Enter item name',
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 20),

              // Zone Selection Dropdown
              CupertinoSlidingSegmentedControl<String>(
                groupValue: _selectedZoneId,
                children: {
                  for (var zone in widget.zones) zone.idZone: Text(zone.zoneName),
                },
                onValueChanged: (value) {
                  setState(() {
                    _selectedZoneId = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Details Section
              Text(
                'Item Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Input for a single detail
              CupertinoTextField(
                controller: _detailsNameController,
                placeholder: 'Enter detail name (e.g., Color, Size)',
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: _detailsController,
                placeholder: 'Enter detail value (e.g., Red, Large)',
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 10),

              // Button to add the current detail to the list
              CupertinoButton(
                child: Text('Add Detail'),
                onPressed: () {
                  final detailsName = _detailsNameController.text.trim();
                  final detailsValue = _detailsController.text.trim();

                  if (detailsName.isNotEmpty && detailsValue.isNotEmpty) {
                    setState(() {
                      _detailsList.add({
                        'name': detailsName,
                        'value': detailsValue,
                      });
                      _detailsNameController.clear();
                      _detailsController.clear();
                    });
                  } else {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill both detail fields.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),

              // Display all added details
              if (_detailsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added Details:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    for (var detail in _detailsList) Text('${detail['name']}: ${detail['value']}'),
                  ],
                ),
              SizedBox(height: 20),

              // Add Item Button
              CupertinoButton.filled(
                child: Text('Add Item'),
                onPressed: () async {
                  final itemName = _itemController.text.trim();

                  if (itemName.isNotEmpty && _selectedZoneId != null && _detailsList.isNotEmpty) {
                    // Save the item and all details to the database
                    final result = await _saveItemAndDetailsToDatabase(
                      itemName: itemName,
                      zoneId: _selectedZoneId!,
                      detailsList: _detailsList,
                    );

                    if (result) {
                      // Return success to the previous page
                      Navigator.pop(context, true);
                    } else {
                      // Show an error if saving failed
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to save the item or details.'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    // Show an error if any field is empty
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill all fields and add at least one detail.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _saveItemAndDetailsToDatabase({
    required String itemName,
    required String zoneId,
    required List<Map<String, String>> detailsList,
  }) async {
    // Connect to the database
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'your_database_host',
      port: 3306,
      user: 'your_database_user',
      password: 'your_database_password',
      db: 'your_database_name',
    ));

    try {
      // Generate a unique ID for the item
      final itemId = Uuid().v4();

      // Insert the item into the Items table
      await conn.query(
        'INSERT INTO Items (IdItem, ItemName, FK_IdZone) VALUES (?, ?, ?)',
        [itemId, itemName, zoneId],
      );

      // Insert all details into the Details table
      for (var detail in detailsList) {
        await conn.query(
          'INSERT INTO Details (DetailsName, Details, FK_IdItem) VALUES (?, ?, ?)',
          [detail['name'], detail['value'], itemId],
        );
      }

      return true; // Success
    } catch (e) {
      print('Error saving item or details: $e');
      return false; // Failure
    } finally {
      await conn.close(); // Close the connection
    }
  }
}

// Zone model to represent a zone
class Zone {
  final String idZone;
  final String zoneName;

  Zone({required this.idZone, required this.zoneName});
}
