import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/models/event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() {
  late DatabaseService databaseService;

  setUpAll(() async {
    // Initialize FFI for sqflite
    sqfliteFfiInit();
    // Set the database factory
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseService = DatabaseService();
    await databaseService.initialize();
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('DatabaseService Tests', () {
    test('database initialization - should create tables', () async {
      final db = await databaseService.database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name IN (?, ?)',
        whereArgs: ['table', 'users', 'events'],
      );
      expect(tables.length, 2);
    });

    test('users table schema - should have correct columns', () async {
      final db = await databaseService.database;
      final tableInfo = await db.query('pragma_table_info("users")');
      final columnNames =
          tableInfo.map((col) => col['name'] as String).toList();
      expect(columnNames, containsAll(['id', 'email', 'password']));
    });

    test('events table schema - should have correct columns', () async {
      final db = await databaseService.database;
      final tableInfo = await db.query('pragma_table_info("events")');
      final columnNames =
          tableInfo.map((col) => col['name'] as String).toList();
      expect(
        columnNames,
        containsAll([
          'id',
          'title',
          'description',
          'start_time',
          'end_time',
          'user_id',
          'local_id',
          'is_all_day',
          'color',
        ]),
      );
    });

    test('insertEvent - should create new event', () async {
      final db = await databaseService.database;
      final event = {
        'title': 'Test Event',
        'description': 'Test Description',
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
        'is_all_day': 0,
      };

      final id = await db.insert('events', event);
      expect(id, isNotNull);
      expect(id, isPositive);

      final inserted = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(inserted.length, 1);
      expect(inserted.first['title'], 'Test Event');
    });

    test('updateEvent - should modify existing event', () async {
      final db = await databaseService.database;
      final event = {
        'title': 'Original Title',
        'description': 'Original Description',
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
        'is_all_day': 0,
      };

      final id = await db.insert('events', event);
      await db.update(
        'events',
        {
          'title': 'Updated Title',
          'description': 'Updated Description',
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      final updated = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(updated.length, 1);
      expect(updated.first['title'], 'Updated Title');
      expect(updated.first['description'], 'Updated Description');
    });

    test('deleteEvent - should remove event', () async {
      final db = await databaseService.database;
      final event = {
        'title': 'Test Event',
        'description': 'Test Description',
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
        'is_all_day': 0,
      };

      final id = await db.insert('events', event);
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );

      final deleted = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(deleted.length, 0);
    });

    test('getEventsForUser - should return user events', () async {
      final db = await databaseService.database;
      final userId = 1;
      final event = {
        'title': 'User Event',
        'description': 'User Description',
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
        'user_id': userId,
        'is_all_day': 0,
      };

      await db.insert('events', event);
      final events = await db.query(
        'events',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      expect(events.length, 1);
      expect(events.first['title'], 'User Event');
    });

    test('getEventsForDateRange - should return events in date range',
        () async {
      final db = await databaseService.database;
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final event = {
        'title': 'Range Event',
        'description': 'Range Description',
        'start_time': start.toUtc().toIso8601String(),
        'end_time': end.toUtc().toIso8601String(),
        'is_all_day': 0,
      };

      await db.insert('events', event);
      final events = await db.query(
        'events',
        where: 'start_time >= ? AND end_time <= ?',
        whereArgs: [
          start.toUtc().toIso8601String(),
          end.toUtc().toIso8601String(),
        ],
      );

      expect(events.length, 1);
      expect(events.first['title'], 'Range Event');
    });
  });
}
