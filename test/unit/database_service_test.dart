import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/models/event.dart';
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseService databaseService;
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(':memory:');
    databaseService = DatabaseService();
    await databaseService.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseService Tests', () {
    test('events table schema - should have correct columns', () async {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='events'",
      );

      expect(tables.length, 1);

      final List<Map<String, dynamic>> columns = await db.rawQuery(
        "PRAGMA table_info('events')",
      );

      final columnNames = columns.map((c) => c['name'] as String).toList();
      expect(
        columnNames,
        containsAll([
          'id',
          'title',
          'description',
          'start_date',
          'end_date',
          'is_all_day',
          'color',
          'user_id',
          'local_id',
        ]),
      );
    });

    test('insertEvent - should create new event', () async {
      final now = DateTime.now();
      final event = Event(
        id: const Uuid().v4(),
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: const Uuid().v4(),
      );

      await databaseService.insertEvent(event);

      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [event.id],
      );

      expect(maps.length, 1);
      expect(maps.first['title'], event.title);
      expect(maps.first['description'], event.description);
      expect(
          maps.first['start_date'], event.startDate.toUtc().toIso8601String());
      expect(maps.first['end_date'], event.endDate.toUtc().toIso8601String());
      expect(maps.first['is_all_day'], event.isAllDay ? 1 : 0);
      expect(maps.first['color'], event.color?.value);
      expect(maps.first['user_id'], event.userId);
    });

    test('updateEvent - should modify existing event', () async {
      final now = DateTime.now();
      final event = Event(
        id: const Uuid().v4(),
        title: 'Original Title',
        description: 'Original Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: const Uuid().v4(),
      );

      await databaseService.insertEvent(event);

      final updatedEvent = Event(
        id: event.id,
        title: 'Updated Title',
        description: 'Updated Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: event.userId,
      );

      await databaseService.updateEvent(updatedEvent);

      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [event.id],
      );

      expect(maps.length, 1);
      expect(maps.first['title'], updatedEvent.title);
      expect(maps.first['description'], updatedEvent.description);
    });

    test('deleteEvent - should remove event', () async {
      final now = DateTime.now();
      final event = Event(
        id: const Uuid().v4(),
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: const Uuid().v4(),
      );

      await databaseService.insertEvent(event);
      await databaseService.deleteEvent(event.id!);

      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [event.id],
      );

      expect(maps.length, 0);
    });

    test('getEventsForUser - should return user events', () async {
      final now = DateTime.now();
      final userId = const Uuid().v4();
      final event = Event(
        id: const Uuid().v4(),
        title: 'User Event',
        description: 'User Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: userId,
      );

      await databaseService.insertEvent(event);

      final events = await databaseService.getEventsForUser(userId);
      expect(events.length, 1);
      expect(events.first.title, event.title);
      expect(events.first.description, event.description);
    });

    test('getEventsForDateRange - should return events in date range',
        () async {
      final now = DateTime.now();
      final event = Event(
        id: const Uuid().v4(),
        title: 'Range Event',
        description: 'Range Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: const Uuid().v4(),
      );

      await databaseService.insertEvent(event);

      final events = await databaseService.getEventsForDateRange(
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );

      expect(events.length, 1);
      expect(events.first.title, event.title);
      expect(events.first.description, event.description);
    });

    test('should get all events for user', () async {
      final events = [
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
          startDate: DateTime(2024, 3, 15, 14, 0),
          endDate: DateTime(2024, 3, 15, 15, 0),
          userId: 1,
        ),
        Event(
          id: 3,
          title: 'Test Event 3',
          description: 'Test Description 3',
          startDate: DateTime(2024, 3, 15, 16, 0),
          endDate: DateTime(2024, 3, 15, 17, 0),
          userId: 2,
        ),
      ];

      for (final event in events) {
        await databaseService.insertEvent(event);
      }

      final userEvents = await databaseService.getEventsForUser(1);
      expect(userEvents.length, 2);
      expect(userEvents[0].title, 'Test Event 1');
      expect(userEvents[1].title, 'Test Event 2');
    });

    test('should get events for date range', () async {
      final events = [
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
          startDate: DateTime(2024, 3, 16, 14, 0),
          endDate: DateTime(2024, 3, 16, 15, 0),
          userId: 1,
        ),
        Event(
          id: 3,
          title: 'Test Event 3',
          description: 'Test Description 3',
          startDate: DateTime(2024, 3, 17, 16, 0),
          endDate: DateTime(2024, 3, 17, 17, 0),
          userId: 1,
        ),
      ];

      for (final event in events) {
        await databaseService.insertEvent(event);
      }

      final startDate = DateTime(2024, 3, 15);
      final endDate = DateTime(2024, 3, 16);
      final rangeEvents =
          await databaseService.getEventsForDateRange(startDate, endDate);

      expect(rangeEvents.length, 2);
      expect(rangeEvents[0].title, 'Test Event 1');
      expect(rangeEvents[1].title, 'Test Event 2');
    });

    test('should handle null description', () async {
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: null,
        startDate: DateTime(2024, 3, 15, 10, 0),
        endDate: DateTime(2024, 3, 15, 11, 0),
        userId: 1,
      );

      final id = await databaseService.insertEvent(event);
      final retrievedEvent = await databaseService.getEvent(id);

      expect(retrievedEvent?.description, null);
    });
  });
}
