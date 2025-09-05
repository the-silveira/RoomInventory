import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsController.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsWidgets.dart';

/// A page for creating and adding new events to the system.
///
/// This page provides a form interface for users to create new events with
/// comprehensive details including event name, location, representative information,
/// and date selection. It integrates with the [AddEventController] for business logic
/// and validation.
///
/// The page features:
/// - A custom navigation bar with save functionality
/// - Form validation and error handling
/// - Date picker integration
/// - API communication for event persistence
/// - User feedback through snackbars
///
/// Route: Typically accessed from the events list page
/// Layout: Uses Cupertino-style widgets for iOS consistency
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => AddEventPage()),
/// );
/// ```
class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

/// The state class for [AddEventPage] that manages the UI and event creation logic.
///
/// This state handles:
/// - Controller initialization and disposal
/// - Form submission and validation
/// - User feedback through snackbars
/// - Navigation back to previous pages
/// - Error state management
///
/// The state maintains a reference to [AddEventController] which handles
/// the business logic, form validation, and API communications.
class _AddEventPageState extends State<AddEventPage> {
  /// Controller instance that manages event creation business logic
  ///
  /// Handles form validation, API communication, and state management
  /// for the event creation process.
  final AddEventController _controller = AddEventController();

  @override
  void dispose() {
    /// Cleans up resources when the page is disposed
    ///
    /// Ensures proper disposal of all TextEditingControllers and other
    /// resources managed by the controller to prevent memory leaks.
    _controller.dispose();
    super.dispose();
  }

  /// Attempts to save the event using the controller and handles the result.
  ///
  /// This method:
  /// 1. Calls the controller's [saveEvent] method to validate and persist the event
  /// 2. Displays appropriate success or error messages to the user
  /// 3. Navigates back to the previous page on successful creation
  /// 4. Updates the UI state to reflect error messages on failure
  ///
  /// Returns:
  ///   - A Future that completes when the save operation is finished
  ///
  /// UI Effects:
  ///   - Shows success snackbar and navigates back on success
  ///   - Shows error snackbar and refreshes UI on failure
  Future<void> _saveItem() async {
    bool success = await _controller.saveEvent();

    if (success) {
      // Show success message and return to previous page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!')),
      );
      Navigator.pop(context);
    } else {
      // Show error message and refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_controller.errorMessage ?? 'Failed to add event')),
      );
      setState(() {}); // Refresh to show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      /// Custom navigation bar with back button and save action
      ///
      /// The navigation bar includes:
      /// - Title: 'Novo Evento' (New Event)
      /// - Back button with 'Eventos' (Events) as previous page title
      /// - Save button that triggers the _saveItem method
      navigationBar: AddNavigationBar(
        title: 'Novo Evento',
        previousPageTitle: 'Eventos',
        onAddPressed: _saveItem,
      ),

      /// Main content area with form and error display
      ///
      /// Uses SafeArea to avoid system UI overlaps and provides
      /// padding and scrolling for the form content.
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Error message display component
                ///
                /// Shows validation errors or API error messages
                /// from the controller. Hidden when no errors are present.
                ErrorMessage(message: _controller.errorMessage ?? ''),

                /// Event form component
                ///
                /// Contains all input fields for event creation:
                /// - Event name, place, representative details
                /// - Date picker and technical extension fields
                /// - Form validation and user input handling
                EventForm(controller: _controller, context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
