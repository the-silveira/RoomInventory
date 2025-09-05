import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A form widget for entering place information in a Cupertino-style interface.
///
/// This widget provides a standardized form field for entering place names
/// with proper Cupertino design principles. It's typically used in conjunction
/// with [SaveButton] to create complete forms for adding or editing places.
///
/// The form field includes:
/// - A text input field with placeholder text
/// - A prefix label for accessibility and clarity
/// - Cupertino-style styling and validation appearance
///
/// Example usage:
/// ```dart
/// PlaceForm(
///   controller: _nameController,
/// )
/// ```
class PlaceForm extends StatelessWidget {
  /// The controller that manages the text input for the place name field.
  ///
  /// This controller should be provided by the parent widget and is used to
  /// capture, validate, and submit the user's input.
  final TextEditingController controller;

  /// Creates a place form with a single text input field for the place name.
  ///
  /// Requires a [controller] to manage the text input state.
  const PlaceForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Builds the Cupertino-style form section with a single text input field.
    ///
    /// Returns a [CupertinoFormSection] containing a [CupertinoTextFormFieldRow]
    /// configured for place name input with appropriate styling and placeholder text.
    return CupertinoFormSection(
      children: [
        CupertinoTextFormFieldRow(
          controller: controller,
          placeholder: 'Place Name',
          prefix: Text('Name:'),
        ),
      ],
    );
  }
}

/// A save button widget with loading state support for form submissions.
///
/// This button displays either a "Save" text label or a loading indicator
/// depending on the current state. It automatically disables itself during
/// loading states to prevent multiple simultaneous submissions.
///
/// Features:
/// - Dynamic text/loading indicator based on state
/// - Automatic disabled state during loading
/// - Cupertino-style button design
/// - Zero padding for compact navigation bar integration
///
/// Example usage:
/// ```dart
/// SaveButton(
///   isLoading: _controller.isLoading,
///   onSave: _savePlace,
/// )
/// ```
class SaveButton extends StatelessWidget {
  /// Indicates whether the button should show a loading state.
  ///
  /// When `true`:
  /// - Shows a [CupertinoActivityIndicator] instead of text
  /// - Disables the button to prevent multiple submissions
  /// - Changes to a non-interactive state
  ///
  /// When `false`:
  /// - Shows "Save" text
  /// - Enables the button for user interaction
  final bool isLoading;

  /// The callback function to execute when the button is pressed.
  ///
  /// This function is typically used to validate and submit form data.
  /// Only called when [isLoading] is `false`.
  final Function() onSave;

  /// Creates a save button with loading state support.
  ///
  /// Requires:
  /// - [isLoading]: The current loading state of the operation
  /// - [onSave]: The function to call when the button is pressed
  const SaveButton({
    Key? key,
    required this.isLoading,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Builds the save button with dynamic state handling.
    ///
    /// Returns a [CupertinoButton] that either:
    /// - Shows a loading indicator and is disabled when [isLoading] is true
    /// - Shows "Save" text and is enabled when [isLoading] is false
    ///
    /// The button uses zero padding for compact integration in navigation bars.
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: isLoading ? CupertinoActivityIndicator() : Text('Save'),
      onPressed: isLoading ? null : onSave,
    );
  }
}
