import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class editEventsController {
  late TextEditingController eventNameController;
  late TextEditingController eventPlaceController;
  late TextEditingController nameRepController;
  late TextEditingController emailRepController;
  late TextEditingController tecExtController;
  late TextEditingController dateController;

  bool isSaving = false;
  String errorMessage = '';

  void initializeControllers(dynamic event) {
    eventNameController = TextEditingController(text: event['EventName']);
    eventPlaceController = TextEditingController(text: event['EventPlace']);
    nameRepController = TextEditingController(text: event['NameRep']);
    emailRepController = TextEditingController(text: event['EmailRep']);
    tecExtController = TextEditingController(text: event['TecExt']);
    dateController = TextEditingController(text: event['Date']);
  }

  void disposeControllers() {
    eventNameController.dispose();
    eventPlaceController.dispose();
    nameRepController.dispose();
    emailRepController.dispose();
    tecExtController.dispose();
    dateController.dispose();
  }

  Future<bool> saveChanges(String eventId) async {
    isSaving = true;
    errorMessage = '';

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E7',
          'IdEvent': eventId,
          'EventName': eventNameController.text,
          'EventPlace': eventPlaceController.text,
          'NameRep': nameRepController.text,
          'EmailRep': emailRepController.text,
          'TecExt': tecExtController.text,
          'Date': dateController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['status'] == 'success';
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime initialDate;
        try {
          initialDate = DateTime.parse(dateController.text);
        } catch (e) {
          initialDate = DateTime.now();
        }

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
                      Navigator.pop(
                          context, DateTime.parse(dateController.text));
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(newDate);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void showError(BuildContext context, String message) {
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
}
