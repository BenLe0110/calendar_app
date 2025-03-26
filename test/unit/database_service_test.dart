import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/models/event.dart';
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseService = DatabaseService(useInMemoryDatabase: true);
    await databaseService.initialize();
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('DatabaseService Tests', () {
    group('Database Initialization', () {
      test('should initialize database successfully', () async {
        final db = await databaseService.database;
        expect(db, isNotNull);
      });

      test('should close database successfully', () async {
        await databaseService.close();
        final db = await databaseService.database;
        expect(db, isNotNull); // Should create new connection
      });

      test('should handle multiple initialization calls', () async {
        await databaseService.initialize();
        await databaseService.initialize();
        final db = await databaseService.database;
        expect(db, isNotNull);
      });
    });

    group('Schema Tests', () {
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

      test('users table schema - should have correct columns', () async {
        final db = await databaseService.database;
        final List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
        );

        expect(tables.length, 1);

        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info('users')",
        );

        final columnNames = columns.map((c) => c['name'] as String).toList();
        expect(
          columnNames,
          containsAll([
            'id',
            'email',
            'password',
            'name',
            'preferences',
          ]),
        );
      });
    });

    group('User Operations', () {
      test('should insert user successfully', () async {
        final db = await databaseService.database;
        final userId = const Uuid().v4();

        await db.insert('users', {
          'id': userId,
          'email': 'test1@example.com',
          'password': 'hashed_password',
          'name': 'Test User',
          'preferences': '{}',
        });

        final List<Map<String, dynamic>> users = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        expect(users.length, 1);
        expect(users.first['email'], 'test1@example.com');
        expect(users.first['name'], 'Test User');
      });

      test('should enforce unique email constraint', () async {
        final db = await databaseService.database;
        final userId1 = const Uuid().v4();
        final userId2 = const Uuid().v4();

        await db.insert('users', {
          'id': userId1,
          'email': 'test2@example.com',
          'password': 'hashed_password',
          'name': 'Test User 1',
          'preferences': '{}',
        });

        await expectLater(
          () => db.insert('users', {
            'id': userId2,
            'email': 'test2@example.com',
            'password': 'hashed_password',
            'name': 'Test User 2',
            'preferences': '{}',
          }),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('Event Operations', () {
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
        expect(maps.first['start_date'],
            event.startDate.toUtc().toIso8601String());
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

      test('getEvent - should return null for non-existent event', () async {
        final event = await databaseService.getEvent('non_existent_id');
        expect(event, null);
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

      test('getEventsForDateRange - should handle edge cases', () async {
        final now = DateTime.now();
        final events = [
          Event(
            id: const Uuid().v4(),
            title: 'Event 1',
            startDate: now,
            endDate: now.add(const Duration(hours: 1)),
            userId: const Uuid().v4(),
          ),
          Event(
            id: const Uuid().v4(),
            title: 'Event 2',
            startDate: now.add(const Duration(days: 2)),
            endDate: now.add(const Duration(days: 3)),
            userId: const Uuid().v4(),
          ),
        ];

        for (final event in events) {
          await databaseService.insertEvent(event);
        }

        final rangeEvents = await databaseService.getEventsForDateRange(
          now.subtract(const Duration(hours: 1)),
          now.add(const Duration(hours: 2)),
        );

        expect(rangeEvents.length, 1);
        expect(rangeEvents.first.title, 'Event 1');
      });
    });

    group('Transaction Handling', () {
      test('should rollback on error in transaction', () async {
        final db = await databaseService.database;
        final userId = const Uuid().v4();

        try {
          await db.transaction((txn) async {
            await txn.insert('users', {
              'id': userId,
              'email': 'test3@example.com',
              'password': 'hashed_password',
              'name': 'Test User',
              'preferences': '{}',
            });

            await txn.insert('events', {
              'id': const Uuid().v4(),
              'title': 'Test Event',
              'start_date': DateTime.now().toUtc().toIso8601String(),
              'end_date': DateTime.now()
                  .add(const Duration(hours: 1))
                  .toUtc()
                  .toIso8601String(),
              'user_id': userId,
              'is_all_day': 0,
            });

            throw Exception('Simulated error');
          });
        } catch (e) {
          // Expected error
        }

        final List<Map<String, dynamic>> users = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        expect(users.length, 0);
      });
    });
  });
}
