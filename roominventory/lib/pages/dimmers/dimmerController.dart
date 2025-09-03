import 'package:http/http.dart' as http;
import 'dart:convert';

import '../classes/ConnectionState.dart';
import '../classes/DMXChannel.dart';

class DMXConfigController {
  // Configuration
  static const firstAreaRows = ['A', 'B', 'C', 'D', 'E'];
  static const firstAreaCols = 12;
  static const secondAreaRows = 2;
  static const secondAreaCols = 12;
  static const secondAreaRowLabels = ['1', '2'];

  // State
  List<DMXChannel> channels = [];
  final Map<String, String> connections = {};
  String? connectingFrom;
  List<List<ConnectionState>> firstAreaStates = List.generate(
    firstAreaRows.length,
    (_) => List.filled(firstAreaCols, ConnectionState.disconnected),
  );
  List<List<ConnectionState>> secondAreaStates = List.generate(
    secondAreaRows,
    (_) => List.filled(secondAreaCols, ConnectionState.disconnected),
  );
  bool isLoading = true;
  String errorMessage = '';

  // Load channels from API
  Future<void> loadChannels() async {
    try {
      isLoading = true;
      errorMessage = '';

      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'C1'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final channelsJson = json.decode(decodedBody) as List;

        channels =
            channelsJson.map((json) => DMXChannel.fromJson(json)).toList();
        _updateChannelStates();
      } else {
        errorMessage = 'Failed to load channels: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error loading channels: $e';
    } finally {
      isLoading = false;
    }
  }

  // Save configuration to API
  Future<bool> saveConfiguration() async {
    try {
      // Update channel states from UI
      for (final channel in channels) {
        final parts = channel.position.split('_');
        if (parts.length < 2) continue;

        if (parts[0] == 'FX' && parts[1].length >= 2) {
          final rowLetter = parts[1][0];
          final colNumber = int.tryParse(parts[1].substring(1)) ?? 0;
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
            final rowNumber = int.tryParse(dmxParts[0].substring(1)) ?? 0;
            final colNumber = int.tryParse(dmxParts[1]) ?? 0;

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
        'query_param': 'C2',
        'data': {
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
        },
      };

      // Send to API
      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      // Handle response
      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          errorMessage = 'Server returned empty response.';
          return false;
        }
        final result = json.decode(response.body);
        return result['success'] == true;
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to save: $e';
      return false;
    }
  }

  int _getChannelIdFromKey(String key) {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  void _updateChannelStates() {
    // Reset all states
    firstAreaStates = List.generate(
      firstAreaRows.length,
      (_) => List.filled(firstAreaCols, ConnectionState.disconnected),
    );
    secondAreaStates = List.generate(
      secondAreaRows,
      (_) => List.filled(secondAreaCols, ConnectionState.disconnected),
    );
    connections.clear();

    // Update from loaded channels
    for (final channel in channels) {
      final parts = channel.position.split('_');
      if (parts.length < 2) continue;

      if (parts[0] == 'FX' && parts[1].length >= 2) {
        final rowLetter = parts[1][0];
        final colNumber = int.tryParse(parts[1].substring(1)) ?? 0;
        final rowIndex = firstAreaRows.indexOf(rowLetter);

        if (rowIndex >= 0 && colNumber >= 1 && colNumber <= firstAreaCols) {
          firstAreaStates[rowIndex][colNumber - 1] = _parseState(channel.state);
        }
      } else if (parts[0] == 'DMX') {
        final dmxParts = parts[1].split('_');
        if (dmxParts.length == 2) {
          final rowNumber = int.tryParse(dmxParts[0].substring(1)) ?? 0;
          final colNumber = int.tryParse(dmxParts[1]) ?? 0;

          if (rowNumber >= 1 &&
              rowNumber <= secondAreaRows &&
              colNumber >= 1 &&
              colNumber <= secondAreaCols) {
            secondAreaStates[rowNumber - 1][colNumber - 1] =
                _parseState(channel.state);
          }
        }
      }

      if (channel.connections.isNotEmpty) {
        final connParts = channel.connections.split('→');
        if (connParts.length == 2) {
          if (connParts[1].startsWith('DMX_R')) {
            final fx = connParts[0].replaceAll("FX_", "");
            final dmx = connParts[1].replaceAll("DMX_R", "");
            final fxRow = fx[0];
            final fxCol = fx.substring(1);
            final dmxParts = dmx.split('_');
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

  ConnectionState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'connected':
        return ConnectionState.connected;
      case 'broken':
        return ConnectionState.broken;
      default:
        return ConnectionState.disconnected;
    }
  }

  void handleFirstAreaTap(int row, int col) {
    final key = 'first_${firstAreaRows[row]}_${col + 1}';

    if (connectingFrom != null) {
      connectingFrom = null;
      return;
    }

    if (connections.containsKey(key)) {
      connections.remove(key);
      firstAreaStates[row][col] = ConnectionState.disconnected;
    } else {
      firstAreaStates[row][col] =
          firstAreaStates[row][col] == ConnectionState.disconnected
              ? ConnectionState.broken
              : ConnectionState.disconnected;
    }
  }

  void handleSecondAreaTap(int row, int col) {
    final key = 'second_${row + 1}_${col + 1}';

    if (connectingFrom != null) {
      if (connectingFrom!.startsWith('first_')) {
        final sourceParts = connectingFrom!.split('_');
        final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
        final sourceCol = int.parse(sourceParts[2]) - 1;
        firstAreaStates[sourceRow][sourceCol] = ConnectionState.connected;
        secondAreaStates[row][col] = ConnectionState.connected;
        connections[connectingFrom!] = key;
      }
      connectingFrom = null;
      return;
    }

    if (connections.containsValue(key)) {
      final toRemove = connections.entries.firstWhere((e) => e.value == key);
      final sourceParts = toRemove.key.split('_');
      final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
      final sourceCol = int.parse(sourceParts[2]) - 1;
      firstAreaStates[sourceRow][sourceCol] = ConnectionState.disconnected;
      connections.remove(toRemove.key);
      secondAreaStates[row][col] = ConnectionState.disconnected;
    } else {
      secondAreaStates[row][col] =
          secondAreaStates[row][col] == ConnectionState.disconnected
              ? ConnectionState.broken
              : ConnectionState.disconnected;
    }
  }

  void startConnectionProcess(String key, int row, int col) {
    if (firstAreaStates[row][col] == ConnectionState.broken) return;
    connectingFrom = key;
  }
}
