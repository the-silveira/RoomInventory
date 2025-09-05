import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../classes/connectionState.dart';
import '../../classes/dmxChannel.dart';

/// Controller class for managing DMX configuration and connections.
///
/// This class handles loading DMX channels from an API, managing connection states,
/// and saving configurations back to the server. It manages two distinct areas:
/// - First area with lettered rows (A-E) and 12 columns
/// - Second area with numbered rows (1-2) and 12 columns
class DMXConfigController {
  /// Configuration constants for the first area (FX channels)
  static const firstAreaRows = ['A', 'B', 'C', 'D', 'E'];

  /// Number of columns in the first area
  static const firstAreaCols = 12;

  /// Configuration constants for the second area (DMX channels)
  static const secondAreaRows = 2;

  /// Number of columns in the second area
  static const secondAreaCols = 12;

  /// Row labels for the second area
  static const secondAreaRowLabels = ['1', '2'];

  /// List of DMX channels loaded from the API
  List<DMXChannel> channels = [];

  /// Map of active connections between first and second area channels
  ///
  /// Keys are in format 'first_[row]_[col]', values are in format 'second_[row]_[col]'
  final Map<String, String> connections = {};

  /// Temporary storage for the starting point of a connection being created
  String? connectingFrom;

  /// 2D list representing connection states for the first area
  ///
  /// Dimensions: [firstAreaRows.length] x [firstAreaCols]
  List<List<ConnectionState>> firstAreaStates = List.generate(
    firstAreaRows.length,
    (_) => List.filled(firstAreaCols, ConnectionState.disconnected),
  );

  /// 2D list representing connection states for the second area
  ///
  /// Dimensions: [secondAreaRows] x [secondAreaCols]
  List<List<ConnectionState>> secondAreaStates = List.generate(
    secondAreaRows,
    (_) => List.filled(secondAreaCols, ConnectionState.disconnected),
  );

  /// Loading state indicator
  bool isLoading = true;

  /// Error message for any operation failures
  String errorMessage = '';

  /// Loads DMX channels from the API endpoint.
  ///
  /// Makes a POST request to retrieve channel data and updates internal state
  /// based on the response. Handles both successful and failed responses.
  ///
  /// Throws:
  ///   - HttpException if the API request fails
  ///   - FormatException if the response JSON is malformed
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

  /// Saves the current configuration to the API.
  ///
  /// Updates channel states from the UI, prepares the payload, and sends it
  /// to the server. Returns true if the operation was successful.
  ///
  /// Returns:
  ///   - `true` if the configuration was saved successfully
  ///   - `false` if the operation failed
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

  /// Converts a UI key to the corresponding channel ID.
  ///
  /// Parses keys in the format 'first_[row]_[col]' or 'second_[row]_[col]'
  /// and finds the matching channel ID from the loaded channels list.
  ///
  /// Parameters:
  ///   - `key`: The UI key to convert (e.g., 'first_A_1', 'second_1_5')
  ///
  /// Returns:
  ///   - The channel ID as an integer
  ///
  /// Throws:
  ///   - FormatException if the key format is invalid
  ///   - Exception if no matching channel is found
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

  /// Updates internal state from loaded channel data.
  ///
  /// Resets all states and repopulates them based on the current channel data,
  /// including parsing existing connections from the server response.
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

  /// Parses a string state into a ConnectionState enum value.
  ///
  /// Parameters:
  ///   - `state`: The string representation of the state
  ///
  /// Returns:
  ///   - ConnectionState.connected for 'connected'
  ///   - ConnectionState.broken for 'broken'
  ///   - ConnectionState.disconnected for any other value
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

  /// Handles tap events on the first area grid.
  ///
  /// Manages state toggling and connection initiation for FX channels.
  ///
  /// Parameters:
  ///   - `row`: The row index (0-based) of the tapped cell
  ///   - `col`: The column index (0-based) of the tapped cell
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

  /// Handles tap events on the second area grid.
  ///
  /// Manages state toggling, connection completion, and connection removal
  /// for DMX channels.
  ///
  /// Parameters:
  ///   - `row`: The row index (0-based) of the tapped cell
  ///   - `col`: The column index (0-based) of the tapped cell
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

  /// Initiates a connection process from a specific cell.
  ///
  /// Stores the starting point for a connection that will be completed
  /// when the user taps a target cell.
  ///
  /// Parameters:
  ///   - `key`: The UI key of the starting cell
  ///   - `row`: The row index of the starting cell
  ///   - `col`: The column index of the starting cell
  void startConnectionProcess(String key, int row, int col) {
    if (firstAreaStates[row][col] == ConnectionState.broken) return;
    connectingFrom = key;
  }
}
