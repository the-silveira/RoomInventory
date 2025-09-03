import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsController.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsWidgets.dart';
import 'package:roominventory/pages/events/addItemEvents/addItemEventsWidgets.dart'
    hide ErrorMessage;

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final AddEventController _controller = AddEventController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    bool success = await _controller.saveEvent();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_controller.errorMessage ?? 'Failed to add event')),
      );
      setState(() {}); // Refresh to show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AddNavigationBar(
        title: 'Novo Evento',
        previousPageTitle: 'Eventos',
        onAddPressed: _saveItem,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ErrorMessage(message: _controller.errorMessage ?? ''),
                EventForm(controller: _controller, context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
