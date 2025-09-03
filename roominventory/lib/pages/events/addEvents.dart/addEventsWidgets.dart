import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roominventory/pages/events/addEvents.dart/addEventsController.dart';

class EventFormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;

  const EventFormField({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      keyboardType: keyboardType,
    );
  }
}

class DatePickerField extends StatelessWidget {
  final AddEventController controller;
  final BuildContext context;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: AbsorbPointer(
        child: CupertinoTextField(
          controller: TextEditingController(
            text: controller.selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(controller.selectedDate!)
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
    );
  }

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
                initialDateTime: controller.selectedDate ?? DateTime.now(),
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  controller.setSelectedDate(newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String? message;

  const ErrorMessage({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message!,
        style: TextStyle(
          color: CupertinoColors.destructiveRed,
          fontSize: 14,
        ),
      ),
    );
  }
}

class EventForm extends StatelessWidget {
  final AddEventController controller;
  final BuildContext context;

  const EventForm({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventFormField(
          controller: controller.eventIdController,
          placeholder: 'ID',
        ),
        SizedBox(height: 16),
        EventFormField(
          controller: controller.eventNameController,
          placeholder: 'Nome',
        ),
        SizedBox(height: 16),
        EventFormField(
          controller: controller.eventPlaceController,
          placeholder: 'Local',
        ),
        SizedBox(height: 16),
        EventFormField(
          controller: controller.nameRepController,
          placeholder: 'Nome Representante',
        ),
        SizedBox(height: 16),
        EventFormField(
          controller: controller.emailRepController,
          placeholder: 'Email Representante',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        EventFormField(
          controller: controller.tecExtController,
          placeholder: 'Técnico Externo',
        ),
        SizedBox(height: 16),
        DatePickerField(controller: controller, context: context),
      ],
    );
  }
}
