import 'package:flutter/cupertino.dart';
import 'package:roominventory/pages/events/editEvents/editEvetsController.dart';

/// A form widget for editing event details with Cupertino-style form fields.
///
/// This widget provides a grouped form section with the following fields:
/// - Event Name
/// - Event Place
/// - Representative Name
/// - Representative Email
/// - Technical Details
/// - Event Date (with date picker functionality)
///
/// The form is connected to an [editEventsController] which manages the
/// text editing controllers and form state.
///
/// Example usage:
/// ```dart
/// EventForm(controller: _editEventsController)
/// ```
class EventForm extends StatelessWidget {
  /// The controller that manages the form state and field controllers
  final editEventsController controller;

  /// Creates an event form widget
  ///
  /// [controller]: The controller that provides the text editing controllers
  ///               and handles form operations
  const EventForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: Text('Event Details'),
      children: [
        /// Event name input field
        CupertinoTextFormFieldRow(
          controller: controller.eventNameController,
          placeholder: 'Event Name',
          prefix: Text('Name:'),
        ),

        /// Event location input field
        CupertinoTextFormFieldRow(
          controller: controller.eventPlaceController,
          placeholder: 'Event Place',
          prefix: Text('Place:'),
        ),

        /// Representative name input field
        CupertinoTextFormFieldRow(
          controller: controller.nameRepController,
          placeholder: 'Representative Name',
          prefix: Text('Rep:'),
        ),

        /// Representative email input field with email keyboard
        CupertinoTextFormFieldRow(
          controller: controller.emailRepController,
          placeholder: 'Representative Email',
          prefix: Text('Email:'),
          keyboardType: TextInputType.emailAddress,
        ),

        /// Technical details input field
        CupertinoTextFormFieldRow(
          controller: controller.tecExtController,
          placeholder: 'Technical Details',
          prefix: Text('Tech:'),
        ),

        /// Date input field with tap-to-pick functionality
        /// Uses GestureDetector to make the field tappable for date selection
        /// while AbsorbPointer prevents manual text input
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: AbsorbPointer(
            child: CupertinoTextFormFieldRow(
              controller: controller.dateController,
              placeholder: 'Event Date (YYYY-MM-DD)',
              prefix: Text('Date:'),
            ),
          ),
        ),
      ],
    );
  }
}

/// A save button widget that handles event changes saving with state feedback.
///
/// This widget provides:
/// - A filled Cupertino button for saving changes
/// - Loading indicator during save operations
/// - Success and error handling through callbacks
/// - Integration with the edit events controller for save operations
///
/// Example usage:
/// ```dart
/// SaveButton(
///   controller: _editEventsController,
///   eventId: 'event123',
///   onSaveSuccess: _handleSaveSuccess,
/// )
/// ```
class SaveButton extends StatelessWidget {
  /// The controller that handles the save operation and form validation
  final editEventsController controller;

  /// The unique identifier of the event being edited
  final String eventId;

  /// Callback function triggered when the save operation is successful
  final Function() onSaveSuccess;

  /// Creates a save button widget
  ///
  /// [controller]: The controller that handles save operations and validation
  /// [eventId]: The unique identifier of the event to save
  /// [onSaveSuccess]: Callback function for successful save operations
  const SaveButton({
    Key? key,
    required this.controller,
    required this.eventId,
    required this.onSaveSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoButton.filled(
        /// Disable button during save operations to prevent multiple submissions
        onPressed: controller.isSaving ? null : () => _saveChanges(context),
        child: controller.isSaving
            ? CupertinoActivityIndicator()
            : Text('Save Changes'),
      ),
    );
  }

  /// Performs the save operation and handles the result
  ///
  /// This method:
  /// 1. Calls the controller's saveChanges method
  /// 2. Triggers the success callback if the operation succeeds
  /// 3. Shows an error dialog if the operation fails
  ///
  /// [context]: The build context for showing error dialogs
  Future<void> _saveChanges(BuildContext context) async {
    bool success = await controller.saveChanges(eventId);
    if (success) {
      onSaveSuccess();
    } else {
      controller.showError(context, controller.errorMessage);
    }
  }
}
