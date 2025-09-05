import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/places/addZones/addZonesController.dart';
import 'package:roominventory/pages/places/addZones/addZonesWidgets.dart';

/// A page for adding new zones to the room inventory system.
///
/// This page provides a form interface for users to create and save new zones
/// (sub-locations or areas within places) to the inventory. It features a
/// Cupertino-style interface with a navigation bar, text input field, and
/// save functionality with error handling.
///
/// The page manages its state using [AddZoneController] for form validation
/// and API communication, and displays appropriate widgets from [addZonesWidgets].
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => AddZonePage()),
/// ).then((success) {
///   if (success == true) {
///     // Zone was added successfully, refresh zones list
///   }
/// });
/// ```
class AddZonePage extends StatefulWidget {
  @override
  _AddZonePageState createState() => _AddZonePageState();
}

/// The state class for [AddZonePage], managing the add zone form and operations.
///
/// This state class handles:
/// - Controller initialization and disposal
/// - Save operation execution with error handling
/// - Navigation results and user feedback
/// - UI building with proper state management
class _AddZonePageState extends State<AddZonePage> {
  /// Controller responsible for form validation, API communication, and state management.
  ///
  /// Handles:
  /// - Text input control for zone name
  /// - Form validation logic
  /// - API calls to save zones
  /// - Loading state management
  /// - Error message storage
  final AddZoneController _controller = AddZoneController();

  @override
  void dispose() {
    /// Cleans up resources when the page is disposed.
    ///
    /// Ensures the controller is properly disposed to prevent memory leaks.
    /// Always call super.dispose() after disposing controllers.
    _controller.dispose();
    super.dispose();
  }

  /// Attempts to save the zone to the backend API and handles the result.
  ///
  /// This method:
  /// 1. Calls the controller's [AddZoneController.saveZone] method
  /// 2. Handles the success case by popping the navigation stack with `true`
  /// 3. Handles the error case by showing a Cupertino-style error dialog
  ///    with the error message from the controller
  ///
  /// Returns:
  /// - `Future<void>` that completes when the save operation finishes
  ///
  /// Navigation Behavior:
  /// - On success: Pops the current route with `true` as result
  /// - On failure: Shows error dialog and remains on current page
  ///
  /// Error Handling:
  /// - Displays a [CupertinoAlertDialog] with the error message
  /// - Allows user to acknowledge the error and continue editing
  Future<void> _saveZone() async {
    bool success = await _controller.saveZone();

    if (success) {
      Navigator.pop(context, true);
    } else {
      // Show error message if needed
      // You could add a dialog here to show the error message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(_controller.errorMessage),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the add zone page interface with Cupertino design principles.
    ///
    /// Returns a [CupertinoPageScaffold] containing:
    /// - Navigation bar with title and dynamic save button
    /// - Safe area padding for proper iOS-style layout
    /// - Form for entering zone name
    ///
    /// The save button dynamically shows loading state and enables/disables
    /// based on the controller's isLoading property.
    return CupertinoPageScaffold(
      /// Navigation bar with page title and trailing save button
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add New Zone'),
        trailing: SaveButton(
          isLoading: _controller.isLoading,
          onSave: _saveZone,
        ),
      ),

      /// Main content area with form inside safe area
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZoneForm(controller: _controller.nameController),
        ),
      ),
    );
  }
}
