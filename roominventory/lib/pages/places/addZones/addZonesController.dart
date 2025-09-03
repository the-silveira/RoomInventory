import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AddZoneController {
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Validate the form
  bool validateForm() {
    if (nameController.text.isEmpty) {
      errorMessage = 'Please enter a zone name';
      return false;
    }
    errorMessage = '';
    return true;
  }

  // Save zone to database
  Future<bool> saveZone() async {
    if (!validateForm()) return false;

    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'P4', // Adjust based on your API
          'ZoneName': nameController.text,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = 'Failed to save zone: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error saving zone: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    nameController.dispose();
  }
}
