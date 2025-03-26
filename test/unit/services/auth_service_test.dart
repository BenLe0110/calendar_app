import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calendar_app/services/auth_service.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AuthService authService;
  final dbPath =
      path.join('.dart_tool', 'test_databases', 'auth_service_test.db');

  setUp(() async {
    authService = AuthService(customDatabasePath: dbPath);
  });

  tearDown(() async {
    await authService.close();
    await databaseFactory.deleteDatabase(dbPath);
  });

  group('AuthService Tests', () {
    group('Registration', () {
      test('should register new user successfully', () async {
        final result = await authService.register(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );
        expect(result.email, equals('test@example.com'));
        expect(result.name, equals('Test User'));
      });

      test('should not allow duplicate email registration', () async {
        await authService.register(
          email: 'test2@example.com',
          password: 'password123',
          name: 'Test User 1',
        );

        expect(
            () => authService.register(
                  email: 'test2@example.com',
                  password: 'password456',
                  name: 'Test User 2',
                ),
            throwsA(isA<AuthException>()));
      });

      test('should create user preferences on registration', () async {
        final result = await authService.register(
          email: 'test3@example.com',
          password: 'password123',
          name: 'Test User',
        );

        final db = await authService.database;
        final prefs = await db.query('user_preferences',
            where: 'userId = ?', whereArgs: [result.id]);
        expect(prefs.length, 1);
        expect(prefs.first['preferences'], '{}');
      });
    });

    group('Authentication', () {
      test('should login successfully with correct credentials', () async {
        await authService.register(
          email: 'test4@example.com',
          password: 'password123',
          name: 'Test User',
        );

        final result = await authService.login(
          email: 'test4@example.com',
          password: 'password123',
        );
        expect(result, isNotNull);
        expect(result!.email, equals('test4@example.com'));
      });

      test('should not login with incorrect password', () async {
        await authService.register(
          email: 'test5@example.com',
          password: 'password123',
          name: 'Test User',
        );

        final result = await authService.login(
          email: 'test5@example.com',
          password: 'wrongpassword',
        );
        expect(result, isNull);
      });

      test('should not login with non-existent email', () async {
        final result = await authService.login(
          email: 'nonexistent@example.com',
          password: 'password123',
        );
        expect(result, isNull);
      });

      test('should maintain current user after login', () async {
        await authService.register(
          email: 'test6@example.com',
          password: 'password123',
          name: 'Test User',
        );

        await authService.login(
          email: 'test6@example.com',
          password: 'password123',
        );

        final currentUser = await authService.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.email, equals('test6@example.com'));
      });

      test('should clear current user after logout', () async {
        await authService.register(
          email: 'test7@example.com',
          password: 'password123',
          name: 'Test User',
        );

        await authService.login(
          email: 'test7@example.com',
          password: 'password123',
        );

        await authService.logout();
        final currentUser = await authService.getCurrentUser();
        expect(currentUser, isNull);
      });
    });

    group('Password Management', () {
      test('should reset password successfully', () async {
        await authService.register(
          email: 'test8@example.com',
          password: 'password123',
          name: 'Test User',
        );

        await authService.resetPassword(
          email: 'test8@example.com',
          newPassword: 'newpassword123',
        );

        final result = await authService.login(
          email: 'test8@example.com',
          password: 'newpassword123',
        );
        expect(result, isNotNull);
      });

      test('should not reset password for non-existent email', () async {
        final result = await authService.resetPassword(
          email: 'nonexistent@example.com',
          newPassword: 'newpassword123',
        );
        expect(result, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        // Simulate a database error by closing the connection
        await authService.close();

        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(result, isNull);
      });

      test('should handle invalid input data', () async {
        expect(
            () => authService.register(
                  email: '',
                  password: '',
                  name: '',
                ),
            throwsA(isA<AuthException>()));
      });
    });
  });
}
