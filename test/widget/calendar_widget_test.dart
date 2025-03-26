import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/widgets/calendar/calendar_view.dart';
import 'package:calendar_app/widgets/calendar/views/daily_view.dart';
import 'package:calendar_app/widgets/calendar/views/monthly_view.dart';
import 'package:calendar_app/widgets/calendar/events/event_widget.dart';
import 'package:intl/intl.dart';

// Mock events for testing
final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Morning Meeting',
    description: 'Team sync',
    startDate: DateTime(2024, 3, 15, 9, 0),
    endDate: DateTime(2024, 3, 15, 10, 0),
    color: Colors.blue,
    isAllDay: false,
  ),
  Event(
    id: '2',
    title: 'All Day Event',
    description: 'Company holiday',
    startDate: DateTime(2024, 3, 15),
    endDate: DateTime(2024, 3, 15, 23, 59),
    color: Colors.red,
    isAllDay: true,
  ),
  Event(
    id: '3',
    title: 'Evening Meeting',
    description: 'Project review',
    startDate: DateTime(2024, 3, 15, 14, 0),
    endDate: DateTime(2024, 3, 15, 15, 0),
    color: Colors.green,
    isAllDay: false,
  ),
];

void main() {
  group('Calendar Widget Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 3, 15);
    });

    testWidgets('should initialize calendar with correct date',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialView: CalendarViewType.monthly,
              selectedDate: testDate,
              events: mockEvents,
            ),
          ),
        ),
      );

      // Verify month and year are displayed correctly
      expect(find.text('March 2024'), findsOneWidget);
    });

    testWidgets('should display event indicators in monthly view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialView: CalendarViewType.monthly,
              selectedDate: testDate,
              events: mockEvents,
            ),
          ),
        ),
      );

      // Verify event indicator is present for day 15
      expect(
        find.byKey(Key('eventIndicator-2024-03-15')),
        findsOneWidget,
      );
    });

    testWidgets('should switch between daily and monthly views',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialView: CalendarViewType.monthly,
              selectedDate: testDate,
              events: mockEvents,
            ),
          ),
        ),
      );

      // Find and tap the view switch button
      await tester.tap(find.byKey(const Key('viewSwitchButton')));
      await tester.pumpAndSettle();

      // Verify we're in daily view
      expect(find.text('March 15'), findsOneWidget);

      // Switch back to monthly view
      await tester.tap(find.byKey(const Key('viewSwitchButton')));
      await tester.pumpAndSettle();

      // Verify we're back in monthly view
      expect(find.text('March 2024'), findsOneWidget);
    });

    testWidgets('should handle day navigation in daily view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialView: CalendarViewType.daily,
              selectedDate: testDate,
              events: mockEvents,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial date should be March 15
      expect(find.text('March 15'), findsOneWidget);

      // Find the GestureDetector that's a direct child of Material
      final gestureDetector = find
          .descendant(
            of: find.byType(Material),
            matching: find.byType(GestureDetector),
            matchRoot: true,
          )
          .first;

      // Swipe left to next day
      await tester.fling(
        gestureDetector,
        const Offset(-100, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Next day should be March 16
      expect(find.text('March 16'), findsOneWidget);

      // Swipe right to previous day
      await tester.fling(
        gestureDetector,
        const Offset(100, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Previous day should be March 15
      expect(find.text('March 15'), findsOneWidget);
    });

    testWidgets('should display events in daily view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialView: CalendarViewType.daily,
              selectedDate: testDate,
              events: mockEvents,
            ),
          ),
        ),
      );

      // Verify all events for the day are displayed
      expect(find.text('Morning Meeting'), findsOneWidget);
      expect(find.text('All Day Event'), findsOneWidget);
      expect(find.text('Evening Meeting'), findsOneWidget);
    });
  });
}
