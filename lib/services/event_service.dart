import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/auth_service.dart';
import 'package:calendar_app/services/logging_service.dart';
import 'package:logging/logging.dart';

class EventService {
  static EventService? _instance;
  static Database? _database;
  static const String tableName = 'events';
  static const String _localIdKey = 'local_events_id';
  final _log = LoggingService.getLogger('EventService');
  final AuthService _authService = AuthService();

  factory EventService() {
    _instance ??= EventService._internal();
    return _instance!;
  }

  EventService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      _log.info('Initializing EventService database...');
      final db = await _authService.database;

      // Ensure the events table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS events(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          is_all_day INTEGER NOT NULL DEFAULT 0,
          color INTEGER,
          user_id TEXT,
          local_id TEXT
        )
      ''');

      await _ensureLocalId(db);
      return db;
    } catch (e, stackTrace) {
      _log.severe('Error initializing EventService database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _ensureLocalId(Database db) async {
    try {
      _log.info('Ensuring local ID exists...');

      // First ensure the preferences table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preferences(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> result = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['local_id'],
      );

      if (result.isEmpty) {
        final localId = DateTime.now().millisecondsSinceEpoch.toString();
        await db.insert('preferences', {
          'key': 'local_id',
          'value': localId,
        });
        _log.info('Created new local ID: $localId');
      } else {
        _log.info('Local ID already exists: ${result.first['value']}');
      }
    } catch (e, stackTrace) {
      _log.severe('Error ensuring local ID', e, stackTrace);
      rethrow;
    }
  }

  Future<String> getLocalId() async {
    try {
      _log.info('Getting local ID...');
      final db = await database;

      // First ensure the preferences table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preferences(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> maps = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: [_localIdKey],
      );

      if (maps.isEmpty) {
        _log.info('No local ID found, creating new one...');
        final localId = const Uuid().v4();
        await db.insert('preferences', {
          'key': _localIdKey,
          'value': localId,
        });
        _log.info('Created new local ID: $localId');
        return localId;
      }

      _log.info('Found existing local ID: ${maps[0]['value']}');
      return maps[0]['value'] as String;
    } catch (e, stackTrace) {
      _log.severe('Error getting local ID', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadEvents() async {
    try {
      _log.info('Loading events...');
      final db = await database;
      final events = await db.query(tableName);
      _log.info('Loaded ${events.length} events');
    } catch (e, stackTrace) {
      _log.severe('Error loading events', e, stackTrace);
      rethrow;
    }
  }

  Future<String> insertEvent(Event event) async {
    try {
      _log.info('Inserting event: ${event.title}');
      final db = await database;
      final id = const Uuid().v4();
      final eventMap = {
        ...event.toMap(),
        'id': id,
      };
      _log.info('Event data to insert: $eventMap');

      await db.insert(
        tableName,
        eventMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _log.info('Event inserted successfully with ID: $id');
      return id;
    } catch (e, stackTrace) {
      _log.severe('Error inserting event', e, stackTrace);
      rethrow;
    }
  }

  Future<void> associateEventsWithUser(String localId, String userId) async {
    try {
      _log.info('Associating events with user: $userId');
      final db = await database;
      await db.update(
        tableName,
        {'user_id': userId},
        where: 'local_id = ?',
        whereArgs: [localId],
      );
      _log.info('Events associated successfully');
    } catch (e, stackTrace) {
      _log.severe('Error associating events with user', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Event>> getEventsForDay(DateTime day, {String? userId}) async {
    try {
      _log.info('Getting events for day: ${day.toString()}');
      final db = await database;
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      String whereClause;
      List<dynamic> whereArgs;

      if (userId != null) {
        whereClause =
            'start_date >= ? AND start_date < ? AND (user_id = ? OR user_id IS NULL)';
        whereArgs = [
          startOfDay.toUtc().toIso8601String(),
          endOfDay.toUtc().toIso8601String(),
          userId,
        ];
      } else {
        whereClause = 'start_date >= ? AND start_date < ?';
        whereArgs = [
          startOfDay.toUtc().toIso8601String(),
          endOfDay.toUtc().toIso8601String(),
        ];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'start_date ASC',
      );

      _log.info('Found ${maps.length} events for the day');
      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e, stackTrace) {
      _log.severe('Error getting events for day', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      _log.info('Updating event: ${event.title}');
      final db = await database;
      await db.update(
        tableName,
        {
          'title': event.title,
          'description': event.description,
          'start_date': event.startDate.toUtc().toIso8601String(),
          'end_date': event.endDate.toUtc().toIso8601String(),
          'is_all_day': event.isAllDay ? 1 : 0,
          'color': event.color?.value,
          'user_id': event.userId,
          'local_id': event.localId,
        },
        where: 'id = ?',
        whereArgs: [event.id],
      );
      _log.info('Event updated successfully');
    } catch (e, stackTrace) {
      _log.severe('Error updating event', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      _log.info('Deleting event with ID: $id');
      final db = await database;
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      _log.info('Event deleted successfully');
    } catch (e, stackTrace) {
      _log.severe('Error deleting event', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Event>> getEventsForDateRange(DateTime start, DateTime end,
      {String? userId}) async {
    try {
      _log.info(
          'Getting events for date range: ${start.toString()} to ${end.toString()}');
      final db = await database;

      String whereClause;
      List<dynamic> whereArgs;

      if (userId != null) {
        whereClause =
            'start_date >= ? AND start_date < ? AND (user_id = ? OR user_id IS NULL)';
        whereArgs = [
          start.toUtc().toIso8601String(),
          end.toUtc().toIso8601String(),
          userId,
        ];
      } else {
        whereClause = 'start_date >= ? AND start_date < ?';
        whereArgs = [
          start.toUtc().toIso8601String(),
          end.toUtc().toIso8601String(),
        ];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'start_date ASC',
      );

      _log.info('Found ${maps.length} events in the date range');
      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e, stackTrace) {
      _log.severe('Error getting events for date range', e, stackTrace);
      rethrow;
    }
  }
}
