import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/editEvents/editEventsWidgets.dart';
import 'package:roominventory/pages/events/editEvents/editEvetsController.dart';

class editEventsPage extends StatefulWidget {
  final dynamic event;

  editEventsPage({required this.event});

  @override
  _editEventsPageState createState() => _editEventsPageState();
}

class _editEventsPageState extends State<editEventsPage> {
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

  void _onSaveSuccess() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Edit Event',
        previousPageTitle: 'Event Details',
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
            Expanded(
              child: ListView(
                children: [
                  EventForm(controller: _controller),
                ],
              ),
            ),
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
