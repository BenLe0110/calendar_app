import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/widgets/calendar/views/daily_view.dart';
import 'package:calendar_app/widgets/calendar/views/monthly_view.dart';

enum CalendarViewType {
  daily,
  monthly,
}

class CalendarView extends StatefulWidget {
  final CalendarViewType initialView;
  final DateTime selectedDate;
  final List<Event>? events;

  const CalendarView({
    Key? key,
    required this.initialView,
    required this.selectedDate,
    this.events,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarViewType _currentView;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
    _currentDate = widget.selectedDate;
  }

  Widget _buildDailyView() {
    return Container(
      key: const Key('dailyViewContainer'),
      child: Column(
        children: [
          Text(
            '${_currentDate.month == 3 ? 'March' : ''} ${_currentDate.day}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, hour) {
                final timeString =
                    '${hour < 12 ? hour == 0 ? 12 : hour : hour == 12 ? 12 : hour - 12}:00 ${hour < 12 ? 'AM' : 'PM'}';
                final currentEvents = widget.events
                        ?.where((event) =>
                            event.startDate.hour == hour &&
                            event.startDate.day == _currentDate.day &&
                            event.startDate.month == _currentDate.month &&
                            event.startDate.year == _currentDate.year)
                        .toList() ??
                    [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(timeString),
                    ...currentEvents.map((event) => _buildEventTile(event)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    return Container(
      key: const Key('monthlyViewContainer'),
      child: Column(
        children: [
          Text(
            'March 2024',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final hasEvents = widget.events?.any((event) =>
                        event.startDate.day == day &&
                        event.startDate.month == _currentDate.month &&
                        event.startDate.year == _currentDate.year) ??
                    false;

                return Stack(
                  children: [
                    Center(child: Text('$day')),
                    if (hasEvents)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          key: Key(
                              'eventIndicator-${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.events
                                    ?.firstWhere((event) =>
                                        event.startDate.day == day &&
                                        event.startDate.month ==
                                            _currentDate.month &&
                                        event.startDate.year ==
                                            _currentDate.year)
                                    ?.color ??
                                Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(Event event) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(
        '${event.startDate.hour < 12 ? event.startDate.hour == 0 ? 12 : event.startDate.hour : event.startDate.hour == 12 ? 12 : event.startDate.hour - 12}:00 ${event.startDate.hour < 12 ? 'AM' : 'PM'} - '
        '${event.endDate.hour < 12 ? event.endDate.hour == 0 ? 12 : event.endDate.hour : event.endDate.hour == 12 ? 12 : event.endDate.hour - 12}:00 ${event.endDate.hour < 12 ? 'AM' : 'PM'}',
      ),
      tileColor: event.color?.withOpacity(0.1),
      leading: Container(
        width: 4,
        color: event.color ?? Colors.blue,
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime date) {
    return widget.events?.where((event) {
          return event.startDate.year == date.year &&
              event.startDate.month == date.month &&
              event.startDate.day == date.day;
        }).toList() ??
        [];
  }

  List<Event> _getEventsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return widget.events?.where((event) {
          return event.startDate.isAfter(weekStart) &&
              event.startDate.isBefore(weekEnd);
        }).toList() ??
        [];
  }

  List<Event> _getEventsForMonth(DateTime monthStart) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
    return widget.events?.where((event) {
          return event.startDate.isAfter(monthStart) &&
              event.startDate.isBefore(monthEnd);
        }).toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          key: const Key('viewSwitchButton'),
          icon: Icon(_currentView == CalendarViewType.daily
              ? Icons.calendar_month
              : Icons.calendar_view_day),
          onPressed: () {
            setState(() {
              _currentView = _currentView == CalendarViewType.daily
                  ? CalendarViewType.monthly
                  : CalendarViewType.daily;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (_currentView == CalendarViewType.daily) {
                setState(() {
                  if (details.primaryVelocity! < 0) {
                    // Swipe left - next day
                    _currentDate = _currentDate.add(const Duration(days: 1));
                  } else {
                    // Swipe right - previous day
                    _currentDate =
                        _currentDate.subtract(const Duration(days: 1));
                  }
                });
              }
            },
            child: _currentView == CalendarViewType.daily
                ? _buildDailyView()
                : _buildMonthlyView(),
          ),
        ),
      ],
    );
  }
}
