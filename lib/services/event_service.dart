import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';

class EventService {
  static Database? _database;
  static const String tableName = 'events';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calendar.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            startTime TEXT NOT NULL,
            endTime TEXT,
            color INTEGER,
            isAllDay INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> loadEvents() async {
    try {
      final db = await database;
      await db.query(tableName);
    } catch (e) {
      print('Error loading events: $e');
      rethrow;
    }
  }

  Future<int> insertEvent(Event event) async {
    try {
      final db = await database;
      return await db.insert(
        tableName,
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getEventsForDay(DateTime day) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'date(startTime) = ?',
        whereArgs: [day.toIso8601String().split('T')[0]],
      );

      return List.generate(maps.length, (i) {
        return Event.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting events for day: $e');
      return [];
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      final db = await database;
      await db.update(
        tableName,
        event.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      final db = await database;
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
}
