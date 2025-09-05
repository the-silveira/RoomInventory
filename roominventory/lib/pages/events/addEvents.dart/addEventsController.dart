import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Controller class for managing event creation and form handling.
///
/// This controller handles all business logic for adding new events through a form interface.
/// It manages form validation, date selection, and API communication for event creation.
///
/// The controller follows the MVC pattern by separating business logic from UI components
/// and provides a clean interface for event management operations.
///
/// Features:
/// - Form field management with TextEditingControllers
/// - Comprehensive form validation
/// - Date selection and formatting
/// - API integration for event persistence
/// - Loading state management
/// - Error handling and message propagation
///
/// Example usage:
/// ```dart
/// final controller = AddEventController();
/// await controller.saveEvent();
/// ```
class AddEventController {
  /// Controller for the event ID input field
  ///
  /// Used to capture and manage the event identifier input.
  /// Typically contains a unique identifier for the event.
  final TextEditingController eventIdController = TextEditingController();

  /// Controller for the event name input field
  ///
  /// Used to capture and manage the event name input.
  /// This field is required for form validation.
  final TextEditingController eventNameController = TextEditingController();

  /// Controller for the event place input field
  ///
  /// Used to capture and manage the event location input.
  /// This field is required for form validation.
  final TextEditingController eventPlaceController = TextEditingController();

  /// Controller for the representative name input field
  ///
  /// Used to capture and manage the event representative's name.
  /// This field is required for form validation.
  final TextEditingController nameRepController = TextEditingController();

  /// Controller for the representative email input field
  ///
  /// Used to capture and manage the event representative's email address.
  /// This field is required for form validation.
  final TextEditingController emailRepController = TextEditingController();

  /// Controller for the technical extension input field
  ///
  /// Used to capture and manage technical extension information.
  /// This field is optional for form validation.
  final TextEditingController tecExtController = TextEditingController();

  /// Controller for the event date input field
  ///
  /// Used to capture and manage the event date selection.
  /// This field is required for form validation and uses date formatting.
  final TextEditingController dateController = TextEditingController();

  /// The currently selected date for the event
  ///
  /// Stores the DateTime object representing the selected event date.
  /// Used for date formatting and validation purposes.
  DateTime? selectedDate;

  /// Loading state indicator for asynchronous operations
  ///
  /// Set to `true` during API calls and `false` when operations complete.
  /// Used to show loading indicators in the UI.
  bool isLoading = false;

  /// Error message for operation failures
  ///
  /// Contains descriptive error messages for form validation failures
  /// or API communication errors. Null when no errors are present.
  String? errorMessage;

  /// Validates all form fields and sets appropriate error messages.
  ///
  /// Performs comprehensive validation on all required form fields:
  /// - Event name (required)
  /// - Event place (required)
  /// - Representative name (required)
  /// - Representative email (required)
  /// - Event date (required)
  ///
  /// Returns:
  ///   - `true` if all required fields are valid and complete
  ///   - `false` if any validation checks fail
  ///
  /// Side effects:
  ///   - Sets [errorMessage] with descriptive text when validation fails
  ///   - Clears [errorMessage] when validation passes
  bool validateForm() {
    // Validate event name
    if (eventNameController.text.isEmpty) {
      errorMessage = 'Please enter the event name';
      return false;
    }

    // Validate event place
    if (eventPlaceController.text.isEmpty) {
      errorMessage = 'Please enter the event place';
      return false;
    }

    // Validate representative name
    if (nameRepController.text.isEmpty) {
      errorMessage = 'Please enter the representative name';
      return false;
    }

    // Validate representative email
    if (emailRepController.text.isEmpty) {
      errorMessage = 'Please enter the representative email';
      return false;
    }

    // Validate event date
    if (dateController.text.isEmpty) {
      errorMessage = 'Please enter the event date';
      return false;
    }

    // Clear any previous error message
    errorMessage = null;
    return true;
  }

  /// Submits the event form data to the API for persistence.
  ///
  /// This method:
  /// 1. Validates the form using [validateForm()]
  /// 2. Sets loading state and clears previous errors
  /// 3. Sends a POST request to the events API endpoint
  /// 4. Handles response parsing and error management
  /// 5. Resets loading state upon completion
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// API Parameter: `query_param = 'E3'` (Event creation endpoint)
  ///
  /// Returns:
  ///   - `true` if the event was successfully created and persisted
  ///   - `false` if the operation failed due to validation or API errors
  ///
  /// Throws:
  ///   - HttpException for network-related errors
  ///   - FormatException for JSON parsing errors
  ///   - Exception for other unexpected errors
  ///
  /// Side effects:
  ///   - Sets [isLoading] to true during API communication
  ///   - Sets [errorMessage] with descriptive text on failure
  ///   - Maintains form field state throughout the operation
  Future<bool> saveEvent() async {
    // Validate form before submission
    if (!validateForm()) return false;

    // Set loading state
    isLoading = true;
    errorMessage = null;

    try {
      // Make API request
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E3',
          'IdEvent': eventIdController.text,
          'EventName': eventNameController.text,
          'EventPlace': eventPlaceController.text,
          'NameRep': nameRepController.text,
          'EmailRep': emailRepController.text,
          'TecExt': tecExtController.text,
          'Date': dateController.text,
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        errorMessage = 'Failed to connect to the server';
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Sets the selected date and updates the date controller text.
  ///
  /// Parameters:
  ///   - `date`: The DateTime object representing the selected event date
  ///
  /// Side effects:
  ///   - Updates [selectedDate] with the provided DateTime
  ///   - Formats the date to 'yyyy-MM-dd' format and updates [dateController]
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    dateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  /// Disposes of all resources managed by this controller.
  ///
  /// This method should be called when the controller is no longer needed
  /// to prevent memory leaks. It disposes all TextEditingController instances.
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   controller.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    eventIdController.dispose();
    eventNameController.dispose();
    eventPlaceController.dispose();
    nameRepController.dispose();
    emailRepController.dispose();
    tecExtController.dispose();
    dateController.dispose();
  }
}
