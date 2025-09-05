import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DatePickerDialog;
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/items/addItem/addItemController.dart';
import 'package:roominventory/pages/items/addItem/addItemWidgets.dart';

/// A page for adding new inventory items to the system.
///
/// This page provides a comprehensive form for creating new inventory items with:
/// - Basic item information (ID, name)
/// - Location selection (place and zone)
/// - Static detail fields (brand, type, quantity, condition, size, verification date)
/// - Dynamic custom detail fields
/// - Validation and error handling
///
/// The page uses an [AddItemController] to manage form state and operations
/// and [addItemWidgets] for UI components.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => AddItemPage()),
/// );
/// ```
class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

/// The state class for [AddItemPage] that manages the item creation form and operations.
///
/// This state class handles:
/// - Controller initialization and cleanup
/// - Data loading for places and zones
/// - Picker dialog management
/// - Dynamic input field management
/// - Save operations and result handling
/// - Navigation and user feedback
class _AddItemPageState extends State<AddItemPage> {
  /// Controller responsible for managing form state and item operations
  final AddItemController _controller = AddItemController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Loads places and zones data when the widget is initialized
  ///
  /// This method is called automatically when the state is created.
  /// It triggers the controller to fetch places and zones data.
  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  /// Shows a modal dialog for selecting a place
  ///
  /// Displays a Cupertino-style action sheet with available places
  /// and updates the selected place and filtered zones when a place is chosen.
  void _showPlacePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => PlacePickerDialog(
        controller: _controller,
        onSelected: (index) {
          setState(() {
            _controller.selectedPlace = _controller.places[index]['IdPlace'];
            _controller.filterZones(_controller.selectedPlace);
          });
        },
      ),
    );
  }

  /// Shows a modal dialog for selecting a zone
  ///
  /// Displays a Cupertino-style action sheet with zones filtered by
  /// the selected place and updates the selected zone.
  void _showZonePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ZonePickerDialog(
        controller: _controller,
        onSelected: (index) {
          setState(() {
            _controller.selectedZone =
                _controller.filteredZones[index]['IdZone'];
          });
        },
      ),
    );
  }

  /// Shows a modal dialog for selecting a verification date
  ///
  /// Displays a Cupertino-style date picker for selecting the
  /// last verification date of the item.
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DatePickerDialog(
        controller: _controller,
        onDateChanged: (DateTime newDate) {
          setState(() {
            _controller.ultimaVerificacaoDate = newDate;
          });
        },
      ),
    );
  }

  /// Adds a new dynamic input field for custom details
  ///
  /// Triggers the controller to create a new dynamic input field
  /// and updates the UI to display the new field.
  void _addDynamicInput() {
    setState(() {
      _controller.addDynamicInput();
    });
  }

  /// Removes a dynamic input field
  ///
  /// Removes the dynamic input field at the specified index
  /// and updates the UI accordingly.
  ///
  /// [index]: The index of the dynamic input to remove
  void _removeDynamicInput(int index) {
    setState(() {
      _controller.removeDynamicInput(index);
    });
  }

  /// Saves the item with all details to the database
  ///
  /// This method:
  /// 1. Calls the controller's saveItem method
  /// 2. Shows a success message and navigates back if successful
  /// 3. Shows an error message if the operation fails
  Future<void> _saveItem() async {
    bool success = await _controller.saveItem();

    if (success) {
      _showMessage('Sucesso', 'Item Guardado com Sucesso', shouldPop: true);
    } else {
      _showMessage('Erro', _controller.errorMessage);
    }
  }

  /// Shows a message dialog with custom title and message
  ///
  /// Displays a Cupertino-style alert dialog that can optionally
  /// navigate back when dismissed.
  ///
  /// [title]: The title of the message dialog
  /// [message]: The message content to display
  /// [shouldPop]: Whether to navigate back after dismissing the dialog
  void _showMessage(String title, String message, {bool shouldPop = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        onOk: () {},
        shouldPop: shouldPop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      /// Custom navigation bar with save functionality
      navigationBar: AddNavigationBar(
        title: 'Novo Item',
        previousPageTitle: 'Inventário',
        onAddPressed: _saveItem,
      ),
      child: SafeArea(
        child: _controller.isLoading
            ? Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    /// Basic item information section
                    ItemInformationSection(controller: _controller),
                    
                    /// Location selection section
                    LocationSection(
                      controller: _controller,
                      onShowPlacePicker: _showPlacePicker,
                      onShowZonePicker: _showZonePicker,
                    ),
                    
                    /// Details section with static and dynamic fields
                    DetailsSection(
                      controller: _controller,
                      onShowDatePicker: _showDatePicker,
                      onAddDynamicInput: _addDynamicInput,
                      onRemoveDynamicInput: _removeDynamicInput,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}