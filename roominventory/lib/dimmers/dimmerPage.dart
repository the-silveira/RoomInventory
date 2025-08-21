import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roominventory/appbar/appbar_back.dart';
import 'dart:convert';

/// Data Models
class DMXChannel {
  final int id;
  final String position;
  final String type;
  String state;
  final String connections;

  DMXChannel(this.id, this.position, this.type, this.state, this.connections);

  factory DMXChannel.fromJson(Map<String, dynamic> json) {
    return DMXChannel(
      int.parse(json['IdChannel'].toString()),
      json['Position'].toString(),
      json['Type'].toString(),
      json['State'].toString(),
      json['Connections']?.toString() ?? '',
    );
  }
}

enum ConnectionState { disconnected, connected, broken }

/// Main Page
class DMXConfigPage extends StatefulWidget {
  const DMXConfigPage({super.key});

  @override
  State<DMXConfigPage> createState() => _DMXConfigPageState();
}

class _DMXConfigPageState extends State<DMXConfigPage>
    with SingleTickerProviderStateMixin {
  // Configuration
  static const firstAreaRows = ['A', 'B', 'C', 'D', 'E'];
  static const firstAreaCols = 12;
  static const secondAreaRows = 2;
  static const secondAreaCols = 12;
  static const secondAreaRowLabels = ['1', '2'];

  // State
  late AnimationController _blinkController;
  List<DMXChannel> _channels = [];
  final Map<String, String> _connections = {};
  String? _connectingFrom;
  List<List<ConnectionState>> _firstAreaStates = List.generate(
    firstAreaRows.length,
    (_) => List.filled(firstAreaCols, ConnectionState.disconnected),
  );
  List<List<ConnectionState>> _secondAreaStates = List.generate(
    secondAreaRows,
    (_) => List.filled(secondAreaCols, ConnectionState.disconnected),
  );
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _loadChannels();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'C1'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final channelsJson = json.decode(decodedBody) as List;

        setState(() {
          _channels =
              channelsJson.map((json) => DMXChannel.fromJson(json)).toList();
          _updateChannelStates();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load channels: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading channels: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      // Update channel states from UI
      for (final channel in _channels) {
        final parts = channel.position.split('_');
        if (parts.length < 2) continue;

        if (parts[0] == 'FX' && parts[1].length >= 2) {
          final rowLetter = parts[1][0];
          final colNumber = int.tryParse(parts[1].substring(1)) ?? 0;
          final rowIndex = firstAreaRows.indexOf(rowLetter);

          if (rowIndex >= 0 && colNumber >= 1 && colNumber <= firstAreaCols) {
            channel.state = _firstAreaStates[rowIndex][colNumber - 1]
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
              channel.state = _secondAreaStates[rowNumber - 1][colNumber - 1]
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
            for (final channel in _channels)
              channel.id.toString(): channel.state
          },
          'connections': [
            for (final entry in _connections.entries)
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
          _showError('Server returned empty response.');
          return;
        }
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _showSuccess('Configuration saved successfully!');
          await _loadChannels(); // Refresh data
        } else {
          _showError('Save failed: ${result['error'] ?? 'Unknown error'}');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to save: $e');
    }
  }

  int _getChannelIdFromKey(String key) {
    try {
      final parts = key.split('_');
      if (parts.length < 3) throw FormatException('Invalid key format: $key');

      if (parts[0] == 'first') {
        // Handle fixture channels (first_A_1 → FX_A1)
        final position = 'FX_${parts[1]}${parts[2]}';
        return _channels
            .firstWhere((c) => c.position == position,
                orElse: () => throw Exception('Channel $position not found'))
            .id;
      } else if (parts[0] == 'second') {
        // Handle DMX channels (second_1_1 → DMX_R1_1)
        final position = 'DMX_R${parts[1]}_${parts[2]}';
        return _channels
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
    _firstAreaStates = List.generate(
      firstAreaRows.length,
      (_) => List.filled(firstAreaCols, ConnectionState.disconnected),
    );
    _secondAreaStates = List.generate(
      secondAreaRows,
      (_) => List.filled(secondAreaCols, ConnectionState.disconnected),
    );
    _connections.clear();

    // Update from loaded channels
    for (final channel in _channels) {
      final parts = channel.position.split('_');
      if (parts.length < 2) continue;

      if (parts[0] == 'FX' && parts[1].length >= 2) {
        // Fixture channel (first area)
        final rowLetter = parts[1][0];
        final colNumber = int.tryParse(parts[1].substring(1)) ?? 0;
        final rowIndex = firstAreaRows.indexOf(rowLetter);

        if (rowIndex >= 0 && colNumber >= 1 && colNumber <= firstAreaCols) {
          _firstAreaStates[rowIndex][colNumber - 1] =
              _parseState(channel.state);
        }
      } else if (parts[0] == 'DMX') {
        // DMX channel (second area)
        final dmxParts = parts[1].split('_');
        if (dmxParts.length == 2) {
          final rowNumber = int.tryParse(dmxParts[0].substring(1)) ?? 0;
          final colNumber = int.tryParse(dmxParts[1]) ?? 0;

          if (rowNumber >= 1 &&
              rowNumber <= secondAreaRows &&
              colNumber >= 1 &&
              colNumber <= secondAreaCols) {
            _secondAreaStates[rowNumber - 1][colNumber - 1] =
                _parseState(channel.state);
          }
        }
      }

      if (channel.connections.isNotEmpty) {
        final connParts = channel.connections.split('→');
        if (connParts.length == 2) {
          // Only process if the target is a DMX channel
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
            _connections[source] = target;
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

  void _handleFirstAreaTap(int row, int col) {
    final key = 'first_${firstAreaRows[row]}_${col + 1}';

    if (_connectingFrom != null) {
      setState(() => _connectingFrom = null);
      return;
    }

    setState(() {
      if (_connections.containsKey(key)) {
        _connections.remove(key);
        _firstAreaStates[row][col] = ConnectionState.disconnected;
      } else {
        _firstAreaStates[row][col] =
            _firstAreaStates[row][col] == ConnectionState.disconnected
                ? ConnectionState.broken
                : ConnectionState.disconnected;
      }
    });
  }

  void _handleSecondAreaTap(int row, int col) {
    final key = 'second_${row + 1}_${col + 1}';

    if (_connectingFrom != null) {
      setState(() {
        // Only allow connections from first area to second area
        if (_connectingFrom!.startsWith('first_')) {
          // Update source channel state
          final sourceParts = _connectingFrom!.split('_');
          final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
          final sourceCol = int.parse(sourceParts[2]) - 1;
          _firstAreaStates[sourceRow][sourceCol] = ConnectionState.connected;

          // Update target channel state
          _secondAreaStates[row][col] = ConnectionState.connected;

          // Create connection
          _connections[_connectingFrom!] = key;
        }
        _connectingFrom = null;
      });
      return;
    }

    setState(() {
      if (_connections.containsValue(key)) {
        // Remove existing connection
        final toRemove = _connections.entries.firstWhere((e) => e.value == key);

        // Reset source channel state
        final sourceParts = toRemove.key.split('_');
        final sourceRow = firstAreaRows.indexOf(sourceParts[1]);
        final sourceCol = int.parse(sourceParts[2]) - 1;
        _firstAreaStates[sourceRow][sourceCol] = ConnectionState.disconnected;

        // Remove connection and reset target state
        _connections.remove(toRemove.key);
        _secondAreaStates[row][col] = ConnectionState.disconnected;
      } else {
        // Toggle broken/disconnected state
        _secondAreaStates[row][col] =
            _secondAreaStates[row][col] == ConnectionState.disconnected
                ? ConnectionState.broken
                : ConnectionState.disconnected;
      }
    });
  }

  void _startConnectionProcess(String key, int row, int col) {
    if (_firstAreaStates[row][col] == ConnectionState.broken) return;
    setState(() => _connectingFrom = key);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AddNavigationBar(
        title: 'Dimmers',
        previousPageTitle: 'Inventário',
        onAddPressed: _saveConfiguration,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                      : Expanded(
                          child: CupertinoScrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fixture Outputs - iOS Style
                                  CupertinoListSection.insetGrouped(
                                    header: Text(
                                      "Barramento de Palco",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    children: [
                                      _buildIOSPortGrid(
                                        rowLabels: firstAreaRows,
                                        columns: firstAreaCols,
                                        states: _firstAreaStates,
                                        isSource: true,
                                      ),
                                    ],
                                  ),

                                  // DMX Outputs - iOS Style
                                  CupertinoListSection.insetGrouped(
                                    header: Text(
                                      "Outputs DMX",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    children: [
                                      _buildIOSPortGrid(
                                        rowLabels: secondAreaRowLabels,
                                        columns: secondAreaCols,
                                        states: _secondAreaStates,
                                        isSource: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSPortGrid({
    required List<String> rowLabels,
    required int columns,
    required List<List<ConnectionState>> states,
    required bool isSource,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 8), // ← Added horizontal padding
      child: Column(
        children: rowLabels.map((label) {
          final rowIndex = rowLabels.indexOf(label);
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Ports Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2), // ← Added padding to the row
                  child: Row(
                    children: List.generate(columns, (colIndex) {
                      final portNumber = colIndex + 1;
                      final key = isSource
                          ? 'first_${label}_$portNumber'
                          : 'second_${label}_$portNumber';
                      final isConnected = isSource
                          ? _connections.containsKey(key)
                          : _connections.containsValue(key);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2), // ← Increased horizontal padding
                          child: GestureDetector(
                            onTap: () => isSource
                                ? _handleFirstAreaTap(rowIndex, colIndex)
                                : _handleSecondAreaTap(rowIndex, colIndex),
                            onLongPress: isSource
                                ? () => _startConnectionProcess(
                                    key, rowIndex, colIndex)
                                : null,
                            child: Container(
                              height: 40, // ← Slightly increased height
                              decoration: BoxDecoration(
                                color: _getPortColor(
                                    states[rowIndex][colIndex], isConnected),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$portNumber',
                                  style: TextStyle(
                                    color: _getPortTextColor(
                                        states[rowIndex][colIndex],
                                        isConnected),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getPortColor(ConnectionState state, bool isConnected) {
    if (isConnected) return Theme.of(context).colorScheme.primary;
    switch (state) {
      case ConnectionState.connected:
        return Theme.of(context).colorScheme.tertiary;
      case ConnectionState.disconnected:
        return Theme.of(context).colorScheme.surfaceContainerLowest;
      case ConnectionState.broken:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color _getPortTextColor(ConnectionState state, bool isConnected) {
    if (isConnected || state == ConnectionState.connected) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    if (state == ConnectionState.broken) {
      return Theme.of(context).colorScheme.onError;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

// Also update your snackbar methods to use theme colors
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
