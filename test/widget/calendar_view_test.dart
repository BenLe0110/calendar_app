import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/widgets/calendar_view.dart';

void main() {
  group('CalendarView Widget Tests', () {
    testWidgets('Daily view shows correct date and time slots',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 19),
          ),
        ),
      );

      // Verify date is displayed
      expect(find.text('March 19'), findsOneWidget);

      // Verify time slots are shown (checking a few examples)
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('12:00 PM'), findsOneWidget);
      expect(find.text('5:00 PM'), findsOneWidget);
    });

    testWidgets('Monthly view shows correct month and days',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.monthly,
            selectedDate: DateTime(2024, 3, 1),
          ),
        ),
      );

      // Verify month is displayed
      expect(find.text('March 2024'), findsOneWidget);

      // Verify some day numbers are shown
      expect(find.text('1'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('Can switch between daily and monthly views',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 19),
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

    testWidgets('Can navigate between days in daily view',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 19),
          ),
        ),
      );

      // Initial date
      expect(find.text('March 19'), findsOneWidget);

      // Swipe left to next day
      await tester.drag(
        find.byKey(const Key('dailyViewContainer')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();

      // Verify date changed to next day
      expect(find.text('March 20'), findsOneWidget);

      // Swipe right to previous day
      await tester.drag(
        find.byKey(const Key('dailyViewContainer')),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // Verify back to original date
      expect(find.text('March 19'), findsOneWidget);
    });

    testWidgets('Shows events in daily view', (WidgetTester tester) async {
      final testEvents = [
        CalendarEvent(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          startTime: DateTime(2024, 3, 19, 10, 0),
          endTime: DateTime(2024, 3, 19, 11, 0),
        ),
      ];

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.daily,
            selectedDate: DateTime(2024, 3, 19),
            events: testEvents,
          ),
        ),
      );

      // Verify event is shown
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('10:00 AM - 11:00 AM'), findsOneWidget);
    });

    testWidgets('Shows event indicators in monthly view',
        (WidgetTester tester) async {
      final testEvents = [
        CalendarEvent(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          startTime: DateTime(2024, 3, 19, 10, 0),
          endTime: DateTime(2024, 3, 19, 11, 0),
        ),
      ];

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
            initialView: CalendarViewType.monthly,
            selectedDate: DateTime(2024, 3, 1),
            events: testEvents,
          ),
        ),
      );

      // Verify event indicator is shown on the correct day
      expect(
        find.byKey(const Key('eventIndicator-2024-03-19')),
        findsOneWidget,
      );
    });
  });
}
