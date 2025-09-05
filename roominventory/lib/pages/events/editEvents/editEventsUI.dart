import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/editEvents/editEventsWidgets.dart';
import 'package:roominventory/pages/events/editEvents/editEvetsController.dart';

/// A page for editing existing event information.
///
/// This page provides a form interface for modifying event details including:
/// - Event name
/// - Event location
/// - Representative information
/// - Technical external reference
/// - Event date
///
/// The page uses an [editEventsController] to manage form state and data operations.
/// Users can save changes or cancel editing through the navigation controls.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(
///     builder: (context) => editEventsPage(event: eventData),
///   ),
/// );
/// ```
class editEventsPage extends StatefulWidget {
  /// The event data to be edited, expected to contain event properties
  final dynamic event;

  /// Creates an event editing page for the specified event
  ///
  /// [event]: The event data to edit (should be a Map with event properties)
  const editEventsPage({required this.event});

  @override
  _editEventsPageState createState() => _editEventsPageState();
}

/// The state class for [editEventsPage] that manages the editing form and operations.
///
/// This state class handles:
/// - Controller initialization and cleanup
/// - Form state management
/// - Save operation coordination
/// - Navigation and success handling
class _editEventsPageState extends State<editEventsPage> {
  /// Controller responsible for managing form state and saving operations
  final editEventsController _controller = editEventsController();

  @override
  void initState() {
    super.initState();
    _controller.initializeControllers(widget.event);
  }

  @override
  void dispose() {
    _controller.disposeControllers();
    super.dispose();
  }

  /// Handles successful save operation by navigating back with a result
  ///
  /// This method is called when event changes are successfully saved.
  /// It pops the navigation stack to return to the previous screen
  /// with a success indicator (true).
  void _onSaveSuccess() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Edit Event',
        previousPageTitle: 'Event Details',

        /// Custom add button that serves as the save action
        onAddPressed: () async {
          bool success = await _controller.saveChanges(widget.event['IdEvent']);
          if (success) {
            _onSaveSuccess();
          } else {
            _controller.showError(context, _controller.errorMessage);
          }
        },
      ),
      child: SafeArea(
        child: Column(
          children: [
            /// Scrollable form section containing editable event fields
            Expanded(
              child: ListView(
                children: [
                  EventForm(controller: _controller),
                ],
              ),
            ),

            /// Fixed save button at the bottom of the screen
            SaveButton(
              controller: _controller,
              eventId: widget.event['IdEvent'],
              onSaveSuccess: _onSaveSuccess,
            ),
          ],
        ),
      ),
    );
  }
}
