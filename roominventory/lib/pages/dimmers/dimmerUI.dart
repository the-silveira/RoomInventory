import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/dimmers/dimmerController.dart';
import 'package:roominventory/pages/dimmers/dimmerWidgets.dart';

class DMXConfigPage extends StatefulWidget {
  const DMXConfigPage({super.key});

  @override
  State<DMXConfigPage> createState() => _DMXConfigPageState();
}

class _DMXConfigPageState extends State<DMXConfigPage> {
  final DMXConfigController _controller = DMXConfigController();
  Timer? _blinkTimer;
  bool _blinkState = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _blinkState = !_blinkState);
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (_blinkState && mounted) {
      setState(() => _blinkState = false);
    }
  }

  Future<void> _loadChannels() async {
    await _controller.loadChannels();
    if (mounted) setState(() {});
  }

  Future<void> _saveConfiguration() async {
    bool success = await _controller.saveConfiguration();

    if (success) {
      _showSuccess('Configuration saved successfully!');
      await _loadChannels();
    } else {
      _showError(_controller.errorMessage);
    }
  }

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

  void _onLongPress(String key, int row, int col) {
    setState(() {
      _controller.startConnectionProcess(key, row, col);
    });
    if (_controller.connectingFrom != null) {
      _startBlinking();
    } else {
      _stopBlinking();
    }
  }

  void _onFirstAreaTap(int row, int col) {
    setState(() {
      _controller.handleFirstAreaTap(row, col);
    });
    if (_controller.connectingFrom == null) _stopBlinking();
  }

  void _onSecondAreaTap(int row, int col) {
    setState(() {
      _controller.handleSecondAreaTap(row, col);
    });
    if (_controller.connectingFrom == null) _stopBlinking();
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
              _controller.isLoading
                  ? const Expanded(
                      child: Center(child: CupertinoActivityIndicator()))
                  : _controller.errorMessage.isNotEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              _controller.errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: CupertinoScrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StageBusSection(
                                    controller: _controller,
                                    isBlinkOn: _blinkState,
                                    onTap: _onFirstAreaTap,
                                    onLongPress: _onLongPress,
                                  ),
                                  DMXOutputsSection(
                                    controller: _controller,
                                    isBlinkOn: _blinkState,
                                    onTap: _onSecondAreaTap,
                                    onLongPress: _onLongPress,
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
}
