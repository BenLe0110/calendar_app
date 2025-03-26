import 'package:sqflite/sqflite.dart';
import 'package:calendar_app/models/event.dart';

class CalendarService {
  final Database _database;

  CalendarService({required Database database}) : _database = database;

  Future<bool> createEvent(Event event) async {
    try {
      final id = await _database.insert(
        'events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<Event>> getEvents(DateTime startDate, DateTime endDate) async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query(
        'events',
        where: 'start_date >= ? AND end_date <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      final count = await _database.update(
        'events',
        event.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    try {
      final count = await _database.delete(
        'events',
        where: 'id = ?',
        whereArgs: [eventId],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<Event>> getEventsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final List<Map<String, dynamic>> maps = await _database.query(
        'events',
        where: 'start_date >= ? AND end_date <= ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );
      return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<int> insertEvent(Event event) async {
    final db = await _database;
    return await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Event>> getEventsForDateRange(DateTime start, DateTime end,
      {int? userId}) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where:
          'start_date >= ? AND start_date < ? AND (user_id = ? OR user_id IS NULL)',
      whereArgs: [
        start.toUtc().toIso8601String(),
        end.toUtc().toIso8601String(),
        userId,
      ],
      orderBy: 'start_date ASC',
    );

    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }
}
