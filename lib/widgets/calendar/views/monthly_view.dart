import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/event_service.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/common/animations/spacing.dart';
import 'package:calendar_app/widgets/common/animations/animated_container.dart';
import 'package:calendar_app/widgets/calendar/events/event_widget.dart';

class MonthlyView extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const MonthlyView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  final EventService _eventService = EventService();
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didUpdateWidget(MonthlyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    final startOfMonth = DateTime(
      widget.focusedDay.year,
      widget.focusedDay.month,
      1,
    );
    final endOfMonth = DateTime(
      widget.focusedDay.year,
      widget.focusedDay.month + 1,
      0,
    );

    final events = await _eventService.getEventsForDay(widget.focusedDay);
    final eventsByDay = <DateTime, List<Event>>{};

    for (var event in events) {
      if (event.isAllDay) {
        final day = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        eventsByDay[day] = [...(eventsByDay[day] ?? []), event];
      } else if (event.startDate.isAfter(startOfMonth) &&
          event.startDate.isBefore(endOfMonth)) {
        final day = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        eventsByDay[day] = [...(eventsByDay[day] ?? []), event];
      }
    }

    setState(() {
      _events = eventsByDay;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return CustomAnimatedContainer(
      duration: AppTheme.animationDurationNormal,
      padding: AppTheme.standardPadding(context),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        onDaySelected: widget.onDaySelected,
        onPageChanged: widget.onPageChanged,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Colors.red),
          holidayTextStyle: const TextStyle(color: Colors.red),
          markerSize: AppTheme.spacing8,
          markerDecoration: BoxDecoration(
            color: AppTheme.accentColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge ??
              const TextStyle(fontSize: 20),
          headerPadding:
              const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              final event = events.first as Event;
              return Positioned(
                bottom: 1,
                child: CustomAnimatedContainer(
                  duration: AppTheme.animationDurationFast,
                  child: Container(
                    width: AppTheme.spacing8,
                    height: AppTheme.spacing8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.color ?? AppTheme.accentColor,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
          selectedBuilder: (context, date, events) {
            return CustomAnimatedContainer(
              duration: AppTheme.animationDurationFast,
              child: Container(
                margin: const EdgeInsets.all(AppTheme.spacing4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, date, events) {
            return CustomAnimatedContainer(
              duration: AppTheme.animationDurationFast,
              child: Container(
                margin: const EdgeInsets.all(AppTheme.spacing4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.accentColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
