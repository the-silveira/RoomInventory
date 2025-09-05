import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A form widget for entering zone information in a Cupertino-style interface.
///
/// This widget provides a standardized form field for entering zone names
/// with proper Cupertino design principles. It's designed to be used in
/// zone creation and editing interfaces, providing consistent styling
/// and user experience across the application.
///
/// The form field includes:
/// - A text input field with placeholder text for zone names
/// - A prefix label for accessibility and form clarity
/// - Cupertino-style styling with proper spacing and borders
/// - Integration with TextEditingController for state management
///
/// Example usage:
/// ```dart
/// ZoneForm(
///   controller: _zoneNameController,
/// )
/// ```
class ZoneForm extends StatelessWidget {
  /// The controller that manages the text input for the zone name field.
  ///
  /// This controller should be provided by the parent widget and is used to:
  /// - Capture user input for the zone name
  /// - Validate the input content
  /// - Submit the data to backend services
  /// - Clear or pre-populate the field when needed
  ///
  /// The controller must be disposed by the parent widget when no longer needed.
  final TextEditingController controller;

  /// Creates a zone form with a single text input field for the zone name.
  ///
  /// Requires a [controller] to manage the text input state and validation.
  ///
  /// Example:
  /// ```dart
  /// ZoneForm(
  ///   controller: _zoneNameController,
  /// )
  /// ```
  const ZoneForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Builds the Cupertino-style form section with a single text input field.
    ///
    /// Returns a [CupertinoFormSection] containing a [CupertinoTextFormFieldRow]
    /// configured for zone name input with appropriate styling and placeholder text.
    ///
    /// The form section provides:
    /// - Consistent Cupertino design styling
    /// - Proper spacing and layout
    /// - Accessibility features through the prefix label
    /// - Integration with the provided text editing controller
    return CupertinoFormSection(
      children: [
        CupertinoTextFormFieldRow(
          controller: controller,
          placeholder: 'Zone Name',
          prefix: Text('Name:'),
        ),
      ],
    );
  }
}

/// A save button widget with loading state support for form submissions.
///
/// This button provides a standardized save action component that:
/// - Displays either "Save" text or a loading indicator based on state
/// - Automatically disables itself during loading operations
/// - Uses Cupertino-style design for iOS consistency
/// - Integrates seamlessly with navigation bars and form layouts
///
/// The button is designed to prevent multiple simultaneous submissions
/// and provide visual feedback during asynchronous operations.
///
/// Example usage:
/// ```dart
/// SaveButton(
///   isLoading: _controller.isLoading,
///   onSave: _saveFormData,
/// )
/// ```
class SaveButton extends StatelessWidget {
  /// Indicates whether the button should show a loading state.
  ///
  /// When `true`:
  /// - Shows a [CupertinoActivityIndicator] instead of text
  /// - Disables the button to prevent multiple submissions
  /// - Changes to a non-interactive visual state
  ///
  /// When `false`:
  /// - Shows "Save" text label
  /// - Enables the button for user interaction
  /// - Executes the onSave callback when pressed
  final bool isLoading;

  /// The callback function to execute when the button is pressed.
  ///
  /// This function is typically used to:
  /// - Validate form data
  /// - Submit data to backend services
  /// - Handle save operation logic
  ///
  /// The callback is only invoked when [isLoading] is `false`.
  /// It should return quickly or be asynchronous to avoid UI jank.
  final Function() onSave;

  /// Creates a save button with loading state support.
  ///
  /// Requires:
  /// - [isLoading]: The current loading state of the operation
  /// - [onSave]: The function to call when the button is pressed (when not loading)
  ///
  /// Example:
  /// ```dart
  /// SaveButton(
  ///   isLoading: false,
  ///   onSave: () => _handleSave(),
  /// )
  /// ```
  const SaveButton({
    Key? key,
    required this.isLoading,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Builds the save button with dynamic state handling.
    ///
    /// Returns a [CupertinoButton] that dynamically changes based on loading state:
    /// - Shows loading indicator and disables when [isLoading] is true
    /// - Shows "Save" text and enables when [isLoading] is false
    ///
    /// The button uses zero padding for compact integration in navigation bars
    /// and maintains proper Cupertino design principles.
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: isLoading ? CupertinoActivityIndicator() : Text('Save'),
      onPressed: isLoading ? null : onSave,
    );
  }
}
