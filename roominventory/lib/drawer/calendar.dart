import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

// Event model
class Event {
  final String IdEvent, EventName, EventPlace, NameRep, EmailRep, TecExt, Date;

  Event(
    this.IdEvent,
    this.EventName,
    this.EventPlace,
    this.NameRep,
    this.EmailRep,
    this.TecExt,
    this.Date,
  );
}
