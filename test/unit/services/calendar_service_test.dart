import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/services/calendar_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calendar_app/models/event.dart';

// Generate mock classes
@GenerateMocks([Database])
import 'calendar_service_test.mocks.dart';

void main() {
  late CalendarService calendarService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    calendarService = CalendarService(database: mockDatabase);
  });

  group('CalendarService Tests', () {
    test('createEvent - should create new calendar event', () async {
      // Arrange
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      );

      when(mockDatabase.insert(
        'events',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      // Act
      final result = await calendarService.createEvent(event);

      // Assert
      expect(result, isTrue);
      verify(mockDatabase.insert(
        'events',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
    });

    test('createEvent - should handle database errors', () async {
      // Arrange
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      );

      when(mockDatabase.insert(
        'events',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await calendarService.createEvent(event);

      // Assert
      expect(result, isFalse);
    });

    test('getEvents - should return events for given date range', () async {
      // Arrange
      final startDate = DateTime(2024, 3, 25);
      final endDate = DateTime(2024, 3, 26);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'id': 1,
              'title': 'Test Event',
              'description': 'Test Description',
              'start_date': startDate.toIso8601String(),
              'end_date': endDate.toIso8601String(),
              'user_id': 1,
            }
          ]);

      // Act
      final events = await calendarService.getEvents(startDate, endDate);

      // Assert
      expect(events.length, 1);
      expect(events[0].title, 'Test Event');
      verify(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getEvents - should return empty list when no events found', () async {
      // Arrange
      final startDate = DateTime(2024, 3, 25);
      final endDate = DateTime(2024, 3, 26);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Act
      final events = await calendarService.getEvents(startDate, endDate);

      // Assert
      expect(events, isEmpty);
    });

    test('getEvents - should handle database errors', () async {
      // Arrange
      final startDate = DateTime(2024, 3, 25);
      final endDate = DateTime(2024, 3, 26);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      // Act
      final events = await calendarService.getEvents(startDate, endDate);

      // Assert
      expect(events, isEmpty);
    });

    test('updateEvent - should update existing event', () async {
      // Arrange
      final event = Event(
        id: 1,
        title: 'Updated Event',
        description: 'Updated Description',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      );

      when(mockDatabase.update(
        'events',
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act
      final result = await calendarService.updateEvent(event);

      // Assert
      expect(result, isTrue);
      verify(mockDatabase.update(
        'events',
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('updateEvent - should handle database errors', () async {
      // Arrange
      final event = Event(
        id: 1,
        title: 'Updated Event',
        description: 'Updated Description',
        startDate: DateTime(2024, 3, 25, 10, 0),
        endDate: DateTime(2024, 3, 25, 11, 0),
        userId: 1,
      );

      when(mockDatabase.update(
        'events',
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await calendarService.updateEvent(event);

      // Assert
      expect(result, isFalse);
    });

    test('deleteEvent - should delete existing event', () async {
      // Arrange
      when(mockDatabase.delete(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act
      final result = await calendarService.deleteEvent(1);

      // Assert
      expect(result, isTrue);
      verify(mockDatabase.delete(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('deleteEvent - should handle database errors', () async {
      // Arrange
      when(mockDatabase.delete(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await calendarService.deleteEvent(1);

      // Assert
      expect(result, isFalse);
    });

    test('getEventsByDate - should return events for specific date', () async {
      // Arrange
      final date = DateTime(2024, 3, 25);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'id': 1,
              'title': 'Test Event',
              'description': 'Test Description',
              'start_date': date.toIso8601String(),
              'end_date': date.toIso8601String(),
              'user_id': 1,
            }
          ]);

      // Act
      final events = await calendarService.getEventsByDate(date);

      // Assert
      expect(events.length, 1);
      expect(events[0].title, 'Test Event');
      verify(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getEventsByDate - should return empty list when no events found',
        () async {
      // Arrange
      final date = DateTime(2024, 3, 25);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Act
      final events = await calendarService.getEventsByDate(date);

      // Assert
      expect(events, isEmpty);
    });

    test('getEventsByDate - should handle database errors', () async {
      // Arrange
      final date = DateTime(2024, 3, 25);

      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      // Act
      final events = await calendarService.getEventsByDate(date);

      // Assert
      expect(events, isEmpty);
    });
  });
}
