import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/places/addPlaces/addPlacesController.dart';
import 'package:roominventory/pages/places/addPlaces/addPlacesWidgets.dart';

/// A page for adding new places to the room inventory system.
///
/// This page provides a form interface for users to create and save new places
/// (locations) to the inventory. It features a Cupertino-style interface with
/// a navigation bar, text input field, and save functionality.
///
/// The page manages its state using [AddPlaceController] for form validation
/// and API communication, and displays appropriate widgets from [addPlacesWidgets].
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => AddPlacePage()),
/// ).then((success) {
///   if (success == true) {
///     // Place was added successfully
///   }
/// });
/// ```
class AddPlacePage extends StatefulWidget {
  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

/// The state class for [AddPlacePage], managing the add place form and operations.
///
/// This state class handles:
/// - Controller initialization and disposal
/// - Save operation execution
/// - Navigation results
/// - UI building with proper error handling
class _AddPlacePageState extends State<AddPlacePage> {
  /// Controller responsible for form validation, API communication, and state management.
  final AddPlaceController _controller = AddPlaceController();

  @override
  void dispose() {
    /// Cleans up resources when the page is disposed.
    ///
    /// Ensures the controller is properly disposed to prevent memory leaks.
    /// Always call super.dispose() after disposing controllers.
    _controller.dispose();
    super.dispose();
  }

  /// Attempts to save the place to the backend API.
  ///
  /// This method:
  /// 1. Calls the controller's savePlace method
  /// 2. Handles the success case by popping the navigation stack with `true`
  /// 3. Handles the error case by potentially showing error messages
  ///
  /// Returns:
  /// - `Future<void>` that completes when the save operation finishes
  ///
  /// Navigation:
  /// - On success: Pops the current route with `true` as result
  /// - On failure: Stays on current page (error handling can be added)
  ///
  /// Example error handling extension:
  /// ```dart
  /// if (!success) {
  ///   showCupertinoDialog(
  ///     context: context,
  ///     builder: (context) => CupertinoAlertDialog(
  ///       title: Text('Error'),
  ///       content: Text(_controller.errorMessage),
  ///       actions: [CupertinoDialogAction(child: Text('OK'), onPressed: () => Navigator.pop(context))],
  ///     ),
  ///   );
  /// }
  /// ```
  Future<void> _savePlace() async {
    bool success = await _controller.savePlace();

    if (success) {
      Navigator.pop(context, true);
    } else {
      // Show error message if needed
      // You could add a dialog here to show the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the add place page interface.
    ///
    /// Returns a [CupertinoPageScaffold] with:
    /// - Navigation bar containing title and save button
    /// - Safe area padding
    /// - Form for entering place name
    ///
    /// The layout uses Cupertino design principles for iOS-style appearance.
    return CupertinoPageScaffold(
      /// Navigation bar with page title and trailing save button
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add New Place'),
        trailing: SaveButton(
          isLoading: _controller.isLoading,
          onSave: _savePlace,
        ),
      ),

      /// Main content area with form
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlaceForm(controller: _controller.nameController),
        ),
      ),
    );
  }
}
