import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/widgets/calendar_widget.dart';
import 'package:calendar_app/widgets/calendar/events/event_details.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final VoidCallback onAddEvent;

  const MainScreen({
    Key? key,
    required this.events,
    required this.onEventTap,
    required this.onAddEvent,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filterEvents();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(theme.brightness == Brightness.light
                ? Icons.brightness_6
                : Icons.brightness_4),
            onPressed: () {
              // Theme toggle functionality will be implemented later
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CalendarWidget(
              selectedDate: _selectedDate,
              events: filteredEvents,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onEventTap: widget.onEventTap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Event> _filterEvents() {
    switch (_filter) {
      case 'Today':
        final now = DateTime.now();
        return _getEventsForDay(now);
      case 'This Week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return _getEventsForWeek(weekStart);
      case 'This Month':
        final now = DateTime.now();
        return _getEventsForMonth(now);
      default:
        return widget.events;
    }
  }

  List<Event> _getEventsForDay(DateTime now) {
    return widget.events.where((event) {
      return event.startDate.year == now.year &&
          event.startDate.month == now.month &&
          event.startDate.day == now.day;
    }).toList();
  }

  List<Event> _getEventsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return widget.events.where((event) {
      return event.startDate.isAfter(weekStart) &&
          event.startDate.isBefore(weekEnd);
    }).toList();
  }

  List<Event> _getEventsForMonth(DateTime now) {
    return widget.events.where((event) {
      return event.startDate.year == now.year &&
          event.startDate.month == now.month;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                setState(() {
                  _filter = 'All';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Today'),
              onTap: () {
                setState(() {
                  _filter = 'Today';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('This Week'),
              onTap: () {
                setState(() {
                  _filter = 'This Week';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('This Month'),
              onTap: () {
                setState(() {
                  _filter = 'This Month';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
