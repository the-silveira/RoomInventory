import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
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

  Future<void> _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Adicionar Item',
        previousPageTitle: 'Itens',
        onAddPressed: _saveItem,
      ),
      child: SafeArea(
        child: _controller.isLoading
            ? Center(child: CupertinoActivityIndicator())
            : ListView(
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
                    onAddDynamicInput: () {
                      setState(() {
                        _controller.addDynamicInput();
                      });
                    },
                    onRemoveDynamicInput: (index) {
                      setState(() {
                        _controller.removeDynamicInput(index);
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  void _showPlacePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => PlacePickerDialog(
        controller: _controller,
        onSelected: (index) {
          setState(() {
            final place = _controller.places[index];
            _controller.selectedPlace = place['idplace']?.toString() ??
                place['IdPlace']?.toString() ??
                '';
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
            final zone = _controller.filteredZones[index];
            _controller.selectedZone =
                zone['idzone']?.toString() ?? zone['IdZone']?.toString() ?? '';
          });
        },
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => RotatingDatePickerDialog(
        controller: _controller,
        onDateChanged: (date) {
          setState(() {
            _controller.ultimaVerificacaoDate = date;
          });
        },
      ),
    );
  }

  Future<void> _saveItem() async {
    bool success = await _controller.saveItem();
    if (success) {
      showCupertinoDialog(
        context: context,
        builder: (context) => MessageDialog(
          title: 'Sucesso',
          message: 'Item adicionado com sucesso!',
          onOk: () => Navigator.pop(context),
          shouldPop: true,
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => MessageDialog(
          title: 'Erro',
          message: _controller.errorMessage,
          onOk: () => Navigator.pop(context),
        ),
      );
    }
  }
}
