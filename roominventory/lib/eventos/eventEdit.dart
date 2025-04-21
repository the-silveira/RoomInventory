import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roominventory/appbar/appbar.dart';

class EditEventPage extends StatefulWidget {
  final dynamic event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _eventNameController;
  late TextEditingController _eventPlaceController;
  late TextEditingController _nameRepController;
  late TextEditingController _emailRepController;
  late TextEditingController _tecExtController;
  late TextEditingController _dateController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.event['EventName']);
    _eventPlaceController =
        TextEditingController(text: widget.event['EventPlace']);
    _nameRepController = TextEditingController(text: widget.event['NameRep']);
    _emailRepController = TextEditingController(text: widget.event['EmailRep']);
    _tecExtController = TextEditingController(text: widget.event['TecExt']);
    _dateController = TextEditingController(text: widget.event['Date']);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventPlaceController.dispose();
    _nameRepController.dispose();
    _emailRepController.dispose();
    _tecExtController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E7', // Assuming E4 is for updating events
          'IdEvent': widget.event['IdEvent'],
          'EventName': _eventNameController.text,
          'EventPlace': _eventPlaceController.text,
          'NameRep': _nameRepController.text,
          'EmailRep': _emailRepController.text,
          'TecExt': _tecExtController.text,
          'Date': _dateController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          Navigator.pop(context, true); // Return success
        } else {
          _showError('Failed to update event: ${responseBody['message']}');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
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
                      // You'll need to implement date selection logic here
                      Navigator.pop(context, DateTime.now());
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: DateTime.parse(_dateController.text),
                  onDateTimeChanged: (DateTime newDate) {
                    _dateController.text = newDate.toIso8601String();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      _dateController.text = picked.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
        previousPageTitle: 'Inventário',
        onAddPressed: _saveChanges,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: Text('Event Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _eventNameController,
                  placeholder: 'Event Name',
                  prefix: Text('Name:'),
                ),
                CupertinoTextFormFieldRow(
                  controller: _eventPlaceController,
                  placeholder: 'Event Place',
                  prefix: Text('Place:'),
                ),
                CupertinoTextFormFieldRow(
                  controller: _nameRepController,
                  placeholder: 'Representative Name',
                  prefix: Text('Rep:'),
                ),
                CupertinoTextFormFieldRow(
                  controller: _emailRepController,
                  placeholder: 'Representative Email',
                  prefix: Text('Email:'),
                  keyboardType: TextInputType.emailAddress,
                ),
                CupertinoTextFormFieldRow(
                  controller: _tecExtController,
                  placeholder: 'Technical Details',
                  prefix: Text('Tech:'),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CupertinoTextFormFieldRow(
                      controller: _dateController,
                      placeholder: 'Event Date',
                      prefix: Text('Date:'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
