import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/screens/main_screen.dart';
import 'package:calendar_app/models/event.dart';

void main() {
  late List<Event> testEvents;

  setUp(() {
    testEvents = [
      Event(
        id: 1,
        title: 'Test Event 1',
        description: 'Test Description 1',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      ),
      Event(
        id: 2,
        title: 'Test Event 2',
        description: 'Test Description 2',
        startDate: DateTime(2024, 3, 25, 14, 0),
        endDate: DateTime(2024, 3, 25, 15, 0),
        userId: 1,
      ),
    ];
  });

  group('MainScreen Tests', () {
    testWidgets('should display app bar with title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      expect(find.text('Calendar App'), findsOneWidget);
    });

    testWidgets('should display add event button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle add event button tap',
        (WidgetTester tester) async {
      bool addEventTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {
              addEventTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(addEventTapped, true);
    });

    testWidgets('should display events in calendar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Test Event 2'), findsOneWidget);
    });

    testWidgets('should handle event tap', (WidgetTester tester) async {
      Event? tappedEvent;
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {
              tappedEvent = event;
            },
            onAddEvent: () {},
          ),
        ),
      );

      await tester.tap(find.text('Test Event 1'));
      await tester.pumpAndSettle();

      expect(tappedEvent?.id, 1);
    });

    testWidgets('should handle empty events list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: [],
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      expect(find.text('Test Event 1'), findsNothing);
      expect(find.text('Test Event 2'), findsNothing);
    });

    testWidgets('should handle theme toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      // Verify theme has changed
      expect(find.byIcon(Icons.brightness_4), findsOneWidget);
    });

    testWidgets('should handle month navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      // Navigate to next month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Navigate to previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Verify we're back to the original month
      expect(find.text('March 2024'), findsOneWidget);
    });

    testWidgets('should handle event filtering', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(
            events: testEvents,
            onEventTap: (event) {},
            onAddEvent: () {},
          ),
        ),
      );

      // Open filter menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select a filter
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Verify filtered events are displayed
      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Test Event 2'), findsOneWidget);
    });
  });
}
