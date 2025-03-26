import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/services/logging_service.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static AuthService? _instance;
  static Database? _database;
  static const String tableName = 'users';
  static const String userPreferencesTable = 'user_preferences';
  static String? _currentUserId;
  final _log = LoggingService.getLogger('AuthService');
  final String? _customDatabasePath;

  factory AuthService({String? customDatabasePath}) {
    _instance ??= AuthService._internal(customDatabasePath);
    return _instance!;
  }

  AuthService._internal(this._customDatabasePath);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      _log.info('Starting database initialization...');
      String path;

      if (_customDatabasePath != null) {
        path = _customDatabasePath!;
      } else {
        final Directory documentsDirectory =
            await path_provider.getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'calendar.db');
      }
      _log.info('Database path: $path');

      if (Platform.isAndroid) {
        _log.info('Initializing database for Android platform');
        // Use regular sqflite for Android
        return await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      } else {
        _log.info('Initializing database for other platform using FFI');
        // Use FFI for other platforms
        final factory = databaseFactoryFfi;
        return await factory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ),
        );
      }
    } catch (e, stackTrace) {
      _log.severe('Error initializing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      _log.info('Creating database tables...');

      _log.info('Creating users table...');
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
      _log.info('Users table created successfully');

      _log.info('Creating user preferences table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $userPreferencesTable(
          userId TEXT PRIMARY KEY,
          preferences TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES $tableName (id)
        )
      ''');
      _log.info('User preferences table created successfully');

      _log.info('Creating preferences table for local ID...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preferences(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      _log.info('Preferences table created successfully');

      _log.info('Creating events table...');
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
      _log.info('Events table created successfully');
    } catch (e, stackTrace) {
      _log.severe('Error creating database tables', e, stackTrace);
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
    } catch (e, stackTrace) {
      _log.warning('Error getting current user', e, stackTrace);
      return null;
    }
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(password);

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (maps.isEmpty) {
        _log.info('Login failed for email: $email');
        return null;
      }

      _currentUserId = maps.first['id'] as String;
      _log.info('User logged in successfully: $email');
      return User.fromMap(maps.first);
    } catch (e, stackTrace) {
      _log.severe('Error during login', e, stackTrace);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final oldUserId = _currentUserId;
      _currentUserId = null;
      _log.info('User logged out successfully: $oldUserId');
    } catch (e, stackTrace) {
      _log.severe('Error during logout', e, stackTrace);
      rethrow;
    }
  }

  Future<User> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      if (email.isEmpty || name.isEmpty || password.isEmpty) {
        throw AuthException('Email, name, and password cannot be empty');
      }

      final db = await database;
      final hashedPassword = _hashPassword(password);
      final id = const Uuid().v4();

      final user = User(
        id: id,
        email: email,
        name: name,
      );

      // Check if email already exists
      final List<Map<String, dynamic>> existingUser = await db.query(
        tableName,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        _log.warning('Registration failed: Email already exists: $email');
        throw AuthException('Email already exists');
      }

      await db.insert(
        tableName,
        {
          'id': id,
          'email': email,
          'name': name,
          'password': hashedPassword,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Initialize empty preferences
      await db.insert(
        userPreferencesTable,
        {
          'userId': id,
          'preferences': '{}',
        },
      );

      _log.info('User registered successfully: $email');
      return user;
    } catch (e, stackTrace) {
      _log.severe('Error during registration', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> resetPassword(
      {required String email, required String newPassword}) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(newPassword);

      final result = await db.update(
        tableName,
        {'password': hashedPassword},
        where: 'email = ?',
        whereArgs: [email],
      );

      return result > 0;
    } catch (e, stackTrace) {
      _log.severe('Error resetting password', e, stackTrace);
      return false;
    }
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

  String? getCurrentUserId() {
    return _currentUserId;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
