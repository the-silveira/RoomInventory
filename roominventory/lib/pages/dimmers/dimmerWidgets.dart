import 'package:flutter/cupertino.dart' hide ConnectionState;
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:roominventory/dimmers/dimmerController.dart';
import 'package:roominventory/classes/ConnectionState.dart';

class IOSPortGrid extends StatelessWidget {
  final DMXConfigController controller;
  final List<String> rowLabels;
  final int columns;
  final List<List<ConnectionState>> states;
  final bool isSource;
  final Function(int, int) onTap;
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

class StageBusSection extends StatelessWidget {
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

class DMXOutputsSection extends StatelessWidget {
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
