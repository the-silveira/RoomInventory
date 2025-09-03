import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/places/addPlaces/addPlacesController.dart';
import 'package:roominventory/places/addPlaces/addPlacesWidgets.dart';

class AddPlacePage extends StatefulWidget {
  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final AddPlaceController _controller = AddPlaceController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePlace() async {
    bool success = await _controller.savePlace();

    if (success) {
      Navigator.pop(context, true);
    } else {
      // Show error message if needed
      // You could add a dialog here to show the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add New Place'),
        trailing: SaveButton(
          isLoading: _controller.isLoading,
          onSave: _savePlace,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlaceForm(controller: _controller.nameController),
        ),
      ),
    );
  }
}
