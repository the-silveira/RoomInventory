import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:roominventory/classes/provider.dart';
import 'package:roominventory/pages/settings/settingsController.dart';
import 'package:roominventory/pages/settings/settingsWidgets.dart';
import '../../globalWidgets/appbar/appbar.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      await _controller.loadEvents();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _controller.handleSignIn();
      setState(() {});
      _showSuccess('Signed in successfully');
    } catch (e) {
      _showError(e.toString());
    }
  }

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

  Future<void> _handleSignOut() async {
    try {
      await _controller.handleSignOut();
      setState(() {});
      _showSuccess('Signed out successfully');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _exportEventsToCalendar() async {
    try {
      await _controller.exportEventsToCalendar();
      _showExportSuccess();
    } catch (e) {
      _showError(e.toString());
    }
  }

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

  void _showImportInstructions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => ImportInstructionsDialog(),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = _auth.currentUser;

    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Definições',
        previousPageTitle: 'Inventário CCO',
      ),
      child: ListView(
        children: <Widget>[
          AccountSection(
            user: user,
            isLoading: _controller.isLoading,
            onSignIn: _handleSignIn,
            onSignOut: _confirmSignOut,
            onExportEvents: _exportEventsToCalendar,
          ),
          PreferencesSection(themeProvider: themeProvider),
        ],
      ),
    );
  }
}
