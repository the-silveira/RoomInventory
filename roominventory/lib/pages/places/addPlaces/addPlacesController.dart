import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AddPlaceController {
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Validate the form
  bool validateForm() {
    if (nameController.text.isEmpty) {
      errorMessage = 'Please enter a place name';
      return false;
    }
    errorMessage = '';
    return true;
  }

  // Save place to database
  Future<bool> savePlace() async {
    if (!validateForm()) return false;

    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'P3',
          'PlaceName': nameController.text,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = 'Failed to save place: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error saving place: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    nameController.dispose();
  }
}
