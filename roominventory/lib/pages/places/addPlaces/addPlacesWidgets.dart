import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceForm extends StatelessWidget {
  final TextEditingController controller;

  const PlaceForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final Function() onSave;

  const SaveButton({
    Key? key,
    required this.isLoading,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: isLoading ? CupertinoActivityIndicator() : Text('Save'),
      onPressed: isLoading ? null : onSave,
    );
  }
}
