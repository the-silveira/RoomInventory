import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Controller class for managing event editing operations and form state.
///
/// This controller handles:
/// - Form field management with TextEditingControllers
/// - Date selection functionality
/// - Saving event changes to the server
/// - Error handling and user feedback
/// - Form state validation and management
///
/// The controller follows the typical MVC pattern by separating business logic
/// from the UI components and providing methods for form operations.
///
/// Example usage:
/// ```dart
/// final controller = editEventsController();
/// controller.initializeControllers(eventData);
/// ```
class editEventsController {
  /// Controller for the event name text field
  late TextEditingController eventNameController;

  /// Controller for the event place/location text field
  late TextEditingController eventPlaceController;

  /// Controller for the representative name text field
  late TextEditingController nameRepController;

  /// Controller for the representative email text field
  late TextEditingController emailRepController;

  /// Controller for the technical details text field
  late TextEditingController tecExtController;

  /// Controller for the event date text field (formatted as YYYY-MM-DD)
  late TextEditingController dateController;

  /// Indicates whether a save operation is currently in progress
  bool isSaving = false;

  /// Stores error messages from save operations or validation failures
  String errorMessage = '';

  /// Initializes all text editing controllers with values from an existing event.
  ///
  /// This method should be called when the controller is first set up to
  /// populate the form fields with existing event data.
  ///
  /// [event]: The event data to initialize the form with. Expected to contain:
  ///   - EventName
  ///   - EventPlace
  ///   - NameRep
  ///   - EmailRep
  ///   - TecExt
  ///   - Date (in YYYY-MM-DD format)
  ///
  /// Example:
  /// ```dart
  /// controller.initializeControllers(eventData);
  /// ```
  void initializeControllers(dynamic event) {
    eventNameController = TextEditingController(text: event['EventName']);
    eventPlaceController = TextEditingController(text: event['EventPlace']);
    nameRepController = TextEditingController(text: event['NameRep']);
    emailRepController = TextEditingController(text: event['EmailRep']);
    tecExtController = TextEditingController(text: event['TecExt']);
    dateController = TextEditingController(text: event['Date']);
  }

  /// Disposes of all text editing controllers to free up resources.
  ///
  /// This method should be called when the controller is no longer needed,
  /// typically in the dispose() method of the State class that uses this controller.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   controller.disposeControllers();
  ///   super.dispose();
  /// }
  /// ```
  void disposeControllers() {
    eventNameController.dispose();
    eventPlaceController.dispose();
    nameRepController.dispose();
    emailRepController.dispose();
    tecExtController.dispose();
    dateController.dispose();
  }

  /// Saves the edited event changes to the server.
  ///
  /// This method:
  /// 1. Sets the saving state to true and clears any previous errors
  /// 2. Sends a POST request to the server with the updated event data
  /// 3. Handles server responses and network errors
  /// 4. Returns true if the operation was successful, false otherwise
  ///
  /// [eventId]: The unique identifier of the event being edited
  /// Returns: [bool] indicating whether the save operation was successful
  ///
  /// Example:
  /// ```dart
  /// bool success = await controller.saveChanges('event123');
  /// if (success) {
  ///   // Navigate back or show success message
  /// }
  /// ```
  Future<bool> saveChanges(String eventId) async {
    isSaving = true;
    errorMessage = '';

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E7',
          'IdEvent': eventId,
          'EventName': eventNameController.text,
          'EventPlace': eventPlaceController.text,
          'NameRep': nameRepController.text,
          'EmailRep': emailRepController.text,
          'TecExt': tecExtController.text,
          'Date': dateController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['status'] == 'success';
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      isSaving = false;
    }
  }

  /// Shows a date picker dialog for selecting an event date.
  ///
  /// This method displays a Cupertino-style date picker modal that allows
  /// users to select a date. The selected date is automatically formatted
  /// and populated into the dateController.
  ///
  /// [context]: The BuildContext used to show the date picker modal
  ///
  /// Example:
  /// ```dart
  /// controller.selectDate(context);
  /// ```
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime initialDate;
        try {
          initialDate = DateTime.parse(dateController.text);
        } catch (e) {
          initialDate = DateTime.now();
        }

        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.pop(
                          context, DateTime.parse(dateController.text));
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(newDate);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// Displays an error dialog with a custom message.
  ///
  /// This method shows a Cupertino-style alert dialog that can be used
  /// to inform users about errors that occurred during form operations.
  ///
  /// [context]: The BuildContext used to show the error dialog
  /// [message]: The error message to display to the user
  ///
  /// Example:
  /// ```dart
  /// controller.showError(context, 'Failed to save event');
  /// ```
  void showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
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
