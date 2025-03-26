import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/services/event_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calendar_app/models/event.dart';
import 'package:uuid/uuid.dart';

// Generate mock classes
@GenerateMocks([Database])
import 'event_service_test.mocks.dart';

void main() {
  late EventService eventService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    eventService = EventService();
  });

  group('EventService Tests', () {
    test('getLocalId - should return existing local ID', () async {
      // Arrange
      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'key': 'local_events_id',
              'value': 'existing-local-id',
            }
          ]);

      // Act
      final localId = await eventService.getLocalId();

      // Assert
      expect(localId, 'existing-local-id');
      verify(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getLocalId - should create new local ID if not exists', () async {
      // Arrange
      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      when(mockDatabase.insert(
        'preferences',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      // Act
      final localId = await eventService.getLocalId();

      // Assert
      expect(localId, isA<String>());
      expect(localId.length, 36); // UUID length
      verify(mockDatabase.insert(
        'preferences',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
    });

    test('insertEvent - should create event with local ID', () async {
      // Arrange
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        startDate: DateTime(2024, 3, 15, 10, 0),
        endDate: DateTime(2024, 3, 15, 11, 0),
        userId: null,
        localId: null,
      );

      when(mockDatabase.insert(
        'events',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'key': 'local_events_id',
              'value': 'test-local-id',
            }
          ]);

      // Act
      final result = await eventService.insertEvent(event);

      // Assert
      expect(result, 1);
      verify(mockDatabase.insert(
        'events',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
      verify(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('associateEventsWithUser - should update events with user ID',
        () async {
      // Arrange
      when(mockDatabase.update(
        'events',
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act
      await eventService.associateEventsWithUser('test-local-id', 1);

      // Assert
      verify(mockDatabase.update(
        'events',
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getEventsForDay - should return events for user or local ID',
        () async {
      // Arrange
      final date = DateTime(2024, 3, 15);
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
              'local_id': 'test-local-id',
            }
          ]);

      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'key': 'local_events_id',
              'value': 'test-local-id',
            }
          ]);

      // Act
      final events = await eventService.getEventsForDay(date);

      // Assert
      expect(events.length, 1);
      expect(events[0].title, 'Test Event');
      expect(events[0].userId, 1);
      expect(events[0].localId, 'test-local-id');
      verify(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getEventsForDay - should return empty list when no events found',
        () async {
      // Arrange
      final date = DateTime(2024, 3, 15);
      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'key': 'local_events_id',
              'value': 'test-local-id',
            }
          ]);

      // Act
      final events = await eventService.getEventsForDay(date);

      // Assert
      expect(events, isEmpty);
    });

    test('getEventsForDay - should handle database errors', () async {
      // Arrange
      final date = DateTime(2024, 3, 15);
      when(mockDatabase.query(
        'events',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      when(mockDatabase.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'key': 'local_events_id',
              'value': 'test-local-id',
            }
          ]);

      // Act
      final events = await eventService.getEventsForDay(date);

      // Assert
      expect(events, isEmpty);
    });
  });
}
