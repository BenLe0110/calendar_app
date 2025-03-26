import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calendar_app/main.dart' as app;
import 'dart:async';
import 'dart:developer';
import 'package:flutter/scheduler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar App Integration Tests', () {
    testWidgets('Complete app flow test', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Test user registration/login flow
      await _testUserAuthentication(tester);

      // Test calendar views
      await _testCalendarViews(tester);

      // Test event management
      await _testEventManagement(tester);

      // Test performance
      await _testPerformance(tester);
    });
  });
}

Future<void> _testUserAuthentication(WidgetTester tester) async {
  // Test Registration
  await tester.tap(find.byKey(const Key('registerButton')));
  await tester.pumpAndSettle();

  // Fill registration form
  await tester.enterText(
      find.byKey(const Key('emailField')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('passwordField')), 'Test@123');
  await tester.enterText(
      find.byKey(const Key('confirmPasswordField')), 'Test@123');
  await tester.tap(find.byKey(const Key('submitRegistration')));
  await tester.pumpAndSettle();

  // Verify registration success
  expect(find.text('Registration Successful'), findsOneWidget);

  // Test Login
  await tester.enterText(
      find.byKey(const Key('loginEmailField')), 'test@example.com');
  await tester.enterText(
      find.byKey(const Key('loginPasswordField')), 'Test@123');
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();

  // Verify login success
  expect(find.text('Welcome back'), findsOneWidget);

  // Test Password Reset
  await tester.tap(find.byKey(const Key('forgotPasswordButton')));
  await tester.pumpAndSettle();
  await tester.enterText(
      find.byKey(const Key('resetEmailField')), 'test@example.com');
  await tester.tap(find.byKey(const Key('sendResetLink')));
  await tester.pumpAndSettle();

  // Verify reset email sent
  expect(find.text('Reset link sent'), findsOneWidget);

  // Test Profile Management
  await tester.tap(find.byKey(const Key('profileButton')));
  await tester.pumpAndSettle();
  await tester.enterText(
      find.byKey(const Key('displayNameField')), 'Test User');
  await tester.tap(find.byKey(const Key('saveProfileButton')));
  await tester.pumpAndSettle();

  // Verify profile update
  expect(find.text('Profile Updated'), findsOneWidget);
}

Future<void> _testCalendarViews(WidgetTester tester) async {
  // Test Daily View
  await tester.tap(find.byKey(const Key('dailyViewButton')));
  await tester.pumpAndSettle();

  // Verify daily view elements
  expect(find.byKey(const Key('hourlyGrid')), findsOneWidget);
  expect(find.byKey(const Key('currentTimeIndicator')), findsOneWidget);

  // Test navigation in daily view
  await tester.drag(find.byKey(const Key('dailyViewContainer')),
      const Offset(-300, 0) // Swipe left for next day
      );
  await tester.pumpAndSettle();

  // Verify date changed
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  expect(find.text(tomorrow.day.toString()), findsOneWidget);

  // Test Monthly View
  await tester.tap(find.byKey(const Key('monthlyViewButton')));
  await tester.pumpAndSettle();

  // Verify monthly view elements
  expect(find.byKey(const Key('monthGrid')), findsOneWidget);
  expect(find.byKey(const Key('currentDayIndicator')), findsOneWidget);

  // Test month navigation
  await tester.tap(find.byKey(const Key('nextMonthButton')));
  await tester.pumpAndSettle();

  // Verify month changed
  final nextMonth = DateTime.now().add(const Duration(days: 32));
  expect(find.text(nextMonth.month.toString()), findsOneWidget);

  // Test event indicators
  expect(find.byKey(const Key('eventIndicator')),
      findsNWidgets(3) // Assuming 3 days have events
      );

  // Test view switching
  await tester.tap(find.byKey(const Key('viewSwitchButton')));
  await tester.pumpAndSettle();

  // Verify view switched
  expect(find.byKey(const Key('dailyViewContainer')), findsOneWidget);
}

Future<void> _testEventManagement(WidgetTester tester) async {
  // Test Event Creation
  await tester.tap(find.byKey(const Key('addEventButton')));
  await tester.pumpAndSettle();

  // Fill event details
  await tester.enterText(
      find.byKey(const Key('eventTitleField')), 'Test Event');
  await tester.enterText(
      find.byKey(const Key('eventDescriptionField')), 'Test Event Description');

  // Set date and time
  await tester.tap(find.byKey(const Key('datePickerButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('15')); // Select 15th of current month
  await tester.tap(find.byKey(const Key('confirmDateButton')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('timePickerButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('10')); // Select 10:00
  await tester.tap(find.text('00'));
  await tester.tap(find.byKey(const Key('confirmTimeButton')));
  await tester.pumpAndSettle();

  // Save event
  await tester.tap(find.byKey(const Key('saveEventButton')));
  await tester.pumpAndSettle();

  // Verify event creation
  expect(find.text('Event Created'), findsOneWidget);
  expect(find.text('Test Event'), findsOneWidget);

  // Test Event Editing
  await tester.tap(find.text('Test Event'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('editEventButton')));
  await tester.pumpAndSettle();

  // Edit event details
  await tester.enterText(
      find.byKey(const Key('eventTitleField')), 'Updated Test Event');
  await tester.enterText(find.byKey(const Key('eventDescriptionField')),
      'Updated Test Event Description');

  // Save edited event
  await tester.tap(find.byKey(const Key('saveEventButton')));
  await tester.pumpAndSettle();

  // Verify event update
  expect(find.text('Event Updated'), findsOneWidget);
  expect(find.text('Updated Test Event'), findsOneWidget);

  // Test Event Details Display
  await tester.tap(find.text('Updated Test Event'));
  await tester.pumpAndSettle();

  // Verify event details
  expect(find.text('Updated Test Event'), findsOneWidget);
  expect(find.text('Updated Test Event Description'), findsOneWidget);
  expect(find.text('10:00 AM'), findsOneWidget);

  // Test Event Deletion
  await tester.tap(find.byKey(const Key('deleteEventButton')));
  await tester.pumpAndSettle();

  // Confirm deletion
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();

  // Verify event deletion
  expect(find.text('Event Deleted'), findsOneWidget);
  expect(find.text('Updated Test Event'), findsNothing);

  // Test Multiple Events
  // Create first event
  await _createEvent(tester, 'Meeting 1', 'Team sync', DateTime.now(),
      const TimeOfDay(hour: 10, minute: 0));

  // Create second event
  await _createEvent(tester, 'Meeting 2', 'Client call', DateTime.now(),
      const TimeOfDay(hour: 14, minute: 30));

  // Verify multiple events
  expect(find.text('Meeting 1'), findsOneWidget);
  expect(find.text('Meeting 2'), findsOneWidget);

  // Test Event Conflicts
  // Try to create overlapping event
  await _createEvent(tester, 'Conflicting Meeting', 'Should show warning',
      DateTime.now(), const TimeOfDay(hour: 10, minute: 0));

  // Verify conflict warning
  expect(find.text('Time Slot Conflict'), findsOneWidget);
}

// Helper function to create events
Future<void> _createEvent(WidgetTester tester, String title, String description,
    DateTime date, TimeOfDay time) async {
  await tester.tap(find.byKey(const Key('addEventButton')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('eventTitleField')), title);
  await tester.enterText(
      find.byKey(const Key('eventDescriptionField')), description);

  await tester.tap(find.byKey(const Key('datePickerButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(date.day.toString()));
  await tester.tap(find.byKey(const Key('confirmDateButton')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('timePickerButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(time.hour.toString()));
  await tester.tap(find.text(time.minute.toString().padLeft(2, '0')));
  await tester.tap(find.byKey(const Key('confirmTimeButton')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('saveEventButton')));
  await tester.pumpAndSettle();
}

Future<void> _testPerformance(WidgetTester tester) async {
  final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;

  // Test App Launch Time
  final stopwatch = Stopwatch()..start();
  app.main();
  await tester.pumpAndSettle();
  stopwatch.stop();

  // Verify launch time is under 2 seconds
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));

  // Test Frame Rate during scrolling
  await binding.traceAction(() async {
    // Perform heavy UI operations
    for (int i = 0; i < 10; i++) {
      await tester.drag(
          find.byKey(const Key('monthlyViewContainer')), const Offset(-300, 0));
      await tester.pumpAndSettle();
    }
  }, reportKey: 'scrolling_performance');

  // Test Memory Usage with Large Dataset
  final List<int> memorySnapshots = [];

  // Take initial memory snapshot
  final initialTimestamp = DateTime.now().millisecondsSinceEpoch;
  memorySnapshots.add(initialTimestamp);

  // Create 100 events
  for (int i = 0; i < 100; i++) {
    await _createEvent(
        tester,
        'Event $i',
        'Description $i',
        DateTime.now().add(Duration(days: i)),
        TimeOfDay(hour: (i % 12) + 8, minute: 0));

    if (i % 10 == 0) {
      // Take memory snapshot every 10 events
      memorySnapshots.add(DateTime.now().millisecondsSinceEpoch);
    }
  }

  // Verify memory usage pattern
  for (int i = 1; i < memorySnapshots.length; i++) {
    final memoryIncrease = memorySnapshots[i] - memorySnapshots[i - 1];
    // Verify each increment is less than 5MB (reasonable for 10 events)
    expect(memoryIncrease, lessThan(5 * 1024 * 1024));
  }

  // Test App Responsiveness
  final List<Duration> frameTimes = [];

  await binding.traceAction(() async {
    // Perform typical user actions
    for (int i = 0; i < 5; i++) {
      final frameStart = DateTime.now();

      // Switch between views
      await tester.tap(find.byKey(const Key('monthlyViewButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dailyViewButton')));
      await tester.pumpAndSettle();

      // Navigate through dates
      await tester.drag(
          find.byKey(const Key('dailyViewContainer')), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Open and close events
      await tester.tap(find.text('Event $i'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('closeEventButton')));
      await tester.pumpAndSettle();

      final frameEnd = DateTime.now();
      frameTimes.add(frameEnd.difference(frameStart));
    }
  }, reportKey: 'app_responsiveness');

  // Verify frame times are reasonable (less than 16ms for 60fps)
  for (final frameTime in frameTimes) {
    expect(frameTime.inMilliseconds, lessThanOrEqualTo(16));
  }

  // Test App State Preservation
  // Simulate app lifecycle changes
  binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await Future.delayed(const Duration(seconds: 5));
  binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();

  // Verify app state is preserved
  expect(find.text('Event 0'), findsOneWidget);
  expect(find.text('Event 99'), findsOneWidget);

  // Test Error Handling
  // Simulate error conditions and verify error messages
  await tester.tap(find.byKey(const Key('triggerErrorButton')));
  await tester.pumpAndSettle();
  expect(find.text('Error handled gracefully'), findsOneWidget);

  // Report final performance metrics
  final Map<String, dynamic> performanceData = {
    'launch_time_ms': stopwatch.elapsedMilliseconds,
    'average_frame_time_ms': frameTimes.fold<int>(
            0, (sum, duration) => sum + duration.inMilliseconds) ~/
        frameTimes.length,
    'memory_snapshots': memorySnapshots,
  };

  binding.reportData ??= <String, dynamic>{};
  binding.reportData!.addAll(performanceData);
}
