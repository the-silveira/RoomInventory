import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/appbar/appbar_back.dart';
import 'package:roominventory/dimmers/dimmerController.dart';
import 'package:roominventory/dimmers/dimmerWidgets.dart';

class DMXConfigPage extends StatefulWidget {
  const DMXConfigPage({super.key});

  @override
  State<DMXConfigPage> createState() => _DMXConfigPageState();
}

class _DMXConfigPageState extends State<DMXConfigPage> {
  final DMXConfigController _controller = DMXConfigController();

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    await _controller.loadChannels();
    setState(() {});
  }

  Future<void> _saveConfiguration() async {
    bool success = await _controller.saveConfiguration();

    if (success) {
      _showSuccess('Configuration saved successfully!');
      await _loadChannels(); // Refresh data
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
                  ? const Center(child: CupertinoActivityIndicator())
                  : _controller.errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _controller.errorMessage,
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
                                  StageBusSection(controller: _controller),
                                  DMXOutputsSection(controller: _controller),
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
