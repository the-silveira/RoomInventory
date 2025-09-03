import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roominventory/classes/provider.dart';

class AccountSection extends StatelessWidget {
  final User? user;
  final bool isLoading;
  final Function() onSignIn;
  final Function() onSignOut;
  final Function() onExportEvents;

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

class PreferencesSection extends StatelessWidget {
  final ThemeProvider themeProvider;

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

class ImportInstructionsDialog extends StatelessWidget {
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

class SignOutConfirmationDialog extends StatelessWidget {
  final Function() onConfirm;

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
