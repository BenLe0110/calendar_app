import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/widgets/calendar/calendar_view.dart';
import 'package:calendar_app/models/event.dart';

void main() {
  late List<Event> testEvents;

  setUp(() {
    testEvents = [
      Event(
        id: '1',
        title: 'All Day Event',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25),
        endDate: DateTime(2024, 3, 25, 23, 59),
        isAllDay: true,
        userId: '1',
      ),
      Event(
        id: '2',
        title: 'Morning Event',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: '1',
      ),
      Event(
        id: '3',
        title: 'Overlapping Event 1',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25, 14, 0),
        endDate: DateTime(2024, 3, 25, 16, 0),
        userId: '1',
      ),
      Event(
        id: '4',
        title: 'Overlapping Event 2',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25, 15, 0),
        endDate: DateTime(2024, 3, 25, 17, 0),
        userId: '1',
      ),
    ];
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('CalendarView Tests', () {
    testWidgets('should initialize in daily view', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 25),
            events: testEvents,
          ),
        ),
      );

      expect(find.byKey(const Key('dailyViewContainer')), findsOneWidget);
      expect(find.byKey(const Key('monthlyViewContainer')), findsNothing);
    });

    testWidgets('should switch between daily and monthly views',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 25),
            events: testEvents,
          ),
        ),
      );

      // Initially in daily view
      expect(find.byKey(const Key('dailyViewContainer')), findsOneWidget);
      expect(find.byKey(const Key('monthlyViewContainer')), findsNothing);

      // Switch to monthly view
      await tester.tap(find.byKey(const Key('viewSwitchButton')));
      await tester.pumpAndSettle();

      // Verify monthly view is shown
      expect(find.byKey(const Key('monthlyViewContainer')), findsOneWidget);
      expect(find.byKey(const Key('dailyViewContainer')), findsNothing);
    });

    testWidgets('should display events in daily view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 25),
            events: testEvents,
          ),
        ),
      );

      // Verify the date is displayed
      expect(find.text('March 25'), findsOneWidget);

      // Verify events are displayed
      expect(find.text('Morning Event'), findsOneWidget);
      expect(find.text('10:00 AM - 11:00 AM'), findsOneWidget);
      expect(find.text('Overlapping Event 1'), findsOneWidget);
      expect(find.text('2:00 PM - 4:00 PM'), findsOneWidget);
      expect(find.text('Overlapping Event 2'), findsOneWidget);
      expect(find.text('3:00 PM - 5:00 PM'), findsOneWidget);
    });

    testWidgets('should display event indicators in monthly view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CalendarView(
            initialView: CalendarViewType.monthly,
            selectedDate: DateTime(2024, 3, 25),
            events: testEvents,
          ),
        ),
      );

      // Verify month title is displayed
      expect(find.text('March 2024'), findsOneWidget);

      // Verify event indicator is present for the day with events
      expect(
        find.byKey(const Key('eventIndicator-2024-03-25')),
        findsOneWidget,
      );
    });

    testWidgets('should navigate between days in daily view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 25),
            events: testEvents,
          ),
        ),
      );

      // Initial date
      expect(find.text('March 25'), findsOneWidget);

      // Swipe left to next day
      await tester.fling(
        find.byKey(const Key('dailyViewContainer')),
        const Offset(-300, 0),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify date changed to next day
      expect(find.text('March 26'), findsOneWidget);

      // Swipe right to previous day
      await tester.fling(
        find.byKey(const Key('dailyViewContainer')),
        const Offset(300, 0),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify back to original date
      expect(find.text('March 25'), findsOneWidget);
    });
  });
}
