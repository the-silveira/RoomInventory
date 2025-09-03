import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddEventController {
  final TextEditingController eventIdController = TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventPlaceController = TextEditingController();
  final TextEditingController nameRepController = TextEditingController();
  final TextEditingController emailRepController = TextEditingController();
  final TextEditingController tecExtController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;
  bool isLoading = false;
  String? errorMessage;

  // Validate the form
  bool validateForm() {
    if (eventNameController.text.isEmpty) {
      errorMessage = 'Please enter the event name';
      return false;
    }
    if (eventPlaceController.text.isEmpty) {
      errorMessage = 'Please enter the event place';
      return false;
    }
    if (nameRepController.text.isEmpty) {
      errorMessage = 'Please enter the representative name';
      return false;
    }
    if (emailRepController.text.isEmpty) {
      errorMessage = 'Please enter the representative email';
      return false;
    }
    if (dateController.text.isEmpty) {
      errorMessage = 'Please enter the event date';
      return false;
    }

    errorMessage = null;
    return true;
  }

  // Function to submit the form
  Future<bool> saveEvent() async {
    if (!validateForm()) return false;

    isLoading = true;

    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'E3',
          'IdEvent': eventIdController.text,
          'EventName': eventNameController.text,
          'EventPlace': eventPlaceController.text,
          'NameRep': nameRepController.text,
          'EmailRep': emailRepController.text,
          'TecExt': tecExtController.text,
          'Date': dateController.text,
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        errorMessage = 'Failed to connect to the server';
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    dateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  void dispose() {
    eventIdController.dispose();
    eventNameController.dispose();
    eventPlaceController.dispose();
    nameRepController.dispose();
    emailRepController.dispose();
    tecExtController.dispose();
    dateController.dispose();
  }
}
