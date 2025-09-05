import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar_back.dart';
import 'package:roominventory/pages/dimmers/dimmerController.dart';
import 'package:roominventory/pages/dimmers/dimmerWidgets.dart';

/// A configuration page for managing DMX (Digital Multiplex) connections and states.
///
/// This page provides a user interface for configuring DMX channel connections between
/// stage bus outputs and DMX outputs. It handles loading channel data from an API,
/// displaying current configurations, and saving changes back to the server.
///
/// The page is divided into two main sections:
/// - StageBusSection: Displays fixture outputs (typically 5 rows A-E with 12 columns)
/// - DMXOutputsSection: Displays DMX outputs (typically 2 rows with 12 columns)
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => DMXConfigPage()),
/// );
/// ```
class DMXConfigPage extends StatefulWidget {
  const DMXConfigPage({super.key});

  @override
  State<DMXConfigPage> createState() => _DMXConfigPageState();
}

/// The state class for [DMXConfigPage] that manages the UI and business logic.
///
/// This state handles:
/// - Initializing the DMX configuration controller
/// - Loading channel data from the API
/// - Saving configuration changes
/// - Managing UI states (loading, error, content)
/// - Displaying user feedback through snackbars
///
/// The state maintains a reference to [DMXConfigController] which handles
/// the business logic and API communications.
class _DMXConfigPageState extends State<DMXConfigPage> {
  /// Controller instance that manages DMX configuration business logic
  final DMXConfigController _controller = DMXConfigController();

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  /// Loads DMX channel data from the API and updates the UI state.
  ///
  /// This method:
  /// 1. Calls the controller's [loadChannels] method to fetch data
  /// 2. Triggers a UI rebuild after data loading completes
  /// 3. Handles any errors that occur during the loading process
  ///
  /// The loading state is managed by the controller's [isLoading] property.
  Future<void> _loadChannels() async {
    await _controller.loadChannels();
    setState(() {});
  }

  /// Saves the current DMX configuration to the API.
  ///
  /// This method:
  /// 1. Calls the controller's [saveConfiguration] method to persist changes
  /// 2. Displays appropriate success or error messages to the user
  /// 3. Refreshes the channel data after a successful save operation
  ///
  /// Returns:
  ///   - A Future that completes when the save operation is finished
  ///
  /// Throws:
  ///   - Exception if the save operation fails (handled internally)
  Future<void> _saveConfiguration() async {
    bool success = await _controller.saveConfiguration();

    if (success) {
      _showSuccess('Configuration saved successfully!');
      await _loadChannels(); // Refresh data
    } else {
      _showError(_controller.errorMessage);
    }
  }

  /// Displays an error message to the user using a floating SnackBar.
  ///
  /// Parameters:
  ///   - `message`: The error message text to display
  ///
  /// The SnackBar uses the theme's error color for visual consistency.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Displays a success message to the user using a floating SnackBar.
  ///
  /// Parameters:
  ///   - `message`: The success message text to display
  ///
  /// The SnackBar uses the theme's tertiary color for visual consistency.
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
              // Loading state - displays activity indicator
              _controller.isLoading
                  ? const Center(child: CupertinoActivityIndicator())

                  // Error state - displays error message
                  : _controller.errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _controller.errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )

                      // Content state - displays configuration sections
                      : Expanded(
                          child: CupertinoScrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Displays the stage bus section with fixture outputs
                                  ///
                                  /// This section shows the first area grid (typically 5x12)
                                  /// with connection states and allows user interactions
                                  /// for creating and managing connections.
                                  StageBusSection(controller: _controller),

                                  /// Displays the DMX outputs section
                                  ///
                                  /// This section shows the second area grid (typically 2x12)
                                  /// with connection states and allows user interactions
                                  /// for completing connections from the stage bus.
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
