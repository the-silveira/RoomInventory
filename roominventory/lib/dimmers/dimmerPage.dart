import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

void main() {
  runApp(const DMXConfigApp());
}

class DMXConfigApp extends StatelessWidget {
  const DMXConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'DMX Board Config',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: DMXConfigPage(),
    );
  }
}

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

/// Widget Components
class DMXOutputGrid extends StatelessWidget {
  final String title;
  final List<String> rowLabels;
  final int columns;
  final List<List<ConnectionState>> states;
  final Map<String, String> connections;
  final String? connectingFrom;
  final AnimationController blinkController;
  final Function(int, int) onTap;
  final Function(String, int, int)? onLongPress;
  final bool showIncomingConnections;

  const DMXOutputGrid({
    super.key,
    required this.title,
    required this.rowLabels,
    required this.columns,
    required this.states,
    required this.connections,
    required this.connectingFrom,
    required this.blinkController,
    required this.onTap,
    this.onLongPress,
    this.showIncomingConnections = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(rowLabels.length, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          rowLabels[rowIndex],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(columns, (colIndex) {
                    final spaceNumber = colIndex + 1;
                    final key = title == 'Fixture Outputs'
                        ? 'first_${rowLabels[rowIndex]}_$spaceNumber'
                        : 'second_${rowLabels[rowIndex]}_$spaceNumber';
                    final isConnected = showIncomingConnections
                        ? connections.containsValue(key)
                        : connections.containsKey(key);
                    final connectionInfo = isConnected
                        ? (showIncomingConnections
                            ? connections.entries
                                .firstWhere((e) => e.value == key)
                                .key
                            : connections[key])
                        : null;

                    return Flexible(
                      child: GestureDetector(
                        onTap: () => onTap(rowIndex, colIndex),
                        onLongPress: onLongPress != null
                            ? () => onLongPress!(key, rowIndex, colIndex)
                            : null,
                        child: AnimatedBuilder(
                          animation: blinkController,
                          builder: (context, child) {
                            return Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: connectingFrom == key
                                    ? blinkController.value > 0.5
                                        ? CupertinoColors.systemYellow
                                        : CupertinoColors.systemGrey
                                    : _getStateColor(states[rowIndex][colIndex],
                                        isConnected),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              height: 40,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$spaceNumber',
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isConnected && connectionInfo != null)
                                      Text(
                                        showIncomingConnections
                                            ? '←${connectionInfo.split('_').sublist(1).join('')}'
                                            : '→${connectionInfo.split('_').sublist(1).join('')}',
                                        style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _getStateColor(ConnectionState state, bool isConnected) {
    if (isConnected) return CupertinoColors.systemBlue;
    switch (state) {
      case ConnectionState.connected:
        return CupertinoColors.systemGreen;
      case ConnectionState.disconnected:
        return CupertinoColors.systemGrey;
      case ConnectionState.broken:
        return CupertinoColors.systemRed;
    }
  }
}

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
        _showError('Failed to load channels: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error loading channels: $e');
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

      developer.log('Saving payload: ${json.encode(payload)}');

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
      developer.log('Error getting channel ID from key $key: $e');
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: CupertinoColors.systemRed),
    );
    developer.log(message);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: CupertinoColors.systemGreen),
    );
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('DMX Board Configuration'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.refresh, size: 28),
              onPressed: _loadChannels,
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, size: 28),
              onPressed: _saveConfiguration,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.circle_fill,
                    size: 12,
                    color: _connectingFrom != null
                        ? CupertinoColors.systemYellow
                        : CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _connectingFrom != null
                        ? 'Select target DMX port'
                        : 'Ready to configure',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixture Outputs
                    _buildSectionHeader(
                        'Fixture Outputs', 'Long press to connect'),
                    const SizedBox(height: 12),
                    _buildPortGrid(
                      rowLabels: firstAreaRows,
                      columns: firstAreaCols,
                      states: _firstAreaStates,
                      isSource: true,
                    ),

                    const SizedBox(height: 32),

                    // DMX Outputs
                    _buildSectionHeader('DMX Outputs', 'Tap to disconnect'),
                    const SizedBox(height: 12),
                    _buildPortGrid(
                      rowLabels: secondAreaRowLabels,
                      columns: secondAreaCols,
                      states: _secondAreaStates,
                      isSource: false,
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildPortGrid({
    required List<String> rowLabels,
    required int columns,
    required List<List<ConnectionState>> states,
    required bool isSource,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Column(
        children: rowLabels.map((label) {
          final rowIndex = rowLabels.indexOf(label);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Row Label
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 15, bottom: 1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                          fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Ports Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () => isSource
                                ? _handleFirstAreaTap(rowIndex, colIndex)
                                : _handleSecondAreaTap(rowIndex, colIndex),
                            onLongPress: isSource
                                ? () => _startConnectionProcess(
                                    key, rowIndex, colIndex)
                                : null,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: _getPortColor(
                                    states[rowIndex][colIndex], isConnected),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: CupertinoColors.systemGrey4,
                                  width: 0.5,
                                ),
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
    if (isConnected) return CupertinoColors.systemBlue;
    switch (state) {
      case ConnectionState.connected:
        return CupertinoColors.systemGreen;
      case ConnectionState.disconnected:
        return CupertinoColors.systemBackground;
      case ConnectionState.broken:
        return CupertinoColors.systemRed;
    }
  }

  Color _getPortTextColor(ConnectionState state, bool isConnected) {
    // White text for colored backgrounds
    if (isConnected ||
        state == ConnectionState.connected ||
        state == ConnectionState.broken) {
      return CupertinoColors.white;
    }
    // Dark text for light backgrounds
    return CupertinoColors.label;
  }
}
