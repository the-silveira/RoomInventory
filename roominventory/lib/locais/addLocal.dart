import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPlacePage extends StatefulWidget {
  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add New Place'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: _isSaving ? CupertinoActivityIndicator() : Text('Save'),
          onPressed: _isSaving ? null : _savePlace,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoFormSection(
            children: [
              CupertinoTextFormFieldRow(
                controller: _nameController,
                placeholder: 'Place Name',
                prefix: Text('Name:'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePlace() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'P3', // Adjust based on your API
          'PlaceName': _nameController.text,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return success
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
