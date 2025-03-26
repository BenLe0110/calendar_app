import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final Function(DateTime) onDateSelected;
  final Function(Event) onEventTap;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, daysInMonth);
    final daysInWeek = 7;
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];

    // Add days from previous month
    final firstWeekday = firstDayOfMonth.weekday;
    for (var i = firstWeekday - 1; i > 0; i--) {
      currentWeek.add(firstDayOfMonth.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (var day = 1; day <= daysInMonth; day++) {
      currentWeek.add(DateTime(selectedDate.year, selectedDate.month, day));
      if (currentWeek.length == daysInWeek) {
        weeks.add(List.from(currentWeek));
        currentWeek = [];
      }
    }

    // Add days from next month
    while (currentWeek.length < daysInWeek) {
      currentWeek
          .add(lastDayOfMonth.add(Duration(days: currentWeek.length + 1)));
    }
    weeks.add(currentWeek);

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ))
              .toList(),
        ),
        const Divider(),
        // Calendar grid
        Expanded(
          child: ListView.builder(
            itemCount: weeks.length,
            itemBuilder: (context, weekIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weeks[weekIndex].map((date) {
                  final isCurrentMonth = date.month == selectedDate.month;
                  final isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;
                  final dayEvents = events.where((event) {
                    return event.startDate.year == date.year &&
                        event.startDate.month == date.month &&
                        event.startDate.day == date.day;
                  }).toList();

                  return GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isCurrentMonth
                                  ? isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                            ),
                          ),
                          if (dayEvents.isNotEmpty)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
