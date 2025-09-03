import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';

import '../../classes/event.dart';

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;
  Map<DateTime, List<Event>> events = {};

  // Load events from API
  Future<void> loadEvents() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (response.statusCode == 200) {
        final dynamic eventsJson = json.decode(response.body);

        events = {
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
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Google Sign In
  Future<void> handleSignIn() async {
    isLoading = true;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      throw Exception('Sign in failed: $error');
    } finally {
      isLoading = false;
    }
  }

  // Sign Out
  Future<void> handleSignOut() async {
    isLoading = true;
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    } finally {
      isLoading = false;
    }
  }

  // Export events to calendar
  Future<void> exportEventsToCalendar() async {
    try {
      if (events.isEmpty) {
        throw Exception('No events to export');
      }

      // Create valid ICS content
      final icsContent = StringBuffer()
        ..writeln('BEGIN:VCALENDAR')
        ..writeln('VERSION:2.0')
        ..writeln('PRODID:-//Room Inventory//EN')
        ..writeln('CALSCALE:GREGORIAN');

      events.forEach((date, events) {
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

      // Get downloads directory
      final directory = await getDownloadsDirectory();
      final file = File(
          '${directory?.path}/room_inventory_events_${DateTime.now().millisecondsSinceEpoch}.ics');
      await file.writeAsString(icsContent.toString());

      // Save file based on platform
      if (Platform.isAndroid) {
        final bytes = await file.readAsBytes();
        await FileSaver.instance.saveAs(
          name: 'room_inventory_events',
          bytes: bytes,
          mimeType: MimeType.other,
          fileExtension: 'ics',
        );
      } else {
        await FileSaver.instance.saveFile(
          name: 'room_inventory_events',
          bytes: await file.readAsBytes(),
          fileExtension: 'ics',
          mimeType: MimeType.other,
        );
      }
    } catch (error) {
      throw Exception('Export failed: $error');
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
}
