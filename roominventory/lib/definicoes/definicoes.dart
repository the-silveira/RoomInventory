import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '/appbar/appbar.dart';
import 'provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (response.statusCode == 200) {
        final dynamic eventsJson = json.decode(response.body);
        //print('API Response: $eventsJson'); // Debug: Print API response

        setState(() {
          _events = {
            for (var event in eventsJson)
              _normalizeDate(DateTime.parse(event['Date'])): [
                Event(
                  event['IdEvent'],
                  event['EventName'],
                  event['EventPlace'],
                  event['NameRep'],
                  event['EmailRep'],
                  event['TecExt'],
                  event['Date'],
                )
              ]
          };
          //print('Events Map: $_events'); // Debug: Print events map
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${googleUser.email}')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmSignOut() async {
    final bool? shouldSignOut = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirm Sign Out'),
        message: const Text('Are you sure you want to sign out?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (shouldSignOut == true) {
      await _handleSignOut();
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed out successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          // Account Section
          CupertinoListSection.insetGrouped(
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
                  subtitle: Text(user.email ?? 'No email'),
                  trailing: Icon(
                      CupertinoIcons.person_crop_circle_fill_badge_checkmark),
                ),
                // Export to Calendar Button
                CupertinoListTile.notched(
                  title: Text('Export Events to Calendar'),
                  trailing: Icon(CupertinoIcons.calendar_badge_plus),
                  onTap: _exportEventsToCalendar,
                ),
                // Separate Sign Out Button
                CupertinoListTile.notched(
                  title: _isLoading
                      ? Row(
                          children: [
                            CupertinoActivityIndicator(),
                            SizedBox(width: 8),
                            Text('Signing out...'),
                          ],
                        )
                      : Text('Sign Out',
                          style: TextStyle(color: CupertinoColors.systemRed)),
                  onTap: _isLoading ? null : _confirmSignOut,
                ),
              ] else ...[
                // Sign In Button
                CupertinoListTile.notched(
                  title: _isLoading
                      ? Row(
                          children: [
                            CupertinoActivityIndicator(),
                            SizedBox(width: 8),
                            Text('Signing in...'),
                          ],
                        )
                      : Text('Sign In with Google'),
                  trailing: Icon(CupertinoIcons.person_crop_circle_badge_plus),
                  onTap: _isLoading ? null : _handleSignIn,
                ),
              ],
            ],
          ),
          // Preferences Section
          CupertinoListSection.insetGrouped(
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
          ),
        ],
      ),
    );
  }

  Future<void> _exportEventsToCalendar() async {
    try {
      if (_events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No events to export')),
        );
        return;
      }

      // Create valid ICS content
      final icsContent = StringBuffer()
        ..writeln('BEGIN:VCALENDAR')
        ..writeln('VERSION:2.0')
        ..writeln('PRODID:-//Room Inventory//EN')
        ..writeln('CALSCALE:GREGORIAN');

      _events.forEach((date, events) {
        for (final event in events) {
          final startDate = DateTime.parse(event.Date).toUtc();
          final endDate = startDate.add(Duration(hours: 1));
          final now = DateTime.now().toUtc();

          icsContent
            ..writeln('BEGIN:VEVENT')
            ..writeln('UID:${event.IdEvent}@roominventory')
            ..writeln('DTSTAMP:${_formatICalDate(now)}')
            ..writeln('DTSTART:${_formatICalDate(startDate)}')
            ..writeln('DTEND:${_formatICalDate(endDate)}')
            ..writeln('SUMMARY:${_escapeICS(event.EventName)}')
            ..writeln(
                'DESCRIPTION:${_escapeICS('Event Place: ${event.EventPlace}\\n'
                    'Responsible: ${event.NameRep}\\n'
                    'Email: ${event.EmailRep}\\n'
                    'Technical Details: ${event.TecExt}')}')
            ..writeln('LOCATION:${_escapeICS(event.EventPlace)}')
            ..writeln(
                'ORGANIZER;CN=${_escapeICS(event.NameRep)}:MAILTO:${event.EmailRep}')
            ..writeln('END:VEVENT');
        }
      });

      icsContent.writeln('END:VCALENDAR');

      // Get downloads directory for more reliable saving
      final directory = await getDownloadsDirectory();
      final file = File(
          '${directory?.path}/room_inventory_events_${DateTime.now().millisecondsSinceEpoch}.ics');
      await file.writeAsString(icsContent.toString());

      // For Android, we need to use a different approach
      if (Platform.isAndroid) {
        final bytes = await file.readAsBytes();
        await FileSaver.instance.saveAs(
          name: 'room_inventory_events',
          bytes: bytes,
          ext: 'ics',
          mimeType: MimeType.other,
        );
      } else {
        // For iOS/macOS
        await FileSaver.instance.saveFile(
          name: 'room_inventory_events',
          bytes: await file.readAsBytes(),
          ext: 'ics',
          mimeType: MimeType.other,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calendar file ready for import'),
          action: SnackBarAction(
            label: 'How to import',
            onPressed: showImportInstructions,
          ),
        ),
      );
    } catch (error, stackTrace) {
      print('Export error: $error');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${error.toString()}')),
      );
    }
  }

  String _escapeICS(String text) {
    return text
        .replaceAll('\n', '\\n')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');
  }

  String _formatICalDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}T${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}Z';
  }

  void showImportInstructions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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
      ),
    );
  }

  // ... [Keep all other existing methods unchanged] ...
  // (_handleSignIn, _confirmSignOut, _handleSignOut, build, etc.)
}

class Event {
  final String IdEvent;
  final String EventName;
  final String EventPlace;
  final String NameRep;
  final String EmailRep;
  final String TecExt;
  final String Date;

  Event(this.IdEvent, this.EventName, this.EventPlace, this.NameRep,
      this.EmailRep, this.TecExt, this.Date);
}
