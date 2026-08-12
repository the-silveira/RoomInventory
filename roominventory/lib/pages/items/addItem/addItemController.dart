import 'package:flutter/cupertino.dart';
import 'package:roominventory/services/supabase_service.dart';

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

  Future<void> fetchData() async {
    try {
      isLoading = true;
      errorMessage = '';

      places = await SupabaseService.getPlaces();
      zones = await SupabaseService.getZones();
      filteredZones = zones;
    } catch (e) {
      errorMessage = 'Connection error: $e';
    } finally {
      isLoading = false;
    }
  }

  void filterZones(String? placeId) {
    if (placeId == null || placeId.isEmpty) {
      filteredZones = zones;
    } else {
      filteredZones = zones.where((zone) {
        final zonePlaceId = zone['fk_idplace']?.toString() ??
            zone['FK_IdPlace']?.toString() ??
            zone['places']?['idplace']?.toString() ??
            '';
        return zonePlaceId == placeId;
      }).toList();
    }
    selectedZone = null;
  }

  void addDynamicInput() {
    dynamicInputs.add({
      'detalhe': TextEditingController(),
      'detalheName': TextEditingController(),
    });
  }

  void removeDynamicInput(int index) {
    dynamicInputs[index]['detalhe']?.dispose();
    dynamicInputs[index]['detalheName']?.dispose();
    dynamicInputs.removeAt(index);
  }

  Future<bool> saveItem() async {
    if (idItemController.text.isEmpty) {
      errorMessage = 'Please enter the item ID';
      return false;
    }
    if (itemNameController.text.isEmpty) {
      errorMessage = 'Please enter the item name';
      return false;
    }
    if (selectedZone == null || selectedZone!.isEmpty) {
      errorMessage = 'Please select a zone';
      return false;
    }

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
      final itemData = {
        'iditem': idItemController.text,
        'itemname': itemNameController.text,
        'fk_idzone': selectedZone!,
      };

      final allDetails = <Map<String, dynamic>>[];

      for (var detail in detailsList) {
        for (var entry in detail.entries) {
          if (entry.value.isNotEmpty) {
            allDetails.add({
              'detailsname': entry.key,
              'details': entry.value,
              'fk_iditem': idItemController.text,
            });
          }
        }
      }

      for (var input in dynamicInputs) {
        final detalheText = input['detalhe']?.text ?? '';
        final detalheNameText = input['detalheName']?.text ?? '';
        if (detalheText.isNotEmpty && detalheNameText.isNotEmpty) {
          allDetails.add({
            'detailsname': detalheText,
            'details': detalheNameText,
            'fk_iditem': idItemController.text,
          });
        }
      }

      await SupabaseService.insertItem(itemData, allDetails);
      return true;
    } catch (e) {
      errorMessage = 'Erro Inesperado. Tente novamente: $e';
      return false;
    }
  }

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
