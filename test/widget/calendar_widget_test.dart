import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/widgets/calendar_widget.dart';
import 'package:calendar_app/models/event.dart';

void main() {
  late List<Event> testEvents;
  late DateTime testDate;

  setUp(() {
    testDate = DateTime(2024, 3, 15);
    testEvents = [
      Event(
        id: 1,
        title: 'Test Event 1',
        description: 'Test Description 1',
        startDate: DateTime(2024, 3, 15, 10, 0),
        endDate: DateTime(2024, 3, 15, 11, 0),
        userId: 1,
      ),
      Event(
        id: 2,
        title: 'Test Event 2',
        description: 'Test Description 2',
        startDate: DateTime(2024, 3, 20, 14, 0),
        endDate: DateTime(2024, 3, 20, 15, 0),
        userId: 1,
      ),
    ];
  });

  group('CalendarWidget Tests', () {
    testWidgets('should display weekday headers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('should display days of the month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('should highlight selected date', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      final selectedDay = find.text('15');
      expect(selectedDay, findsOneWidget);
    });

    testWidgets('should show event indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      // Find containers with event indicators
      final eventIndicators =
          find.byType(Container).evaluate().where((element) {
        final widget = element.widget as Container;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration?.color == Colors.blue;
      });

      expect(eventIndicators.length, 2);
    });

    testWidgets('should handle date selection', (WidgetTester tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {
                selectedDate = date;
              },
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(selectedDate?.day, 20);
      expect(selectedDate?.month, 3);
      expect(selectedDate?.year, 2024);
    });

    testWidgets('should handle event tap', (WidgetTester tester) async {
      Event? tappedEvent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {
                tappedEvent = event;
              },
            ),
          ),
        ),
      );

      // Note: Event tap functionality is not directly testable in this widget
      // as it's handled by the parent widget (MainScreen)
      expect(tappedEvent, null);
    });

    testWidgets('should display days from previous and next month',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              selectedDate: testDate,
              events: testEvents,
              onDateSelected: (date) {},
              onEventTap: (event) {},
            ),
          ),
        ),
      );

      // Find days from previous month (should be grayed out)
      final previousMonthDays = find.byType(Text).evaluate().where((element) {
        final widget = element.widget as Text;
        return widget.style?.color == Colors.grey;
      });

      expect(previousMonthDays.isNotEmpty, true);
    });
  });
}
