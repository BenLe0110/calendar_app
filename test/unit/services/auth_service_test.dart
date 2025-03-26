import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/services/event_service.dart';

// Generate mock classes
@GenerateMocks([Database, EventService])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockDatabase mockDatabase;
  late MockEventService mockEventService;

  setUp(() {
    mockDatabase = MockDatabase();
    mockEventService = MockEventService();
    authService = AuthService();
  });

  group('AuthService Tests', () {
    test('register - should create new user and associate events', () async {
      // Arrange
      when(mockDatabase.insert(
        'users',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      when(mockEventService.getLocalId())
          .thenAnswer((_) async => 'test-local-id');
      when(mockEventService.associateEventsWithUser(any, any))
          .thenAnswer((_) async => {});

      // Act
      final result = await authService.register(
        'test@example.com',
        'Test User',
        'Test@123',
      );

      // Assert
      expect(result, isA<User>());
      expect(result.email, 'test@example.com');
      expect(result.name, 'Test User');
      verify(mockDatabase.insert(
        'users',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
      verify(mockEventService.getLocalId()).called(1);
      verify(mockEventService.associateEventsWithUser(
              'test-local-id', result.id))
          .called(1);
    });

    test('register - should handle event association errors', () async {
      // Arrange
      when(mockDatabase.insert(
        'users',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      when(mockEventService.getLocalId())
          .thenAnswer((_) async => 'test-local-id');
      when(mockEventService.associateEventsWithUser(any, any))
          .thenThrow(Exception('Association error'));

      // Act & Assert
      expect(
        () => authService.register(
          'test@example.com',
          'Test User',
          'Test@123',
        ),
        throwsException,
      );
    });

    test('login - should return user for valid credentials', () async {
      // Arrange
      when(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'id': '1',
              'email': 'test@example.com',
              'name': 'Test User',
              'password': 'hashedPassword',
            }
          ]);

      // Act
      final result = await authService.login(
        'test@example.com',
        'Test@123',
      );

      // Assert
      expect(result, isA<User>());
      expect(result?.email, 'test@example.com');
      expect(result?.name, 'Test User');
      verify(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('login - should return null for invalid credentials', () async {
      // Arrange
      when(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await authService.login(
        'wrong@example.com',
        'WrongPassword',
      );

      // Assert
      expect(result, isNull);
    });

    test('getCurrentUser - should return current user when logged in',
        () async {
      // Arrange
      when(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'id': '1',
              'email': 'test@example.com',
              'name': 'Test User',
              'password': 'hashedPassword',
            }
          ]);

      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isA<User>());
      expect(result?.email, 'test@example.com');
      expect(result?.name, 'Test User');
    });

    test('getCurrentUser - should return null when not logged in', () async {
      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('logout - should clear current user', () async {
      // Act
      await authService.logout();

      // Assert
      final result = await authService.getCurrentUser();
      expect(result, isNull);
    });

    test('resetPassword - should return true for existing user', () async {
      // Arrange
      when(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'id': '1',
              'email': 'test@example.com',
              'name': 'Test User',
              'password': 'hashedPassword',
            }
          ]);

      // Act
      final result = await authService.resetPassword('test@example.com');

      // Assert
      expect(result, isTrue);
      verify(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('resetPassword - should return false for non-existent user', () async {
      // Arrange
      when(mockDatabase.query(
        'users',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await authService.resetPassword('nonexistent@example.com');

      // Assert
      expect(result, isFalse);
    });
  });
}
