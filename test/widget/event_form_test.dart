import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/widgets/event_form.dart';
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

  group('EventForm Tests', () {
    testWidgets('should display empty form for new event',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {},
            ),
          ),
        ),
      );

      // Verify form fields are empty
      expect(find.text(''), findsNWidgets(2)); // Title and description fields
      expect(find.text('Create Event'), findsOneWidget);
    });

    testWidgets('should display event data for editing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              event: testEvent,
              onSubmit: (event) {},
            ),
          ),
        ),
      );

      // Verify form fields are populated
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {},
            ),
          ),
        ),
      );

      // Try to submit without filling required fields
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('should validate date range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {},
            ),
          ),
        ),
      );

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'Test Event');
      await tester.enterText(
          find.byType(TextFormField).last, 'Test Description');

      // Set end date before start date
      await tester.tap(find.text('Select End Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Start Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('End date must be after start date'), findsOneWidget);
    });

    testWidgets('should call onSubmit with form data',
        (WidgetTester tester) async {
      Event? submittedEvent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {
                submittedEvent = event;
              },
            ),
          ),
        ),
      );

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'New Event');
      await tester.enterText(
          find.byType(TextFormField).last, 'New Description');

      // Set dates
      await tester.tap(find.text('Select Start Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select End Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();

      // Verify submitted data
      expect(submittedEvent?.title, 'New Event');
      expect(submittedEvent?.description, 'New Description');
    });

    testWidgets('should handle cancel button', (WidgetTester tester) async {
      bool cancelled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {},
              onCancel: () {
                cancelled = true;
              },
            ),
          ),
        ),
      );

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify cancel callback was called
      expect(cancelled, true);
    });

    testWidgets('should handle keyboard actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventForm(
              onSubmit: (event) {},
            ),
          ),
        ),
      );

      // Enter text in title field
      await tester.enterText(find.byType(TextFormField).first, 'Test Event');
      await tester.testTextInput.receiveAction(TextInputAction.next);

      // Verify focus moved to description field
      expect(find.byType(TextFormField).last, findsOneWidget);
    });
  });
}
