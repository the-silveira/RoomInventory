import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:roominventory/services/supabase_service.dart';

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

  Future<bool> saveEvent() async {
    if (!validateForm()) return false;

    isLoading = true;
    errorMessage = null;

    try {
      // Usar chaves minúsculas (nomes das colunas no Supabase)
      final eventData = {
        'idevent': eventIdController.text,
        'eventname': eventNameController.text,
        'eventplace': eventPlaceController.text,
        'namerep': nameRepController.text,
        'emailrep': emailRepController.text,
        'tecext': tecExtController.text,
        'date': dateController.text,
      };

      await SupabaseService.insertEvent(eventData);
      return true;
    } catch (e) {
      errorMessage = 'Connection error: $e';
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
