import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsController.dart';

/// A customizable text field widget for event form inputs.
///
/// This widget provides a consistent Cupertino-style text field with
/// standardized styling and validation appearance. It supports various
/// keyboard types and placeholder text for different input requirements.
///
/// Features:
/// - Cupertino-styled text input with border and rounded corners
/// - Customizable placeholder text
/// - Support for different keyboard types (email, numeric, etc.)
/// - Theme-aware text coloring
/// - Consistent padding and styling
///
/// Example usage:
/// ```dart
/// EventFormField(
///   controller: textController,
///   placeholder: 'Enter name',
///   keyboardType: TextInputType.text,
/// )
/// ```
class EventFormField extends StatelessWidget {
  /// The controller that manages the text input content and state
  final TextEditingController controller;

  /// The placeholder text displayed when the field is empty
  final String placeholder;

  /// The type of keyboard to display for input
  ///
  /// Common values:
  /// - `TextInputType.text` (default)
  /// - `TextInputType.emailAddress`
  /// - `TextInputType.number`
  /// - `TextInputType.phone`
  final TextInputType? keyboardType;

  const EventFormField({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      keyboardType: keyboardType,
    );
  }
}

/// A date picker field widget with Cupertino-style modal date selection.
///
/// This widget provides a touch-friendly date selection interface that
/// displays the selected date in a text field format. When tapped, it
/// shows a Cupertino-style date picker modal for date selection.
///
/// Features:
/// - Display of selected date in 'yyyy-MM-dd' format
/// - Cupertino modal date picker interface
/// - Minimum and maximum date constraints (2000-2100)
/// - Theme-aware styling
/// - AbsorbPointer to prevent keyboard input
///
/// Example usage:
/// ```dart
/// DatePickerField(
///   controller: eventController,
///   context: context,
/// )
/// ```
class DatePickerField extends StatelessWidget {
  /// The controller that manages date selection and state
  final AddEventController controller;

  /// The build context for showing modal dialogs
  final BuildContext context;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: AbsorbPointer(
        child: CupertinoTextField(
          controller: TextEditingController(
            text: controller.selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(controller.selectedDate!)
                : '',
          ),
          placeholder: 'Data Evento',
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// Displays a Cupertino-style date picker modal dialog.
  ///
  /// This method shows a bottom modal sheet with a date picker that allows
  /// users to select a date. The selected date is automatically applied to
  /// the controller.
  ///
  /// Parameters:
  ///   - `context`: The build context for showing the modal
  ///
  /// Features:
  ///   - Cancel and Done buttons for user control
  ///   - Date-only selection mode (no time)
  ///   - Defaults to current date if no date is selected
  ///   - Date range constraints (2000-2100)
  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // Action buttons row
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: controller.selectedDate ?? DateTime.now(),
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  controller.setSelectedDate(newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying error messages in the event form.
///
/// This component conditionally displays error messages with consistent
/// styling. It automatically hides itself when no error message is provided.
///
/// Features:
/// - Conditional rendering (hidden when message is null or empty)
/// - Consistent error styling with red text color
/// - Proper spacing and padding
/// - Standardized font size and styling
///
/// Example usage:
/// ```dart
/// ErrorMessage(message: controller.errorMessage)
/// ```
class ErrorMessage extends StatelessWidget {
  /// The error message text to display
  ///
  /// When null or empty, the widget renders as [SizedBox.shrink] (hidden)
  final String? message;

  const ErrorMessage({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hide widget if no message is provided
    if (message == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message!,
        style: TextStyle(
          color: CupertinoColors.destructiveRed,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// A complete event form widget that combines all form fields.
///
/// This widget composes all individual form fields into a complete
/// event creation form with proper spacing and layout.
///
/// The form includes fields for:
/// - Event ID
/// - Event Name
/// - Event Location
/// - Representative Name
/// - Representative Email
/// - External Technician
/// - Event Date (with date picker)
///
/// Features:
/// - Consistent vertical spacing between fields
/// - Proper field ordering and grouping
/// - Theme-aware styling
/// - Integration with event controller
///
/// Example usage:
/// ```dart
/// EventForm(
///   controller: eventController,
///   context: context,
/// )
/// ```
class EventForm extends StatelessWidget {
  /// The controller that manages all form field states and validation
  final AddEventController controller;

  /// The build context for theme access and modal dialogs
  final BuildContext context;

  const EventForm({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event ID field
        EventFormField(
          controller: controller.eventIdController,
          placeholder: 'ID',
        ),
        SizedBox(height: 16),

        // Event Name field
        EventFormField(
          controller: controller.eventNameController,
          placeholder: 'Nome',
        ),
        SizedBox(height: 16),

        // Event Location field
        EventFormField(
          controller: controller.eventPlaceController,
          placeholder: 'Local',
        ),
        SizedBox(height: 16),

        // Representative Name field
        EventFormField(
          controller: controller.nameRepController,
          placeholder: 'Nome Representante',
        ),
        SizedBox(height: 16),

        // Representative Email field
        EventFormField(
          controller: controller.emailRepController,
          placeholder: 'Email Representante',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),

        // External Technician field
        EventFormField(
          controller: controller.tecExtController,
          placeholder: 'Técnico Externo',
        ),
        SizedBox(height: 16),

        // Date Picker field
        DatePickerField(controller: controller, context: context),
      ],
    );
  }
}
