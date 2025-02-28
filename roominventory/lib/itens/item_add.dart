import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roominventory/appbar/appbar_back.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _idItemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _condicaoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _tamanhoController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _ultimaVerificacaoController = TextEditingController();
  DateTime? _ultimaVerificacaoDate;

  List<dynamic> places = [];
  List<dynamic> zones = [];
  List<dynamic> filteredZones = [];
  String? selectedPlace;
  String? selectedZone;
  final List<Map<String, String>> _detailsList = [];
  bool isLoading = true;

  // New list to store dynamic input fields
  final List<Map<String, TextEditingController>> _dynamicInputs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'P1'},
      );
      if (response.statusCode == 200) {
        setState(() {
          places = json.decode(response.body);
        });
      }

      response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'Z1'},
      );
      if (response.statusCode == 200) {
        setState(() {
          zones = json.decode(response.body);
          filteredZones = zones;
        });
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveItem() async {
    _detailsList.add({
      'Marca': _marcaController.text,
      'Tipo': _tipoController.text,
      'Quantidade': _quantidadeController.text,
      'Condição': _condicaoController.text,
      'Tamanho': _tamanhoController.text,
      'Última Verificação': _ultimaVerificacaoDate != null ? '${_ultimaVerificacaoDate!.day}/${_ultimaVerificacaoDate!.month}/${_ultimaVerificacaoDate!.year}' : '',
    });

    try {
      var response = await http.post(
        Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'I2',
          'IdItem': _idItemController.text,
          'ItemName': _itemNameController.text,
          'FK_IdZone': selectedZone,
        },
      );
      if (json.decode(response.body)['status'].toString() == 'success') {
        for (var detail in _detailsList) {
          detail.forEach((key, value) async {
            await http.post(
              Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
              body: {
                'query_param': 'D1',
                'DetailsName': key,
                'Details': value,
                'FK_IdItem': _idItemController.text,
              },
            );
          });
        }
        for (var input in _dynamicInputs) {
          await http.post(
            Uri.parse('https://services.interagit.com/API/roominventory/api_ri.php'),
            body: {
              'query_param': 'D1',
              'DetailsName': input['detalhe']!.text,
              'Details': input['detalheName']!.text,
              'FK_IdItem': _idItemController.text,
            },
          );
        }
        _showMessage("Item Guardado com Sucesso", json.decode(response.body)['status'].toString());
      } else {
        _showMessage("ID do Item já existe. Tente novamente", json.decode(response.body)['status'].toString());
      }
    } catch (e) {
      _showMessage("Erro Inseperado. Tente novamente", 'error');
    }
  }

  void _showMessage(String message, status) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(status == 'success' ? 'Sucesso' : 'Erro'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => {
              Navigator.pop(context),
              status == 'success' ? Navigator.pop(context) : null,
            },
          ),
        ],
      ),
    );
  }

  void _filterZones(String? placeId) {
    setState(() {
      filteredZones = placeId == null ? zones : zones.where((zone) => zone['FK_IdPlace'] == placeId).toList();
      selectedZone = null;
    });
  }

  void _addDynamicInput() {
    setState(() {
      _dynamicInputs.add({
        'detalhe': TextEditingController(),
        'detalheName': TextEditingController(),
      });
    });
  }

  void _removeDynamicInput(int index) {
    setState(() {
      _dynamicInputs.removeAt(index);
    });
  }

  void _showPlacePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
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
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedPlace = places[index]['IdPlace'];
                    _filterZones(selectedPlace);
                  });
                },
                children: places
                    .map((place) => Text(
                          place['PlaceName'],
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZonePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
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
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedZone = filteredZones[index]['IdZone'];
                  });
                },
                children: filteredZones
                    .map((zone) => Text(
                          zone['ZoneName'],
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _ultimaVerificacaoDate ?? DateTime.now(),
                minimumDate: DateTime(1900),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _ultimaVerificacaoDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
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
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Item Information Section
                    CupertinoFormSection(
                      header: Text(
                        "Informação do Item",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      children: [
                        CupertinoTextFormFieldRow(
                          controller: _idItemController,
                          placeholder: 'ID',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _itemNameController,
                          placeholder: 'Nome',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),

                    // Location Section
                    CupertinoFormSection(
                      header: Text(
                        "Localização",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      children: [
                        CupertinoListTile(
                          title: Text(
                            "Lugar",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          trailing: CupertinoButton(
                            child: Text(
                              selectedPlace != null ? places.firstWhere((place) => place['IdPlace'] == selectedPlace)['PlaceName'] : 'Select',
                              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            onPressed: _showPlacePicker,
                          ),
                        ),
                        CupertinoListTile(
                          title: Text(
                            "Zona",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          trailing: CupertinoButton(
                            child: Text(
                              selectedZone != null ? filteredZones.firstWhere((zone) => zone['IdZone'] == selectedZone)['ZoneName'] : 'Select',
                              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            onPressed: _showZonePicker,
                          ),
                        ),
                      ],
                    ),

                    // Details Section
                    CupertinoFormSection(
                      header: Text(
                        "Item Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      children: [
                        CupertinoTextFormFieldRow(
                          controller: _marcaController,
                          placeholder: 'Marca',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _tipoController,
                          placeholder: 'Tipo',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _quantidadeController,
                          placeholder: 'Quantidade',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _condicaoController,
                          placeholder: 'Condição',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _tamanhoController,
                          placeholder: 'Tamanho',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        CupertinoListTile(
                          title: Text(
                            'Última Verificação',
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          trailing: CupertinoButton(
                            child: Text(
                              _ultimaVerificacaoDate != null ? '${_ultimaVerificacaoDate!.day}/${_ultimaVerificacaoDate!.month}/${_ultimaVerificacaoDate!.year}' : 'Selecionar Data',
                              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            onPressed: _showDatePicker,
                          ),
                        ),

                        // Dynamic Inputs Section (right below the Details Section)
                        ..._dynamicInputs.map((input) {
                          final index = _dynamicInputs.indexOf(input);
                          return Column(
                            children: [
                              Row(
                                children: [
                                  // Detalhe Input
                                  Expanded(
                                    child: CupertinoTextFormFieldRow(
                                      controller: input['detalhe'],
                                      placeholder: 'Detalhe',
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                  SizedBox(width: 5), // Add some spacing between the inputs
                                  // Detalhe Name Input
                                  Expanded(
                                    child: CupertinoTextFormFieldRow(
                                      controller: input['detalheName'],
                                      placeholder: 'Detalhe Name',
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                  SizedBox(width: 10), // Add some spacing between the inputs and the button
                                  // Remove Button (Trash Icon)
                                  CupertinoButton(
                                    padding: EdgeInsets.zero, // Remove default padding
                                    child: Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
                                    onPressed: () => _removeDynamicInput(index),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10), // Add some spacing between dynamic inputs
                            ],
                          );
                        }).toList(),
                        CupertinoListTile(
                            title: IconButton(
                          onPressed: _addDynamicInput,
                          icon: Icon(
                            CupertinoIcons.add,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
