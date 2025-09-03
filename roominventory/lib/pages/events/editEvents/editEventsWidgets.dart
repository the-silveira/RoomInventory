import 'package:flutter/cupertino.dart';
import 'package:roominventory/pages/events/editEvents/editEvetsController.dart';

class EventForm extends StatelessWidget {
  final editEventsController controller;

  const EventForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: Text('Event Details'),
      children: [
        CupertinoTextFormFieldRow(
          controller: controller.eventNameController,
          placeholder: 'Event Name',
          prefix: Text('Name:'),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.eventPlaceController,
          placeholder: 'Event Place',
          prefix: Text('Place:'),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.nameRepController,
          placeholder: 'Representative Name',
          prefix: Text('Rep:'),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.emailRepController,
          placeholder: 'Representative Email',
          prefix: Text('Email:'),
          keyboardType: TextInputType.emailAddress,
        ),
        CupertinoTextFormFieldRow(
          controller: controller.tecExtController,
          placeholder: 'Technical Details',
          prefix: Text('Tech:'),
        ),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: AbsorbPointer(
            child: CupertinoTextFormFieldRow(
              controller: controller.dateController,
              placeholder: 'Event Date (YYYY-MM-DD)',
              prefix: Text('Date:'),
            ),
          ),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final editEventsController controller;
  final String eventId;
  final Function() onSaveSuccess;

  const SaveButton({
    Key? key,
    required this.controller,
    required this.eventId,
    required this.onSaveSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoButton.filled(
        onPressed: controller.isSaving ? null : () => _saveChanges(context),
        child: controller.isSaving
            ? CupertinoActivityIndicator()
            : Text('Save Changes'),
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    bool success = await controller.saveChanges(eventId);
    if (success) {
      onSaveSuccess();
    } else {
      controller.showError(context, controller.errorMessage);
    }
  }
}
