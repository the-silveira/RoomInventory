import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:roominventory/classes/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

/// A comprehensive calendar widget that displays events from the inventory system.
///
/// The [CalendarWidget] provides an interactive calendar interface that:
/// - Fetches and displays events from the API
/// - Allows navigation between months and calendar formats
/// - Shows event details for selected dates
/// - Integrates with the app's theme system
///
/// ## Features:
/// - **Interactive Calendar**: Month/week views with navigation
/// - **Event Loading**: Fetches events from the REST API
/// - **Date Selection**: Click any date to view its events
/// - **Theme Integration**: Adapts to light/dark theme changes
/// - **Responsive Design**: Works on mobile and tablet devices
///
/// ## Usage:
/// ```dart
/// // Simple usage in a parent widget
/// CalendarWidget()
///
/// // With custom styling or constraints
/// Container(
///   height: 600,
///   child: CalendarWidget(),
/// )
/// ```
///
/// ## API Integration:
/// The widget fetches events from the API endpoint:
/// - URL: `https://services.interagit.com/API/roominventory/api_ri.php`
/// - Method: POST with `{'query_param': 'E1'}`
/// - Response: JSON array of event objects
///
/// ## Event Structure:
/// Events are parsed into [Event] objects with:
/// - IdEvent, EventName, EventPlace, NameRep, EmailRep, TecExt, Date
class CalendarWidget extends StatefulWidget {
  /// Creates a calendar widget that displays inventory events.
  ///
  /// The widget automatically loads events from the API when initialized
  /// and provides a fully interactive calendar interface.
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  /// The current display format of the calendar (month or week view).
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// The currently focused day in the calendar navigation.
  DateTime _focusedDay = DateTime.now();

  /// The currently selected day for event display.
  DateTime? _selectedDay;

  /// Map of events keyed by their date (normalized to remove time component).
  Map<DateTime, List<Event>> _events = {};

  /// List of events for the currently selected day.
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  /// Normalizes a DateTime by removing the time component.
  ///
  /// This ensures consistent date comparison and mapping by creating
  /// a new DateTime with only year, month, and day components.
  ///
  /// [date]: The DateTime to normalize
  /// Returns: A new DateTime with time set to 00:00:00
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Fetches events from the API and updates the events map.
  ///
  /// ## API Call:
  /// - Makes a POST request to the events endpoint
  /// - Parses JSON response into Event objects
  /// - Maps events by their normalized date
  ///
  /// ## Error Handling:
  /// - Logs errors to console
  /// - Maintains previous events state on failure
  ///
  /// ## State Update:
  /// Triggers a rebuild with the new events data
  Future<void> _loadEvents() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://services.interagit.com/API/roominventory/api_ri.php'),
        body: {'query_param': 'E1'},
      );

      if (response.statusCode == 200) {
        final dynamic eventsJson = json.decode(response.body);

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
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Calendar Table
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _events[_normalizeDate(selectedDay)] ?? [];
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            eventLoader: (day) {
              return _events[_normalizeDate(day)] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: scheme.onPrimary),
              selectedDecoration: BoxDecoration(
                color: scheme.secondary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              formatButtonTextStyle: TextStyle(color: scheme.primary),
              formatButtonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.primary),
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: scheme.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: scheme.primary),
            ),
          ),

          // Events List
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      'No events for the selected day',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            event.EventName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _eventDetail("📍", event.EventPlace, scheme),
                              _eventDetail("👤", event.NameRep, scheme),
                              _eventDetail("📧", event.EmailRep, scheme),
                              _eventDetail("🛠", event.TecExt, scheme),
                              _eventDetail("📅", event.Date, scheme),
                              _eventDetail("ID:", event.IdEvent, scheme),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Creates a styled event detail row with icon and text.
  ///
  /// [label]: The icon or prefix text (e.g., "📍", "👤")
  /// [value]: The event detail value to display
  /// [scheme]: The current color scheme for theme-appropriate styling
  ///
  /// Returns: A styled Text widget with the event detail
  Widget _eventDetail(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        "$label $value",
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }
}
