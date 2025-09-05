import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:roominventory/pages/dimmers/dimmerController.dart';
import 'package:roominventory/classes/connectionState.dart';

/// A customizable iOS-styled grid component for displaying DMX ports with connection states.
///
/// This widget renders a grid of ports with visual indicators for connection status,
/// state (connected, disconnected, broken), and interactive capabilities. It supports
/// both source (first area) and target (second area) port configurations.
///
/// Features:
/// - Visual state indication through color coding
/// - Support for tap and long-press interactions
/// - iOS-style aesthetics with shadows and rounded corners
/// - Theme-aware coloring using the current theme's color scheme
///
/// Example usage:
/// ```dart
/// IOSPortGrid(
///   controller: dmxController,
///   rowLabels: ['A', 'B', 'C'],
///   columns: 12,
///   states: portStates,
///   isSource: true,
///   onTap: (row, col) => handleTap(row, col),
///   onLongPress: (key, row, col) => startConnection(key, row, col),
/// )
/// ```
class IOSPortGrid extends StatelessWidget {
  /// The controller that manages DMX configuration state and business logic
  final DMXConfigController controller;

  /// Labels for each row in the grid (e.g., ['A', 'B', 'C'] or ['1', '2'])
  final List<String> rowLabels;

  /// Number of columns in the grid (typically 12 for DMX configurations)
  final int columns;

  /// 2D list representing the connection state of each port in the grid
  final List<List<ConnectionState>> states;

  /// Whether this grid represents source ports (true) or target ports (false)
  ///
  /// Source ports are typically stage bus outputs, while target ports are DMX outputs.
  /// This affects how connection states are determined and displayed.
  final bool isSource;

  /// Callback function invoked when a port is tapped
  ///
  /// Parameters:
  ///   - `row`: The row index (0-based) of the tapped port
  ///   - `col`: The column index (0-based) of the tapped port
  final Function(int, int) onTap;

  /// Optional callback function invoked when a port is long-pressed
  ///
  /// Parameters:
  ///   - `key`: The unique identifier key for the port (e.g., 'first_A_1')
  ///   - `row`: The row index (0-based) of the long-pressed port
  ///   - `col`: The column index (0-based) of the long-pressed port
  final Function(String, int, int)? onLongPress;

  const IOSPortGrid({
    Key? key,
    required this.controller,
    required this.rowLabels,
    required this.columns,
    required this.states,
    required this.isSource,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: rowLabels.map((label) {
          final rowIndex = rowLabels.indexOf(label);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                // Row label header
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
                // Port grid row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: List.generate(columns, (colIndex) {
                      final portNumber = colIndex + 1;
                      final key = isSource
                          ? 'first_${label}_$portNumber'
                          : 'second_${label}_$portNumber';
                      final isConnected = isSource
                          ? controller.connections.containsKey(key)
                          : controller.connections.containsValue(key);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () => onTap(rowIndex, colIndex),
                            onLongPress: onLongPress != null
                                ? () => onLongPress!(key, rowIndex, colIndex)
                                : null,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getPortColor(context,
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
                                        context,
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

  /// Determines the background color for a port based on its state and connection status.
  ///
  /// Parameters:
  ///   - `context`: The build context for theme access
  ///   - `state`: The current ConnectionState of the port
  ///   - `isConnected`: Whether the port is part of an active connection
  ///
  /// Returns:
  ///   - Primary color for connected ports
  ///   - Tertiary color for connected state ports
  ///   - Surface color for disconnected ports
  ///   - Error color for broken ports
  Color _getPortColor(
      BuildContext context, ConnectionState state, bool isConnected) {
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

  /// Determines the text color for a port based on its state and connection status.
  ///
  /// Parameters:
  ///   - `context`: The build context for theme access
  ///   - `state`: The current ConnectionState of the port
  ///   - `isConnected`: Whether the port is part of an active connection
  ///
  /// Returns:
  ///   - On-primary color for connected or connected-state ports
  ///   - On-error color for broken ports
  ///   - On-surface color for disconnected ports
  Color _getPortTextColor(
      BuildContext context, ConnectionState state, bool isConnected) {
    if (isConnected || state == ConnectionState.connected) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    if (state == ConnectionState.broken) {
      return Theme.of(context).colorScheme.onError;
    }
    return Theme.of(context).colorScheme.onSurface;
  }
}

/// A section widget that displays the stage bus (first area) DMX ports.
///
/// This section represents the source ports where connections originate.
/// Typically contains 5 rows (A-E) with 12 columns each, following standard
/// DMX stage bus configurations.
///
/// Includes support for both tap interactions (state toggling) and long-press
/// interactions (connection initiation).
class StageBusSection extends StatelessWidget {
  /// The controller that manages the DMX configuration state
  final DMXConfigController controller;

  const StageBusSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        "Barramento de Palco",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        IOSPortGrid(
          controller: controller,
          rowLabels: DMXConfigController.firstAreaRows,
          columns: DMXConfigController.firstAreaCols,
          states: controller.firstAreaStates,
          isSource: true,
          onTap: (row, col) => controller.handleFirstAreaTap(row, col),
          onLongPress: (key, row, col) =>
              controller.startConnectionProcess(key, row, col),
        ),
      ],
    );
  }
}

/// A section widget that displays the DMX output (second area) ports.
///
/// This section represents the target ports where connections terminate.
/// Typically contains 2 rows with 12 columns each, following standard
/// DMX output configurations.
///
/// Supports tap interactions for connection completion and state toggling.
class DMXOutputsSection extends StatelessWidget {
  /// The controller that manages the DMX configuration state
  final DMXConfigController controller;

  const DMXOutputsSection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        "Outputs DMX",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        IOSPortGrid(
          controller: controller,
          rowLabels: DMXConfigController.secondAreaRowLabels,
          columns: DMXConfigController.secondAreaCols,
          states: controller.secondAreaStates,
          isSource: false,
          onTap: (row, col) => controller.handleSecondAreaTap(row, col),
        ),
      ],
    );
  }
}
