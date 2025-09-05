import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';

import '../../classes/event.dart';

/// A controller class for managing application settings, authentication, and data export functionality.
///
/// This controller handles:
/// - User authentication with Google Sign-In via Firebase
/// - Loading and managing event data from the API
/// - Exporting events to calendar format (ICS files)
/// - Application state management for settings-related operations
///
/// The controller integrates multiple services including:
/// - Firebase Authentication for user management
/// - Google Sign-In for OAuth authentication
/// - HTTP client for API communication
/// - File system access for calendar exports
///
/// Example usage:
/// ```dart
/// final settingsController = SettingsController();
///
/// // Sign in user
/// await settingsController.handleSignIn();
///
/// // Load events
/// await settingsController.loadEvents();
///
/// // Export events to calendar
/// await settingsController.exportEventsToCalendar();
/// ```
class SettingsController {
  /// Firebase Authentication instance for managing user authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign-In instance for handling OAuth authentication.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Indicates whether an operation is currently in progress.
  ///
  /// When `true`, the UI should show a loading indicator and disable interactions.
  /// Automatically managed during authentication and export operations.
  bool isLoading = false;

  /// A map of events grouped by their date.
  ///
  /// Structure: `Map<DateTime, List<Event>>`
  /// - Key: Normalized date (time set to 00:00:00)
  /// - Value: List of events occurring on that date
  ///
  /// Events are loaded from the API and normalized for calendar display.
  Map<DateTime, List<Event>> events = {};

  /// Loads events from the remote API and processes them for calendar display.
  ///
  /// Performs the following operations:
  /// 1. Sends POST request to the API endpoint with query parameter 'E1'
  /// 2. Processes the JSON response into Event objects
  /// 3. Groups events by normalized date (time removed)
  /// 4. Updates the events map for calendar display
  ///
  /// API Endpoint: `https://services.interagit.com/API/roominventory/api_ri.php`
  /// Query Parameter: `query_param = 'E1'`
  ///
  /// Expected API Response Structure:
  /// ```json
  /// [
  ///   {
  ///     "IdEvent": "1",
  ///     "EventName": "Conference",
  ///     "EventPlace": "Main Hall",
  ///     "NameRep": "John Doe",
  ///     "EmailRep": "john@example.com",
  ///     "TecExt": "Microphone, Projector",
  ///     "Date": "2024-01-15 14:00:00"
  ///   }
  /// ]
  /// ```
  ///
  /// Throws:
  /// - `Exception` with HTTP status code if API request fails
  /// - `Exception` with error details if parsing fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.loadEvents();
  ///   // Events are now available in controller.events
  /// } catch (e) {
  ///   // Handle error
  /// }
  /// ```
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

  /// Normalizes a DateTime by removing the time component.
  ///
  /// This is used to group events by date regardless of their specific time.
  ///
  /// Parameters:
  /// - [date]: The DateTime to normalize
  ///
  /// Returns: A new DateTime with the same year, month, and day but time set to 00:00:00
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Handles the Google Sign-In authentication flow.
  ///
  /// Performs the following operations:
  /// 1. Initiates Google Sign-In flow
  /// 2. Obtains authentication credentials from Google
  /// 3. Signs into Firebase with the obtained credentials
  /// 4. Manages loading state during the process
  ///
  /// Throws:
  /// - `Exception` if the sign-in process fails at any step
  /// - `Exception` if the user cancels the sign-in flow (returns null)
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.handleSignIn();
  ///   // User is now signed in
  /// } catch (e) {
  ///   // Handle sign-in error
  /// }
  /// ```
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

  /// Handles user sign-out from both Google and Firebase.
  ///
  /// Performs the following operations:
  /// 1. Signs out from Google Sign-In
  /// 2. Signs out from Firebase Authentication
  /// 3. Manages loading state during the process
  ///
  /// Throws:
  /// - `Exception` if the sign-out process fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.handleSignOut();
  ///   // User is now signed out
  /// } catch (e) {
  ///   // Handle sign-out error
  /// }
  /// ```
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

  /// Exports all loaded events to an ICS calendar file.
  ///
  /// This method:
  /// 1. Validates that there are events to export
  /// 2. Generates valid ICS (iCalendar) content with proper formatting
  /// 3. Saves the file to the device's downloads directory
  /// 4. Uses platform-specific file saving mechanisms
  ///
  /// ICS Format Features:
  /// - Proper VEVENT entries for each event
  /// - UTC time formatting
  /// - Escaped special characters
  /// - Complete event details in description
  /// - Unique identifiers for calendar clients
  ///
  /// File Location:
  /// - Android: Uses FileSaver with system picker
  /// - iOS: Uses FileSaver with system picker
  /// - File name: `room_inventory_events_[timestamp].ics`
  ///
  /// Throws:
  /// - `Exception` if no events are available to export
  /// - `Exception` if file system operations fail
  /// - `Exception` if platform-specific saving fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await controller.exportEventsToCalendar();
  ///   // File saved successfully
  /// } catch (e) {
  ///   // Handle export error
  /// }
  /// ```
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

  /// Escapes special characters in ICS text content.
  ///
  /// ICS format requires certain characters to be escaped with backslashes.
  ///
  /// Parameters:
  /// - [text]: The text to escape
  ///
  /// Returns: The escaped text with special characters properly formatted
  String _escapeICS(String text) {
    return text
        .replaceAll('\n', '\\n')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');
  }

  /// Formats a DateTime object into ICS-compliant date format.
  ///
  /// ICS format requires dates in `YYYYMMDDTHHMMSSZ` format for UTC times.
  ///
  /// Parameters:
  /// - [date]: The DateTime to format
  ///
  /// Returns: The formatted date string in ICS format
  String _formatICalDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}T${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}Z';
  }
}
