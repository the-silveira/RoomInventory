import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
                    event['Date'])
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

  @override
  Widget build(BuildContext context) {
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
                //print('Selected Events: $_selectedEvents'); // Debug: Print selected events
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final events = _events[_normalizeDate(day)] ?? [];
              //print('Events for $day: $events'); // Debug: Print events for the day
              return events;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.surface),
              selectedDecoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      'No events for the selected day',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return ListTile(
                        title: Text(event.EventName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "📍 ${event.IdEvent}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2), // Add spacing between lines
                            Text(
                              "👤 ${event.NameRep}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "📧 ${event.EmailRep}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "🛠 ${event.TecExt}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "📅 Date: ${event.Date}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "ID: ${event.IdEvent}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Event class
class Event {
  final String IdEvent, EventName, EventPlace, NameRep, EmailRep, TecExt, Date;

  Event(this.IdEvent, this.EventName, this.EventPlace, this.NameRep,
      this.EmailRep, this.TecExt, this.Date);
}
