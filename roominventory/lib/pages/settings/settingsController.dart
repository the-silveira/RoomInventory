import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';

import '../../classes/event.dart';
import 'package:roominventory/services/supabase_service.dart';

class SettingsController {
  final SupabaseClient _client = Supabase.instance.client;

  bool isLoading = false;
  Map<DateTime, List<Event>> events = {};

  Future<void> loadEvents() async {
    try {
      isLoading = true;

      final eventsJson = await SupabaseService.getEvents();

      events.clear();

      for (var event in eventsJson) {
        final date = _normalizeDate(DateTime.parse(event['date']));
        final eventObj = Event(
          event['idevent'] ?? '',
          event['eventname'] ?? '',
          event['eventplace'] ?? '',
          event['namerep'] ?? '',
          event['emailrep'] ?? '',
          event['tecext'] ?? '',
          event['date'] ?? '',
        );

        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add(eventObj);
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    } finally {
      isLoading = false;
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> handleSignIn() async {
    isLoading = true;
    try {
      await SupabaseService.signInWithGoogle();
    } catch (error) {
      throw Exception('Sign in failed: $error');
    } finally {
      isLoading = false;
    }
  }

  Future<void> handleSignOut() async {
    isLoading = true;
    try {
      await SupabaseService.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    } finally {
      isLoading = false;
    }
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> exportEventsToCalendar() async {
    try {
      if (events.isEmpty) {
        throw Exception('No events to export');
      }

      final icsContent = StringBuffer()
        ..writeln('BEGIN:VCALENDAR')
        ..writeln('VERSION:2.0')
        ..writeln('PRODID:-//Room Inventory//EN')
        ..writeln('CALSCALE:GREGORIAN');

      events.forEach((date, eventsList) {
        for (final event in eventsList) {
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
                'DESCRIPTION:${_escapeICS("Event Place: ${event.EventPlace}\n"
                    "Responsible: ${event.NameRep}\n"
                    "Email: ${event.EmailRep}\n"
                    "Technical Details: ${event.TecExt}")}')
            ..writeln('LOCATION:${_escapeICS(event.EventPlace)}')
            ..writeln(
                'ORGANIZER;CN=${_escapeICS(event.NameRep)}:MAILTO:${event.EmailRep}')
            ..writeln('END:VEVENT');
        }
      });

      icsContent.writeln('END:VCALENDAR');

      final directory = await getDownloadsDirectory();
      final file = File(
          '${directory?.path}/room_inventory_events_${DateTime.now().millisecondsSinceEpoch}.ics');
      await file.writeAsString(icsContent.toString());

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
