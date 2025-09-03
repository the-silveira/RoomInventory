import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/items/addItem/addItemController.dart';

class ItemInformationSection extends StatelessWidget {
  final AddItemController controller;

  const ItemInformationSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection(
      header: Text(
        "Informação do Item",
        style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      children: [
        CupertinoTextFormFieldRow(
          controller: controller.idItemController,
          placeholder: 'ID',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.itemNameController,
          placeholder: 'Nome',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class LocationSection extends StatelessWidget {
  final AddItemController controller;
  final Function() onShowPlacePicker;
  final Function() onShowZonePicker;

  const LocationSection({
    Key? key,
    required this.controller,
    required this.onShowPlacePicker,
    required this.onShowZonePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection(
      header: Text(
        "Localização",
        style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
      ),
      children: [
        CupertinoListTile(
          title: Text(
            "Lugar",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: CupertinoButton(
            child: Text(
              controller.selectedPlace != null
                  ? controller.places.firstWhere((place) =>
                      place['IdPlace'] == controller.selectedPlace)['PlaceName']
                  : 'Select',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onPressed: onShowPlacePicker,
          ),
        ),
        CupertinoListTile(
          title: Text(
            "Zona",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: CupertinoButton(
            child: Text(
              controller.selectedZone != null
                  ? controller.filteredZones.firstWhere((zone) =>
                      zone['IdZone'] == controller.selectedZone)['ZoneName']
                  : 'Select',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onPressed: onShowZonePicker,
          ),
        ),
      ],
    );
  }
}

class DetailsSection extends StatelessWidget {
  final AddItemController controller;
  final Function() onShowDatePicker;
  final Function() onAddDynamicInput;
  final Function(int) onRemoveDynamicInput;

  const DetailsSection({
    Key? key,
    required this.controller,
    required this.onShowDatePicker,
    required this.onAddDynamicInput,
    required this.onRemoveDynamicInput,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection(
      header: Text(
        "Item Details",
        style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
      ),
      children: [
        CupertinoTextFormFieldRow(
          controller: controller.marcaController,
          placeholder: 'Marca',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.tipoController,
          placeholder: 'Tipo',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.quantidadeController,
          placeholder: 'Quantidade',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.condicaoController,
          placeholder: 'Condição',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoTextFormFieldRow(
          controller: controller.tamanhoController,
          placeholder: 'Tamanho',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        CupertinoListTile(
          title: Text(
            'Última Verificação',
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: CupertinoButton(
            child: Text(
              controller.ultimaVerificacaoDate != null
                  ? '${controller.ultimaVerificacaoDate!.day}/${controller.ultimaVerificacaoDate!.month}/${controller.ultimaVerificacaoDate!.year}'
                  : 'Selecionar Data',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onPressed: onShowDatePicker,
          ),
        ),
        ..._buildDynamicInputs(context),
        CupertinoListTile(
          title: IconButton(
            onPressed: onAddDynamicInput,
            icon: Icon(
              CupertinoIcons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicInputs(BuildContext context) {
    return controller.dynamicInputs.map((input) {
      final index = controller.dynamicInputs.indexOf(input);
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoTextFormFieldRow(
                  controller: input['detalhe'],
                  placeholder: 'Detalhe',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: CupertinoTextFormFieldRow(
                  controller: input['detalheName'],
                  placeholder: 'Detalhe Name',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              SizedBox(width: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.trash,
                    color: CupertinoColors.destructiveRed),
                onPressed: () => onRemoveDynamicInput(index),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      );
    }).toList();
  }
}

class PlacePickerDialog extends StatelessWidget {
  final AddItemController controller;
  final Function(int) onSelected;

  const PlacePickerDialog({
    Key? key,
    required this.controller,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Theme.of(context).colorScheme.surfaceContainer,
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              onSelectedItemChanged: onSelected,
              children: controller.places
                  .map((place) => Text(
                        place['PlaceName'],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ZonePickerDialog extends StatelessWidget {
  final AddItemController controller;
  final Function(int) onSelected;

  const ZonePickerDialog({
    Key? key,
    required this.controller,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Theme.of(context).colorScheme.surfaceContainer,
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              onSelectedItemChanged: onSelected,
              children: controller.filteredZones
                  .map((zone) => Text(
                        zone['ZoneName'],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DatePickerDialog extends StatelessWidget {
  final AddItemController controller;
  final Function(DateTime) onDateChanged;

  const DatePickerDialog({
    Key? key,
    required this.controller,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: Text('Confirmar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime:
                  controller.ultimaVerificacaoDate ?? DateTime.now(),
              minimumDate: DateTime(1900),
              maximumDate: DateTime(2100),
              onDateTimeChanged: onDateChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final Function() onOk;
  final bool shouldPop;

  const MessageDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onOk,
    this.shouldPop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
            if (shouldPop) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
