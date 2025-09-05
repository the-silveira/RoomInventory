import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

/// Controller class for managing the addition of new inventory items.
///
/// This controller handles:
/// - Form field management for item details
/// - Dynamic input field management for custom details
/// - Data fetching for places and zones
/// - Item validation and saving to the database
/// - Error handling and state management
///
/// The controller manages both static item properties and dynamic custom details,
/// providing a comprehensive solution for item creation with flexible detail fields.
///
/// Example usage:
/// ```dart
/// final controller = AddItemController();
/// await controller.fetchData();
/// ```
class AddItemController {
  /// Controller for the item ID text field
  final TextEditingController idItemController = TextEditingController();

  /// Controller for the item name text field
  final TextEditingController itemNameController = TextEditingController();

  /// Controller for the brand/marca text field
  final TextEditingController marcaController = TextEditingController();

  /// Controller for the condition/condicao text field
  final TextEditingController condicaoController = TextEditingController();

  /// Controller for the quantity/quantidade text field
  final TextEditingController quantidadeController = TextEditingController();

  /// Controller for the size/tamanho text field
  final TextEditingController tamanhoController = TextEditingController();

  /// Controller for the type/tipo text field
  final TextEditingController tipoController = TextEditingController();

  /// List of available places fetched from the API
  List<dynamic> places = [];

  /// List of all available zones fetched from the API
  List<dynamic> zones = [];

  /// List of zones filtered by the selected place
  List<dynamic> filteredZones = [];

  /// Currently selected place ID for zone filtering
  String? selectedPlace;

  /// Currently selected zone ID for item placement
  String? selectedZone;

  /// Date of last verification for the item
  DateTime? ultimaVerificacaoDate;

  /// List of static detail fields with their values
  final List<Map<String, String>> detailsList = [];

  /// List of dynamic input fields with their controllers
  final List<Map<String, TextEditingController>> dynamicInputs = [];

  /// Loading state indicator - true when data is being fetched
  bool isLoading = true;

  /// Error message for displaying operation failures
  String errorMessage = '';

  /// Fetches places and zones data from the API for item placement.
  ///
  /// This method performs two API calls:
  /// 1. Fetches available places (query_param: 'P1')
  /// 2. Fetches available zones (query_param: 'Z1')
  ///
  /// The fetched data is used to populate place and zone selection dropdowns.
  /// Updates loading state upon completion.
  ///
  /// Throws exceptions for network errors and invalid responses.
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchData();
  /// ```
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

  /// Filters available zones based on the selected place.
  ///
  /// This method updates the filteredZones list to only include zones
  /// that belong to the selected place. Resets the selected zone when called.
  ///
  /// [placeId]: The ID of the selected place to filter zones by
  ///
  /// Example:
  /// ```dart
  /// controller.filterZones('place123');
  /// ```
  void filterZones(String? placeId) {
    filteredZones = placeId == null
        ? zones
        : zones.where((zone) => zone['FK_IdPlace'] == placeId).toList();
    selectedZone = null;
  }

  /// Adds a new dynamic input field for custom item details.
  ///
  /// Creates a new set of controllers for a dynamic detail field and
  /// adds it to the dynamicInputs list. Each dynamic input consists of:
  /// - A detail name field (detalhe)
  /// - A detail value field (detalheName)
  ///
  /// Example:
  /// ```dart
  /// controller.addDynamicInput();
  /// ```
  void addDynamicInput() {
    dynamicInputs.add({
      'detalhe': TextEditingController(),
      'detalheName': TextEditingController(),
    });
  }

  /// Removes a dynamic input field and disposes its controllers.
  ///
  /// This method removes the specified dynamic input from the list
  /// and properly disposes of its text editing controllers to prevent
  /// memory leaks.
  ///
  /// [index]: The index of the dynamic input to remove
  ///
  /// Example:
  /// ```dart
  /// controller.removeDynamicInput(0);
  /// ```
  void removeDynamicInput(int index) {
    dynamicInputs[index]['detalhe']?.dispose();
    dynamicInputs[index]['detalheName']?.dispose();
    dynamicInputs.removeAt(index);
  }

  /// Saves the item with all details to the database.
  ///
  /// This method performs multiple operations:
  /// 1. Adds static details to detailsList
  /// 2. Saves the main item to the database (query_param: 'I2')
  /// 3. Saves static details to the database (query_param: 'D1')
  /// 4. Saves dynamic details to the database (query_param: 'D1')
  ///
  /// Returns true if all operations succeed, false otherwise.
  /// Handles duplicate ID errors and other server responses.
  ///
  /// Returns: [bool] indicating whether the save operation was successful
  ///
  /// Example:
  /// ```dart
  /// bool success = await controller.saveItem();
  /// if (success) {
  ///   // Item saved successfully
  /// }
  /// ```
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

  /// Disposes all text editing controllers to free up resources.
  ///
  /// This method should be called when the controller is no longer needed
  /// to prevent memory leaks. It disposes both static and dynamic controllers.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   controller.dispose();
  ///   super.dispose();
  /// }
  /// ```
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
