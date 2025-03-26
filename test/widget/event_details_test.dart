import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/widgets/event_details.dart';
import 'package:calendar_app/models/event.dart';

void main() {
  late Event testEvent;

  setUp(() {
    testEvent = Event(
      id: 1,
      title: 'Test Event',
      description: 'Test Description',
      startDate: DateTime(2024, 3, 25, 10, 0),
      endDate: DateTime(2024, 3, 25, 11, 0),
      userId: 1,
    );
  });

  group('EventDetails Tests', () {
    testWidgets('should display event information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: testEvent,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify event details are displayed
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('March 25, 2024'), findsOneWidget);
      expect(find.text('10:00 AM - 11:00 AM'), findsOneWidget);
    });

    testWidgets('should handle edit button tap', (WidgetTester tester) async {
      bool editTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: testEvent,
              onEdit: () {
                editTapped = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify edit callback was called
      expect(editTapped, true);
    });

    testWidgets('should handle delete button tap', (WidgetTester tester) async {
      bool deleteTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: testEvent,
              onEdit: () {},
              onDelete: () {
                deleteTapped = true;
              },
            ),
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify delete callback was called
      expect(deleteTapped, true);
    });

    testWidgets('should show confirmation dialog before delete',
        (WidgetTester tester) async {
      bool deleteConfirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: testEvent,
              onEdit: () {},
              onDelete: () {
                deleteConfirmed = true;
              },
            ),
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Delete Event'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this event?'),
          findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify delete callback was called
      expect(deleteConfirmed, true);
    });

    testWidgets('should cancel delete when cancel is tapped',
        (WidgetTester tester) async {
      bool deleteConfirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: testEvent,
              onEdit: () {},
              onDelete: () {
                deleteConfirmed = true;
              },
            ),
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify delete callback was not called
      expect(deleteConfirmed, false);
    });

    testWidgets('should format date and time correctly',
        (WidgetTester tester) async {
      final event = Event(
        id: 2,
        title: 'Another Event',
        description: 'Another Description',
        startDate: DateTime(2024, 12, 31, 23, 59),
        endDate: DateTime(2025, 1, 1, 0, 0),
        userId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: event,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify date and time formatting
      expect(find.text('December 31, 2024'), findsOneWidget);
      expect(find.text('11:59 PM - 12:00 AM'), findsOneWidget);
    });

    testWidgets('should handle long descriptions', (WidgetTester tester) async {
      final event = Event(
        id: 3,
        title: 'Long Description Event',
        description:
            'This is a very long description that should wrap to multiple lines and be properly displayed in the event details view. It should handle text overflow correctly and maintain proper formatting.',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventDetails(
              event: event,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify long description is displayed
      expect(find.text('This is a very long description'), findsOneWidget);
    });
  });
}
