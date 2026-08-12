import 'package:flutter/cupertino.dart';
import 'package:roominventory/services/supabase_service.dart';
import '../../classes/connectionState.dart';
import '../../classes/dmxChannel.dart';

class DMXConfigController {
  static const firstAreaRows = ['A', 'B', 'C', 'D', 'E'];
  static const firstAreaCols = 12;
  static const secondAreaRows = 2;
  static const secondAreaCols = 12;
  static const secondAreaRowLabels = ['1', '2'];

  List channels = [];
  final Map connections = {};
  String? connectingFrom;

  List<List<connectionState>> firstAreaStates = List.generate(
    firstAreaRows.length,
    (_) => List.filled(firstAreaCols, connectionState.disconnected),
  );

  List<List<connectionState>> secondAreaStates = List.generate(
    secondAreaRows,
    (_) => List.filled(secondAreaCols, connectionState.disconnected),
  );

  bool isLoading = true;
  String errorMessage = '';

  Future<void> loadChannels() async {
    try {
      isLoading = true;
      errorMessage = '';

      final channelsJson = await SupabaseService.getChannelsWithConnections();
      debugPrint('DMX Raw data count: ${channelsJson.length}');

      channels = [];

      for (var i = 0; i < channelsJson.length; i++) {
        final json = channelsJson[i];

        if (json['idchannel'] == null) {
          debugPrint('DMX Skip [$i]: null idchannel');
          continue;
        }

        final position = json['position'];
        if (position == null ||
            position.toString() == 'null' ||
            position.toString().isEmpty) {
          debugPrint('DMX Skip [$i]: invalid position');
          continue;
        }

        try {
          final channel = DMXChannel.fromJson(json);
          channels.add(channel);
        } catch (e, stack) {
          debugPrint('DMX Error parsing channel [$i]: $e');
          debugPrint('$stack');
        }
      }

      debugPrint('DMX Valid channels loaded: ${channels.length}');
      _updateChannelStates();
    } catch (e, stack) {
      errorMessage = 'Connection error: $e';
      debugPrint('DMX load error: $e');
      debugPrint('$stack');
      channels = [];
    } finally {
      isLoading = false;
    }
  }

  Future<bool> saveConfiguration() async {
    try {
      for (final channel in channels) {
        final parts = channel.position?.toString().split('_') ?? [];
        if (parts.length < 2) continue;

        if (parts[0] == 'FX' && parts[1].length >= 2) {
          final rowLetter = parts[1][0];
          final colStr = parts[1].substring(1);
          if (colStr == 'null') continue;

          final colNumber = int.tryParse(colStr) ?? 0;
          final rowIndex = firstAreaRows.indexOf(rowLetter);

          if (rowIndex >= 0 && colNumber >= 1 && colNumber <= firstAreaCols) {
            channel.state = firstAreaStates[rowIndex][colNumber - 1]
                .toString()
                .split('.')
                .last;
          }
        } else if (parts[0] == 'DMX') {
          final dmxParts = parts[1].split('_');
          if (dmxParts.length == 2) {
            final rowStr = dmxParts[0].substring(1);
            final colStr = dmxParts[1];
            if (rowStr == 'null' || colStr == 'null') continue;

            final rowNumber = int.tryParse(rowStr) ?? 0;
            final colNumber = int.tryParse(colStr) ?? 0;

            if (rowNumber >= 1 &&
                rowNumber <= secondAreaRows &&
                colNumber >= 1 &&
                colNumber <= secondAreaCols) {
              channel.state = secondAreaStates[rowNumber - 1][colNumber - 1]
                  .toString()
                  .split('.')
                  .last;
            }
          }
        }
      }

      final payload = {
        'states': {
          for (final channel in channels) channel.id.toString(): channel.state
        },
        'connections': [
          for (final entry in connections.entries)
            if ((entry.key.startsWith('first_') &&
                entry.value.startsWith('second_')))
              {
                'source': _getChannelIdFromKey(entry.key),
                'target': _getChannelIdFromKey(entry.value),
              }
        ],
      };

      return await SupabaseService.saveChannelsConfig(payload);
    } catch (e, stack) {
      errorMessage = 'Failed to save: $e';
      debugPrint('DMX save error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  int _getChannelIdFromKey(String key) {
    final parts = key.split('_');
    if (parts.length < 3) throw FormatException('Invalid key format: $key');

    if (parts[0] == 'first') {
      final position = 'FX_${parts[1]}${parts[2]}';
      return channels
          .firstWhere((c) => c.position == position,
              orElse: () => throw Exception('Channel $position not found'))
          .id;
    } else if (parts[0] == 'second') {
      final position = 'DMX_R${parts[1]}_${parts[2]}';
      return channels
          .firstWhere((c) => c.position == position,
              orElse: () => throw Exception('Channel $position not found'))
          .id;
    }
    throw FormatException('Unknown key type: $key');
  }

  void _updateChannelStates() {
    firstAreaStates = List.generate(
      firstAreaRows.length,
      (_) => List.filled(firstAreaCols, connectionState.disconnected),
    );
    secondAreaStates = List.generate(
      secondAreaRows,
      (_) => List.filled(secondAreaCols, connectionState.disconnected),
    );
    connections.clear();

    for (final channel in channels) {
      final position = channel.position?.toString() ?? '';
      final stateStr = channel.state?.toString() ?? '';
      final connStr = channel.connections?.toString() ?? '';

      if (position.isEmpty || position == 'null') continue;

      final parts = position.split('_');
      if (parts.length < 2) continue;

      if (parts[0] == 'FX' && parts[1].length >= 2) {
        final rowLetter = parts[1][0];
        final colStr = parts[1].substring(1);
        if (colStr == 'null') continue;

        final colNumber = int.tryParse(colStr) ?? 0;
        final rowIndex = firstAreaRows.indexOf(rowLetter);

        if (rowIndex >= 0 && colNumber >= 1 && colNumber <= firstAreaCols) {
          firstAreaStates[rowIndex][colNumber - 1] = _parseState(stateStr);
        }
      } else if (parts[0] == 'DMX') {
        final dmxParts = parts[1].split('_');
        if (dmxParts.length == 2) {
          final rowStr = dmxParts[0].substring(1);
          final colStr = dmxParts[1];
          if (rowStr == 'null' || colStr == 'null') continue;

          final rowNumber = int.tryParse(rowStr) ?? 0;
          final colNumber = int.tryParse(colStr) ?? 0;

          if (rowNumber >= 1 &&
              rowNumber <= secondAreaRows &&
              colNumber >= 1 &&
              colNumber <= secondAreaCols) {
            secondAreaStates[rowNumber - 1][colNumber - 1] =
                _parseState(stateStr);
          }
        }
      }

      if (connStr.isNotEmpty && connStr != 'null') {
        final connParts = connStr.split('→');
        if (connParts.length == 2) {
          if (connParts[1].startsWith('DMX_R')) {
            final fx = connParts[0].replaceAll("FX_", "");
            final dmx = connParts[1].replaceAll("DMX_R", "");
            if (fx.isEmpty || dmx.isEmpty) continue;

            final fxRow = fx[0];
            final fxCol = fx.substring(1);
            final dmxParts = dmx.split('_');
            if (dmxParts.length < 2) continue;

            final dmxRow = dmxParts[0];
            final dmxCol = dmxParts[1];
            final source = 'first_${fxRow}_$fxCol';
            final target = 'second_${dmxRow}_$dmxCol';
            connections[source] = target;
          }
        }
      }
    }
  }

  connectionState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'connected':
        return connectionState.connected;
      case 'broken':
        return connectionState.broken;
      default:
        return connectionState.disconnected;
    }
  }

  void handleFirstAreaTap(int row, int col) {
    final key = 'first_${firstAreaRows[row]}_${col + 1}';

    if (connectingFrom != null) {
      if (connectingFrom == key) {
        connectingFrom = null;
        return;
      }

      // Se a origem é do second area, faz a conexão
      if (connectingFrom!.startsWith('second_')) {
        final sourceKey = key;
        final targetKey = connectingFrom!;

        final sParts = sourceKey.split('_');
        final sRow = firstAreaRows.indexOf(sParts[1]);
        final sCol = int.parse(sParts[2]) - 1;
        firstAreaStates[sRow][sCol] = connectionState.connected;

        final tParts = targetKey.split('_');
        final tRow = int.parse(tParts[1]) - 1;
        final tCol = int.parse(tParts[2]) - 1;
        secondAreaStates[tRow][tCol] = connectionState.connected;

        connections[sourceKey] = targetKey;
        connectingFrom = null;
        return;
      }

      connectingFrom = null;
      return;
    }

    if (connections.containsKey(key)) {
      connections.remove(key);
      firstAreaStates[row][col] = connectionState.disconnected;
    } else {
      firstAreaStates[row][col] =
          firstAreaStates[row][col] == connectionState.disconnected
              ? connectionState.broken
              : connectionState.disconnected;
    }
  }

  void handleSecondAreaTap(int row, int col) {
    final key = 'second_${row + 1}_${col + 1}';

    if (connectingFrom != null) {
      if (connectingFrom == key) {
        connectingFrom = null;
        return;
      }

      // Se a origem é do first area, faz a conexão
      if (connectingFrom!.startsWith('first_')) {
        final sourceParts = connectingFrom!.split('_');
        final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
        final sourceCol = int.parse(sourceParts[2]) - 1;
        firstAreaStates[sourceRow][sourceCol] = connectionState.connected;
        secondAreaStates[row][col] = connectionState.connected;
        connections[connectingFrom!] = key;
        connectingFrom = null;
        return;
      }

      connectingFrom = null;
      return;
    }

    if (connections.containsValue(key)) {
      final toRemove = connections.entries.firstWhere((e) => e.value == key);
      final sourceParts = toRemove.key.split('_');
      final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
      final sourceCol = int.parse(sourceParts[2]) - 1;
      firstAreaStates[sourceRow][sourceCol] = connectionState.disconnected;
      connections.remove(toRemove.key);
      secondAreaStates[row][col] = connectionState.disconnected;
    } else {
      secondAreaStates[row][col] =
          secondAreaStates[row][col] == connectionState.disconnected
              ? connectionState.broken
              : connectionState.disconnected;
    }
  }

  void startConnectionProcess(String key, int row, int col) {
    if (connectingFrom == key) {
      connectingFrom = null;
      return;
    }

    final area = key.split('_')[0];
    if (area == 'first') {
      if (firstAreaStates[row][col] == connectionState.broken) return;
      if (connections.containsKey(key)) return;
    } else {
      if (secondAreaStates[row][col] == connectionState.broken) return;
      if (connections.containsValue(key)) return;
    }
    connectingFrom = key;
  }
}
