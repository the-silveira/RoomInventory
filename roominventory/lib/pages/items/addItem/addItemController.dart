import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class AddItemController {
  final TextEditingController idItemController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController condicaoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController tamanhoController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();

  List<dynamic> places = [];
  List<dynamic> zones = [];
  List<dynamic> filteredZones = [];
  String? selectedPlace;
  String? selectedZone;
  DateTime? ultimaVerificacaoDate;

  final List<Map<String, String>> detailsList = [];
  final List<Map<String, TextEditingController>> dynamicInputs = [];

  bool isLoading = true;
  String errorMessage = '';

  // Fetch places and zones data
  Future<void> fetchData() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'P1'},
      );

      if (response.statusCode == 200) {
        places = json.decode(response.body);
      }

      response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'Z1'},
      );

      if (response.statusCode == 200) {
        zones = json.decode(response.body);
        filteredZones = zones;
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
    }
  }

  // Filter zones based on selected place
  void filterZones(String? placeId) {
    filteredZones = placeId == null
        ? zones
        : zones.where((zone) => zone['FK_IdPlace'] == placeId).toList();
    selectedZone = null;
  }

  // Add dynamic input field
  void addDynamicInput() {
    dynamicInputs.add({
      'detalhe': TextEditingController(),
      'detalheName': TextEditingController(),
    });
  }

  // Remove dynamic input field
  void removeDynamicInput(int index) {
    dynamicInputs[index]['detalhe']?.dispose();
    dynamicInputs[index]['detalheName']?.dispose();
    dynamicInputs.removeAt(index);
  }

  // Save item to database
  Future<bool> saveItem() async {
    // Add static details to detailsList
    detailsList.add({
      'Marca': marcaController.text,
      'Tipo': tipoController.text,
      'Quantidade': quantidadeController.text,
      'Condição': condicaoController.text,
      'Tamanho': tamanhoController.text,
      'Última Verificação': ultimaVerificacaoDate != null
          ? '${ultimaVerificacaoDate!.day}/${ultimaVerificacaoDate!.month}/${ultimaVerificacaoDate!.year}'
          : '',
    });

    try {
      // Save main item
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {
          'query_param': 'I2',
          'IdItem': idItemController.text,
          'ItemName': itemNameController.text,
          'FK_IdZone': selectedZone,
        },
      );

      if (response.statusCode != 200) {
        errorMessage = 'Failed to save item';
        return false;
      }

      var responseData = json.decode(response.body);
      if (responseData['status'] != 'success') {
        errorMessage =
            responseData['message'] ?? 'ID do Item já existe. Tente novamente';
        return false;
      }

      // Save static details
      for (var detail in detailsList) {
        detail.forEach((key, value) async {
          await http.post(
            Uri.parse(
                'https://services.interagit.com/API/roominventory/api_ri.php'),
            body: {
              'query_param': 'D1',
              'DetailsName': key,
              'Details': value,
              'FK_IdItem': idItemController.text,
            },
          );
        });
      }

      // Save dynamic details
      for (var input in dynamicInputs) {
        await http.post(
          Uri.parse(
              'https://services.interagit.com/API/roominventory/api_ri.php'),
          body: {
            'query_param': 'D1',
            'DetailsName': input['detalhe']!.text,
            'Details': input['detalheName']!.text,
            'FK_IdItem': idItemController.text,
          },
        );
      }

      return true;
    } catch (e) {
      errorMessage = 'Erro Inesperado. Tente novamente: $e';
      return false;
    }
  }

  // Dispose all controllers
  void dispose() {
    idItemController.dispose();
    itemNameController.dispose();
    marcaController.dispose();
    condicaoController.dispose();
    quantidadeController.dispose();
    tamanhoController.dispose();
    tipoController.dispose();

    for (var input in dynamicInputs) {
      input['detalhe']?.dispose();
      input['detalheName']?.dispose();
    }
  }
}
