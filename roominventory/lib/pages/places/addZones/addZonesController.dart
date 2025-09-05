import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/// A controller class for managing the addition of new zones to the inventory system.
///
/// This controller handles the business logic for creating zones, including:
/// - Form validation for zone names
/// - HTTP requests to save zones to the backend API
/// - Loading state management during API calls
/// - Error handling and message management
///
/// The controller follows the typical Flutter controller pattern with
/// [TextEditingController] for form fields and HTTP client for API communication.
/// It is designed to be used with zone creation forms and pages.
///
/// Example usage:
/// ```dart
/// final addZoneController = AddZoneController();
///
/// // Validate form inputs
/// if (addZoneController.validateForm()) {
///   // Save zone to backend
///   final success = await addZoneController.saveZone();
///   if (success) {
///     // Handle successful zone creation
///     print('Zone created successfully');
///   } else {
///     // Show error message to user
///     showError(addZoneController.errorMessage);
///   }
/// }
/// ```
class AddZoneController {
  /// Controller for the zone name text input field.
  ///
  /// Used to capture and manage user input for the zone name.
  /// Provides methods for text manipulation, selection, and validation.
  /// Must be disposed when no longer needed to prevent memory leaks.
  final TextEditingController nameController = TextEditingController();

  /// Indicates whether an API request is currently in progress.
  ///
  /// When `true`:
  /// - The UI should display a loading indicator
  /// - Form interactions should be disabled
  /// - Save operations should be prevented
  ///
  /// Automatically managed during save operations through [saveZone] method.
  bool isLoading = false;

  /// Stores error messages for display to the user.
  ///
  /// Contains validation errors or API error messages in user-friendly format.
  /// Empty string indicates no errors. Updated during:
  /// - Form validation ([validateForm])
  /// - API operations ([saveZone])
  ///
  /// Example error messages:
  /// - "Please enter a zone name" (validation error)
  /// - "Failed to save zone: 404" (API error)
  /// - "Error saving zone: SocketException" (network error)
  String errorMessage = '';

  /// Validates the form inputs for adding a new zone.
  ///
  /// Performs client-side validation checks:
  /// - Ensures zone name field is not empty
  /// - Updates [errorMessage] with appropriate validation messages
  ///
  /// Returns:
  /// - `true` if the form is valid (zone name is not empty)
  /// - `false` if the form is invalid (zone name is empty)
  ///
  /// Example:
  /// ```dart
  /// if (controller.validateForm()) {
  ///   // Proceed with saving the zone
  /// } else {
  ///   // Show validation error: controller.errorMessage
  /// }
  /// ```
  bool validateForm() {
    if (nameController.text.isEmpty) {
      errorMessage = 'Please enter a zone name';
      return false;
    }
    errorMessage = '';
    return true;
  }

  /// Saves the zone to the remote database via HTTP API call.
  ///
  /// Performs the following operations:
  /// 1. Validates form inputs using [validateForm]
  /// 2. Sets loading state to `true`
  /// 3. Sends POST request to backend API with zone data
  /// 4. Handles response and error scenarios
  /// 5. Resets loading state to `false`
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// Query Parameter: `query_param = 'P4'` (specific to zone creation)
  /// Form Data: `ZoneName = [entered zone name]`
  ///
  /// Returns:
  /// - `Future<bool>`: `true` if the zone was saved successfully (HTTP 200)
  /// - `Future<bool>`: `false` if validation failed or API call encountered an error
  ///
  /// Error Handling:
  /// - HTTP errors: Captures status code and updates [errorMessage]
  /// - Network errors: Captures exception details and updates [errorMessage]
  ///
  /// Example:
  /// ```dart
  /// final success = await controller.saveZone();
  /// if (success) {
  ///   Navigator.pop(context, true); // Return success to previous page
  /// } else {
  ///   // Display controller.errorMessage to user
  /// }
  /// ```
  Future<bool> saveZone() async {
    if (!validateForm()) return false;

    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'P4', // Adjust based on your API
          'ZoneName': nameController.text,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = 'Failed to save zone: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error saving zone: $e';
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
  ///   addZoneController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    nameController.dispose();
  }
}
