import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/// A controller class for managing the addition of new places to the inventory system.
///
/// This controller handles:
/// - Form validation for place names
/// - HTTP requests to save places to the backend API
/// - Loading state management
/// - Error handling and message management
///
/// The controller follows the typical Flutter controller pattern with
/// TextEditingController for form fields and HTTP client for API communication.
///
/// Example usage:
/// ```dart
/// final addPlaceController = AddPlaceController();
///
/// // Validate form
/// if (addPlaceController.validateForm()) {
///   // Save place
///   final success = await addPlaceController.savePlace();
///   if (success) {
///     // Handle success
///   } else {
///     // Show error: addPlaceController.errorMessage
///   }
/// }
/// ```
class AddPlaceController {
  /// Controller for the place name text input field.
  ///
  /// Used to capture and manage the user input for the place name.
  /// Should be disposed when no longer needed to prevent memory leaks.
  final TextEditingController nameController = TextEditingController();

  /// Indicates whether an API request is currently in progress.
  ///
  /// When true, the UI should show a loading indicator and disable form interactions.
  /// Automatically managed during save operations.
  bool isLoading = false;

  /// Stores error messages for display to the user.
  ///
  /// Contains validation errors or API error messages. Empty string indicates no errors.
  /// Updated during validation and save operations.
  String errorMessage = '';

  /// Validates the form inputs for adding a new place.
  ///
  /// Checks if the place name field is not empty. Updates [errorMessage] with
  /// appropriate validation messages.
  ///
  /// Returns:
  /// - `true` if the form is valid (name is not empty)
  /// - `false` if the form is invalid (name is empty)
  ///
  /// Example:
  /// ```dart
  /// if (controller.validateForm()) {
  ///   // Proceed with saving
  /// }
  /// ```
  bool validateForm() {
    if (nameController.text.isEmpty) {
      errorMessage = 'Please enter a place name';
      return false;
    }
    errorMessage = '';
    return true;
  }

  /// Saves the place to the remote database via HTTP API call.
  ///
  /// Performs form validation first, then sends a POST request to the backend API
  /// with the place data. Handles loading state and error management automatically.
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// Query Parameter: `query_param = 'P3'`
  /// Form Data: `PlaceName = [entered name]`
  ///
  /// Returns:
  /// - `Future<bool>`: `true` if the place was saved successfully
  /// - `Future<bool>`: `false` if validation failed or API call encountered an error
  ///
  /// Throws:
  /// - Various network and HTTP exceptions which are caught and converted to error messages
  ///
  /// Example:
  /// ```dart
  /// final success = await controller.savePlace();
  /// if (success) {
  ///   Navigator.pop(context, true); // Return success
  /// }
  /// ```
  Future<bool> savePlace() async {
    if (!validateForm()) return false;

    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'P3',
          'PlaceName': nameController.text,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = 'Failed to save place: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error saving place: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Cleans up resources used by the controller.
  ///
  /// Disposes of the [nameController] to prevent memory leaks.
  /// Should be called when the controller is no longer needed, typically
  /// in the `dispose` method of the associated State class.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   addPlaceController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    nameController.dispose();
  }
}
