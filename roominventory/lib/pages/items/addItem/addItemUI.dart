import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DatePickerDialog;
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/items/addItem/addItemController.dart';
import 'package:roominventory/pages/items/addItem/addItemWidgets.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final AddItemController _controller = AddItemController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  void _showPlacePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => PlacePickerDialog(
        controller: _controller,
        onSelected: (index) {
          setState(() {
            _controller.selectedPlace = _controller.places[index]['IdPlace'];
            _controller.filterZones(_controller.selectedPlace);
          });
        },
      ),
    );
  }

  void _showZonePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ZonePickerDialog(
        controller: _controller,
        onSelected: (index) {
          setState(() {
            _controller.selectedZone =
                _controller.filteredZones[index]['IdZone'];
          });
        },
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DatePickerDialog(
        controller: _controller,
        onDateChanged: (DateTime newDate) {
          setState(() {
            _controller.ultimaVerificacaoDate = newDate;
          });
        },
      ),
    );
  }

  void _addDynamicInput() {
    setState(() {
      _controller.addDynamicInput();
    });
  }

  void _removeDynamicInput(int index) {
    setState(() {
      _controller.removeDynamicInput(index);
    });
  }

  Future<void> _saveItem() async {
    bool success = await _controller.saveItem();

    if (success) {
      _showMessage('Sucesso', 'Item Guardado com Sucesso', shouldPop: true);
    } else {
      _showMessage('Erro', _controller.errorMessage);
    }
  }

  void _showMessage(String title, String message, {bool shouldPop = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        onOk: () {},
        shouldPop: shouldPop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AddNavigationBar(
        title: 'Novo Item',
        previousPageTitle: 'Inventário',
        onAddPressed: _saveItem,
      ),
      child: SafeArea(
        child: _controller.isLoading
            ? Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ItemInformationSection(controller: _controller),
                    LocationSection(
                      controller: _controller,
                      onShowPlacePicker: _showPlacePicker,
                      onShowZonePicker: _showZonePicker,
                    ),
                    DetailsSection(
                      controller: _controller,
                      onShowDatePicker: _showDatePicker,
                      onAddDynamicInput: _addDynamicInput,
                      onRemoveDynamicInput: _removeDynamicInput,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
