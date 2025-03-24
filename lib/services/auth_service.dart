import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static Database? _database;
  static const String tableName = 'users';
  static const String userPreferencesTable = 'user_preferences';
  static String? _currentUserId;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'calendar.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tableName(
              id TEXT PRIMARY KEY,
              email TEXT UNIQUE NOT NULL,
              name TEXT NOT NULL,
              password TEXT NOT NULL,
              photoUrl TEXT,
              preferences TEXT
            )
          ''');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<User?> getCurrentUser() async {
    try {
      if (_currentUserId == null) return null;

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [_currentUserId],
      );

      if (maps.isEmpty) {
        _currentUserId = null;
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(password);

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (maps.isEmpty) return null;

      _currentUserId = maps.first['id'] as String;
      return User.fromMap(maps.first);
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _currentUserId = null;
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  Future<User> register(String email, String name, String password) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(password);
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final user = User(
        id: id,
        email: email,
        name: name,
      );

      await db.insert(
        tableName,
        {
          ...user.toMap(),
          'password': hashedPassword,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return user;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  Future<bool> resetPassword(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return false;

    // In a real app, you would:
    // 1. Generate a reset token
    // 2. Send an email with the reset link
    // 3. Store the token with an expiration time
    return true;
  }

  Future<void> updateUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    final db = await database;
    await db.insert(
      userPreferencesTable,
      {
        'userId': userId,
        'preferences': jsonEncode(preferences),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      userPreferencesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return {};

    return jsonDecode(maps.first['preferences'] as String);
  }
}
