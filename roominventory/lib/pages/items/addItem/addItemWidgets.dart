import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/items/addItem/addItemController.dart';

/// A form section widget for entering basic item information.
///
/// This widget provides text fields for:
/// - Item ID
/// - Item Name
///
/// It's part of the item creation form and uses Cupertino-style form elements.
///
/// Example usage:
/// ```dart
/// ItemInformationSection(controller: _addItemController)
/// ```
class ItemInformationSection extends StatelessWidget {
  /// Controller that manages the form state and text editing controllers
  final AddItemController controller;

  /// Creates an item information section
  ///
  /// [controller]: The controller that provides the text editing controllers
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
        /// Item ID input field
        CupertinoTextFormFieldRow(
          controller: controller.idItemController,
          placeholder: 'ID',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Item name input field
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

/// A form section widget for selecting item location (place and zone).
///
/// This widget provides selection interfaces for:
/// - Place selection (shows a picker dialog)
/// - Zone selection (shows a picker dialog filtered by selected place)
///
/// The selected values are displayed as buttons that trigger the picker dialogs.
///
/// Example usage:
/// ```dart
/// LocationSection(
///   controller: _addItemController,
///   onShowPlacePicker: _showPlacePicker,
///   onShowZonePicker: _showZonePicker,
/// )
/// ```
class LocationSection extends StatelessWidget {
  /// Controller that manages location selection state
  final AddItemController controller;

  /// Callback function to show the place picker dialog
  final Function() onShowPlacePicker;

  /// Callback function to show the zone picker dialog
  final Function() onShowZonePicker;

  /// Creates a location selection section
  ///
  /// [controller]: The controller that manages location state
  /// [onShowPlacePicker]: Callback to show place picker
  /// [onShowZonePicker]: Callback to show zone picker
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
        /// Place selection tile
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

        /// Zone selection tile
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

/// A form section widget for entering item details and custom dynamic fields.
///
/// This widget provides:
/// - Static detail fields (Marca, Tipo, Quantidade, Condição, Tamanho)
/// - Date selection for last verification
/// - Dynamic input fields for custom details
/// - Add/remove functionality for dynamic fields
///
/// Example usage:
/// ```dart
/// DetailsSection(
///   controller: _addItemController,
///   onShowDatePicker: _showDatePicker,
///   onAddDynamicInput: _addDynamicInput,
///   onRemoveDynamicInput: _removeDynamicInput,
/// )
/// ```
class DetailsSection extends StatelessWidget {
  /// Controller that manages detail fields and dynamic inputs
  final AddItemController controller;

  /// Callback function to show the date picker dialog
  final Function() onShowDatePicker;

  /// Callback function to add a new dynamic input field
  final Function() onAddDynamicInput;

  /// Callback function to remove a dynamic input field
  final Function(int) onRemoveDynamicInput;

  /// Creates a details section with static and dynamic fields
  ///
  /// [controller]: The controller that manages detail fields
  /// [onShowDatePicker]: Callback to show date picker
  /// [onAddDynamicInput]: Callback to add dynamic input
  /// [onRemoveDynamicInput]: Callback to remove dynamic input
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
        /// Brand input field
        CupertinoTextFormFieldRow(
          controller: controller.marcaController,
          placeholder: 'Marca',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Type input field
        CupertinoTextFormFieldRow(
          controller: controller.tipoController,
          placeholder: 'Tipo',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Quantity input field
        CupertinoTextFormFieldRow(
          controller: controller.quantidadeController,
          placeholder: 'Quantidade',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Condition input field
        CupertinoTextFormFieldRow(
          controller: controller.condicaoController,
          placeholder: 'Condição',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Size input field
        CupertinoTextFormFieldRow(
          controller: controller.tamanhoController,
          placeholder: 'Tamanho',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        /// Last verification date selection tile
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

        /// Dynamic input fields
        ..._buildDynamicInputs(context),

        /// Add dynamic input button
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

  /// Builds the dynamic input fields from the controller's dynamicInputs list
  ///
  /// Each dynamic input consists of two text fields (detail name and value)
  /// with a remove button. Returns a list of widget columns for each dynamic input.
  ///
  /// [context]: The build context for styling
  /// Returns: List<Widget> containing the dynamic input fields
  List<Widget> _buildDynamicInputs(BuildContext context) {
    return controller.dynamicInputs.map((input) {
      final index = controller.dynamicInputs.indexOf(input);
      return Column(
        children: [
          Row(
            children: [
              /// Detail name input field
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

              /// Detail value input field
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

              /// Remove button
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

/// A dialog widget for selecting a place from available options.
///
/// Displays a Cupertino-style picker with a list of available places.
/// The selected place index is returned via the onSelected callback.
///
/// Example usage:
/// ```dart
/// PlacePickerDialog(
///   controller: _addItemController,
///   onSelected: (index) => _handlePlaceSelection(index),
/// )
/// ```
class PlacePickerDialog extends StatelessWidget {
  /// Controller that provides the list of available places
  final AddItemController controller;

  /// Callback function triggered when a place is selected
  final Function(int) onSelected;

  /// Creates a place picker dialog
  ///
  /// [controller]: The controller that provides places data
  /// [onSelected]: Callback for place selection
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

/// A dialog widget for selecting a zone from available options.
///
/// Displays a Cupertino-style picker with zones filtered by the selected place.
/// The selected zone index is returned via the onSelected callback.
///
/// Example usage:
/// ```dart
/// ZonePickerDialog(
///   controller: _addItemController,
///   onSelected: (index) => _handleZoneSelection(index),
/// )
/// ```
class ZonePickerDialog extends StatelessWidget {
  /// Controller that provides the list of filtered zones
  final AddItemController controller;

  /// Callback function triggered when a zone is selected
  final Function(int) onSelected;

  /// Creates a zone picker dialog
  ///
  /// [controller]: The controller that provides filtered zones data
  /// [onSelected]: Callback for zone selection
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

/// A dialog widget for selecting a date.
///
/// Displays a Cupertino-style date picker for selecting the last verification date.
/// The selected date is returned via the onDateChanged callback.
///
/// Example usage:
/// ```dart
/// DatePickerDialog(
///   controller: _addItemController,
///   onDateChanged: (date) => _handleDateSelection(date),
/// )
/// ```
class DatePickerDialog extends StatelessWidget {
  /// Controller that provides the initial date value
  final AddItemController controller;

  /// Callback function triggered when a date is selected or changed
  final Function(DateTime) onDateChanged;

  /// Creates a date picker dialog
  ///
  /// [controller]: The controller that provides the initial date
  /// [onDateChanged]: Callback for date selection
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

/// A dialog widget for displaying messages to the user.
///
/// Shows a Cupertino-style alert dialog with a title, message, and OK button.
/// Can optionally navigate back when dismissed.
///
/// Example usage:
/// ```dart
/// MessageDialog(
///   title: 'Success',
///   message: 'Item saved successfully',
///   onOk: () {},
///   shouldPop: true,
/// )
/// ```
class MessageDialog extends StatelessWidget {
  /// The title of the message dialog
  final String title;

  /// The message content to display
  final String message;

  /// Callback function for the OK button
  final Function() onOk;

  /// Whether to navigate back after dismissing the dialog
  final bool shouldPop;

  /// Creates a message dialog
  ///
  /// [title]: Dialog title
  /// [message]: Dialog message content
  /// [onOk]: Callback for OK button
  /// [shouldPop]: Whether to pop navigation after dismissal
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
