import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:roominventory/classes/provider.dart';
import 'package:roominventory/pages/settings/settingsController.dart';
import 'package:roominventory/pages/settings/settingsWidgets.dart';
import '../../globalWidgets/appbar/appbar.dart';

/// The settings page for the Room Inventory application.
///
/// This page provides users with access to:
/// - Account management (sign-in/sign-out with Google)
/// - Theme preferences (light/dark mode)
/// - Event calendar export functionality
/// - Application configuration options
///
/// The page integrates with multiple services:
/// - Firebase Authentication for user management
/// - ThemeProvider for application theming
/// - SettingsController for business logic operations
///
/// Features:
/// - User authentication status display
/// - Google Sign-In integration
/// - Calendar export with instructions
/// - Theme switching capabilities
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => SettingsPage()),
/// );
/// ```
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

/// The state class for [SettingsPage], managing user settings and preferences.
///
/// This state class handles:
/// - User authentication state management
/// - Event data loading for calendar export
/// - Theme preference management
/// - User interaction handling (sign-in, sign-out, export)
/// - Error handling and user feedback
class _SettingsPageState extends State<SettingsPage> {
  /// Controller responsible for settings-related business logic.
  ///
  /// Handles:
  /// - User authentication operations
  /// - Event data loading and processing
  /// - Calendar file export functionality
  final SettingsController _controller = SettingsController();

  /// Firebase Authentication instance for accessing current user information.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Loads events from the API for calendar export functionality.
  ///
  /// This method:
  /// 1. Calls the controller's [loadEvents] method
  /// 2. Handles any errors by showing user-friendly error messages
  /// 3. Runs automatically when the page is initialized
  ///
  /// The loaded events are stored in the controller and used for calendar export.
  Future<void> _loadEvents() async {
    try {
      await _controller.loadEvents();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Handles the user sign-in process with Google authentication.
  ///
  /// This method:
  /// 1. Calls the controller's [handleSignIn] method
  /// 2. Updates the UI state to reflect authentication changes
  /// 3. Shows success/error messages to the user
  /// 4. Triggers a UI rebuild to update authentication status
  Future<void> _handleSignIn() async {
    try {
      await _controller.handleSignIn();
      setState(() {});
      _showSuccess('Signed in successfully');
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Shows a confirmation dialog before signing out the user.
  ///
  /// This method:
  /// 1. Displays a Cupertino-style modal confirmation dialog
  /// 2. Only proceeds with sign-out if user confirms
  /// 3. Prevents accidental sign-outs
  ///
  /// Returns: A Future that completes when the user makes a decision
  Future<void> _confirmSignOut() async {
    final bool? shouldSignOut = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => SignOutConfirmationDialog(
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (shouldSignOut == true) {
      await _handleSignOut();
    }
  }

  /// Handles the user sign-out process.
  ///
  /// This method:
  /// 1. Calls the controller's [handleSignOut] method
  /// 2. Updates the UI state to reflect authentication changes
  /// 3. Shows success/error messages to the user
  /// 4. Triggers a UI rebuild to update authentication status
  Future<void> _handleSignOut() async {
    try {
      await _controller.handleSignOut();
      setState(() {});
      _showSuccess('Signed out successfully');
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Exports events to a calendar file and provides user feedback.
  ///
  /// This method:
  /// 1. Calls the controller's [exportEventsToCalendar] method
  /// 2. Shows a success message with import instructions
  /// 3. Handles any export errors with user-friendly messages
  /// 4. Provides additional help for calendar import process
  Future<void> _exportEventsToCalendar() async {
    try {
      await _controller.exportEventsToCalendar();
      _showExportSuccess();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Shows a success message after calendar export with import guidance.
  ///
  /// Displays a SnackBar with:
  /// - Success message indicating file readiness
  /// - Action button to show import instructions
  /// - Temporary visibility with user-dismiss capability
  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendar file ready for import'),
        action: SnackBarAction(
          label: 'How to import',
          onPressed: _showImportInstructions,
        ),
      ),
    );
  }

  /// Shows a dialog with instructions for importing the calendar file.
  ///
  /// Displays a Cupertino-style dialog containing step-by-step instructions
  /// for importing the generated ICS file into calendar applications.
  void _showImportInstructions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => ImportInstructionsDialog(),
    );
  }

  /// Shows a success message to the user.
  ///
  /// Parameters:
  /// - [message]: The success message to display
  ///
  /// Uses a SnackBar for temporary, non-intrusive feedback.
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows an error message to the user.
  ///
  /// Parameters:
  /// - [message]: The error message to display
  ///
  /// Uses a SnackBar for temporary, non-intrusive feedback.
  /// Error messages are typically derived from caught exceptions.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Accesses the current theme provider for theme management.
    final themeProvider = Provider.of<ThemeProvider>(context);

    /// Gets the currently authenticated user, if any.
    final user = _auth.currentUser;

    /// Builds the settings page interface with Cupertino design principles.
    ///
    /// Returns a [CupertinoPageScaffold] containing:
    /// - Custom navigation bar with title and back button
    /// - List view with two main sections:
    ///   - AccountSection: User authentication and calendar export
    ///   - PreferencesSection: Theme and application preferences
    ///
    /// The layout adapts based on user authentication state.
    return CupertinoPageScaffold(
      /// Custom navigation bar with consistent app styling
      navigationBar: CustomNavigationBar(
        title: 'Definições',
        previousPageTitle: 'Inventário CCO',
      ),

      /// Scrollable list of settings sections
      child: ListView(
        children: <Widget>[
          /// Account management section with authentication and export features
          AccountSection(
            user: user,
            isLoading: _controller.isLoading,
            onSignIn: _handleSignIn,
            onSignOut: _confirmSignOut,
            onExportEvents: _exportEventsToCalendar,
          ),

          /// Theme and preferences section
          PreferencesSection(themeProvider: themeProvider),
        ],
      ),
    );
  }
}
