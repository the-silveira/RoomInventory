import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:roominventory/services/supabase_service.dart';

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
    // Helper para obter valor com fallback entre minúsculas e PascalCase
    String get(dynamic e, String key) {
      return e?[key] ?? e?[key.toLowerCase()] ?? '';
    }

    eventNameController = TextEditingController(text: get(event, 'eventName'));
    eventPlaceController =
        TextEditingController(text: get(event, 'eventplace'));
    nameRepController = TextEditingController(text: get(event, 'namerep'));
    emailRepController = TextEditingController(text: get(event, 'emailrep'));
    tecExtController = TextEditingController(text: get(event, 'tecext'));
    dateController = TextEditingController(text: get(event, 'date'));
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
      final eventData = {
        'eventname': eventNameController.text,
        'eventplace': eventPlaceController.text,
        'namerep': nameRepController.text,
        'emailrep': emailRepController.text,
        'tecext': tecExtController.text,
        'date': dateController.text,
      };

      await SupabaseService.updateEvent(eventId, eventData);
      return true;
    } catch (e) {
      errorMessage = 'Connection error: $e';
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup(
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
