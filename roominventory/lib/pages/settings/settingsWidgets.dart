import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roominventory/classes/provider.dart';

/// A section widget that displays account-related information and actions.
///
/// This widget shows different UI states based on the user's authentication status:
/// - When user is signed in: Shows user info, export button, and sign-out option
/// - When user is signed out: Shows sign-in button
///
/// Features:
/// - Dynamic UI based on authentication state
/// - Loading states for authentication operations
/// - Consistent Cupertino design styling
/// - Integration with Firebase Authentication
///
/// Example usage:
/// ```dart
/// AccountSection(
///   user: currentUser,
///   isLoading: false,
///   onSignIn: _handleSignIn,
///   onSignOut: _handleSignOut,
///   onExportEvents: _exportEvents,
/// )
/// ```
class AccountSection extends StatelessWidget {
  /// The currently authenticated Firebase user, or null if not signed in.
  ///
  /// Used to determine which UI state to show (signed-in vs signed-out).
  /// When null, shows sign-in options. When not null, shows user info and sign-out.
  final User? user;

  /// Indicates whether an authentication operation is in progress.
  ///
  /// When true:
  /// - Shows loading indicators instead of action text
  /// - Disables button interactions to prevent duplicate operations
  /// - Provides visual feedback for ongoing operations
  final bool isLoading;

  /// Callback function to handle user sign-in.
  ///
  /// Typically initiates the Google Sign-In flow through Firebase Authentication.
  /// Only enabled when [isLoading] is false.
  final Function() onSignIn;

  /// Callback function to handle user sign-out.
  ///
  /// Typically signs the user out of Firebase Authentication.
  /// Only enabled when [isLoading] is false.
  final Function() onSignOut;

  /// Callback function to handle calendar export.
  ///
  /// Typically exports events to an ICS file for calendar import.
  /// Available only when user is signed in.
  final Function() onExportEvents;

  /// Creates an account section with authentication-aware UI.
  ///
  /// Requires:
  /// - [user]: Current authentication state
  /// - [isLoading]: Loading state for operations
  /// - [onSignIn]: Sign-in handler callback
  /// - [onSignOut]: Sign-out handler callback
  /// - [onExportEvents]: Calendar export handler callback
  const AccountSection({
    Key? key,
    required this.user,
    required this.isLoading,
    required this.onSignIn,
    required this.onSignOut,
    required this.onExportEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        'Account',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
        ),
      ),
      children: [
        if (user != null) ...[
          // User Info Tile
          CupertinoListTile.notched(
            title: Text('Logged in as'),
            subtitle: Text(user!.email ?? 'No email'),
            trailing:
                Icon(CupertinoIcons.person_crop_circle_fill_badge_checkmark),
          ),
          // Export to Calendar Button
          CupertinoListTile.notched(
            title: Text('Export Events to Calendar'),
            trailing: Icon(CupertinoIcons.calendar_badge_plus),
            onTap: onExportEvents,
          ),
          // Sign Out Button
          CupertinoListTile.notched(
            title: isLoading
                ? Row(
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(width: 8),
                      Text('Signing out...'),
                    ],
                  )
                : Text('Sign Out',
                    style: TextStyle(color: CupertinoColors.systemRed)),
            onTap: isLoading ? null : onSignOut,
          ),
        ] else ...[
          // Sign In Button
          CupertinoListTile.notched(
            title: isLoading
                ? Row(
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(width: 8),
                      Text('Signing in...'),
                    ],
                  )
                : Text(
                    'Sign In with Google',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
            trailing: Icon(CupertinoIcons.person_crop_circle_badge_plus),
            onTap: isLoading ? null : onSignIn,
          ),
        ],
      ],
    );
  }
}

/// A section widget that displays application preference settings.
///
/// This widget provides user-configurable preferences such as:
/// - Dark mode/light mode theme switching
/// - Other application settings (extensible)
///
/// Features:
/// - Theme mode switching with immediate visual feedback
/// - Consistent Cupertino design styling
/// - Integration with ThemeProvider for state management
///
/// Example usage:
/// ```dart
/// PreferencesSection(themeProvider: themeProvider)
/// ```
class PreferencesSection extends StatelessWidget {
  /// The theme provider that manages application theme state.
  ///
  /// Used to:
  /// - Get current theme mode state
  /// - Update theme mode based on user preferences
  /// - Maintain consistent theming across the application
  final ThemeProvider themeProvider;

  /// Creates a preferences section with theme configuration options.
  ///
  /// Requires [themeProvider] to manage and update theme preferences.
  const PreferencesSection({
    Key? key,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        'Preferences',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
        ),
      ),
      children: [
        CupertinoListTile.notched(
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: CupertinoSwitch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeProvider.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A dialog widget that displays instructions for importing calendar files.
///
/// This dialog provides step-by-step guidance for users on how to import
/// the exported ICS calendar files into their calendar applications.
///
/// Features:
/// - Clear, concise instructions for Google Calendar import
/// - Cupertino-style dialog design for iOS consistency
/// - Simple dismissal with OK button
///
/// Example usage:
/// ```dart
/// showCupertinoDialog(
///   context: context,
///   builder: (context) => ImportInstructionsDialog(),
/// )
/// ```
class ImportInstructionsDialog extends StatelessWidget {
  /// Creates a dialog with calendar import instructions.
  const ImportInstructionsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('How to Import'),
      content: Text(
        '1. Open Google Calendar\n'
        '2. Go to Settings → Import & Export\n'
        '3. Select the downloaded .ics file',
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

/// A confirmation dialog for user sign-out operations.
///
/// This dialog prevents accidental sign-outs by requiring explicit user
/// confirmation before proceeding with the sign-out operation.
///
/// Features:
/// - Clear confirmation message
/// - Destructive styling for sign-out action
/// - Cancel option to abort the operation
/// - Cupertino-style action sheet design
///
/// Example usage:
/// ```dart
/// showCupertinoModalPopup(
///   context: context,
///   builder: (context) => SignOutConfirmationDialog(onConfirm: _signOut),
/// )
/// ```
class SignOutConfirmationDialog extends StatelessWidget {
  /// Callback function to execute when user confirms sign-out.
  ///
  /// Typically calls the sign-out method from the authentication controller.
  final Function() onConfirm;

  /// Creates a sign-out confirmation dialog.
  ///
  /// Requires [onConfirm] callback to handle the confirmed sign-out action.
  const SignOutConfirmationDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Confirm Sign Out'),
      message: const Text('Are you sure you want to sign out?'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: onConfirm,
          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }
}
