import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../appbar/appbar_back.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _eventIdController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventPlaceController = TextEditingController();
  final _nameRepController = TextEditingController();
  final _emailRepController = TextEditingController();
  final _tecExtController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;
  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate ?? DateTime.now(),
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                    _dateController.text = newDate.toString();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to validate the form
  bool _validateForm() {
    if (_eventNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the event name';
      });
      return false;
    }
    if (_eventPlaceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the event place';
      });
      return false;
    }
    if (_nameRepController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the representative name';
      });
      return false;
    }
    if (_emailRepController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the representative email';
      });
      return false;
    }
    if (_dateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the event date';
      });
      return false;
    }
    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  // Function to submit the form
  Future<void> _saveItem() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E3', // Assuming 'E2' is the query for adding an event
          'IdEvent': _eventIdController.text,
          'EventName': _eventNameController.text,
          'EventPlace': _eventPlaceController.text,
          'NameRep': _nameRepController.text,
          'EmailRep': _emailRepController.text,
          'TecExt': _tecExtController.text,
          'Date': _dateController.text,
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event added successfully!')),
          );
          Navigator.pop(context); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add event: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
                CupertinoTextField(
                  controller: _eventIdController,
                  placeholder: 'ID',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _eventNameController,
                  placeholder: 'Nome',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _eventPlaceController,
                  placeholder: 'Local',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _nameRepController,
                  placeholder: 'Nome Representante',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _emailRepController,
                  placeholder: 'Email Representante',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _tecExtController,
                  placeholder: 'Técnico Externo',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showDatePicker(context),
                  child: AbsorbPointer(
                    child: CupertinoTextField(
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
