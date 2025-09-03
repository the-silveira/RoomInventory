import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/places/addZones/addZonesController.dart';
import 'package:roominventory/pages/places/addZones/addZonesWidgets.dart';

class AddZonePage extends StatefulWidget {
  @override
  _AddZonePageState createState() => _AddZonePageState();
}

class _AddZonePageState extends State<AddZonePage> {
  final AddZoneController _controller = AddZoneController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveZone() async {
    bool success = await _controller.saveZone();

    if (success) {
      Navigator.pop(context, true);
    } else {
      // Show error message if needed
      // You could add a dialog here to show the error message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(_controller.errorMessage),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add New Zone'),
        trailing: SaveButton(
          isLoading: _controller.isLoading,
          onSave: _saveZone,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZoneForm(controller: _controller.nameController),
        ),
      ),
    );
  }
}
