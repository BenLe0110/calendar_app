import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('should create event with required fields', () {
      final now = DateTime.now();
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.startDate, now);
      expect(event.endDate, now.add(const Duration(hours: 1)));
      expect(event.isAllDay, false);
      expect(event.color, null);
      expect(event.userId, '1');
    });

    test('should create event with all fields', () {
      final now = DateTime.now();
      final testColor = Colors.blue.value;
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Color(testColor),
        userId: '1',
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.startDate, now);
      expect(event.endDate, now.add(const Duration(hours: 1)));
      expect(event.isAllDay, true);
      expect(event.color?.value, testColor);
      expect(event.userId, '1');
    });

    test('should convert event to and from map', () {
      final now = DateTime.now();
      final testColor = Colors.blue.value;
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Color(testColor),
        userId: '1',
      );

      final map = event.toMap();
      final fromMap = Event.fromMap(map);

      expect(fromMap.id, event.id);
      expect(fromMap.title, event.title);
      expect(fromMap.description, event.description);
      expect(fromMap.startDate, event.startDate);
      expect(fromMap.endDate, event.endDate);
      expect(fromMap.isAllDay, event.isAllDay);
      expect(fromMap.color?.value, testColor);
      expect(fromMap.userId, event.userId);
    });

    test('should convert event to and from JSON', () {
      final now = DateTime.now();
      final testColor = Colors.blue.value;
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Color(testColor),
        userId: '1',
      );

      final json = event.toJson();
      final fromJson = Event.fromJson(json);

      expect(fromJson.id, event.id);
      expect(fromJson.title, event.title);
      expect(fromJson.description, event.description);
      expect(fromJson.startDate, event.startDate);
      expect(fromJson.endDate, event.endDate);
      expect(fromJson.isAllDay, event.isAllDay);
      expect(fromJson.color?.value, testColor);
      expect(fromJson.userId, event.userId);
    });

    test('should compare events correctly', () {
      final now = DateTime.now();
      final event1 = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
      );

      final event2 = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
      );

      final event3 = Event(
        id: '2',
        title: 'Different Event',
        description: 'Different Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '2',
      );

      expect(event1 == event2, true);
      expect(event1 == event3, false);
    });

    test('should generate correct hash code', () {
      final now = DateTime.now();
      final event1 = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
      );

      final event2 = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
      );

      expect(event1.hashCode, event2.hashCode);
    });

    test('should throw assertion error when start date is after end date', () {
      final now = DateTime.now();
      expect(
        () => Event(
          id: '1',
          title: 'Test Event',
          startDate: now.add(const Duration(hours: 1)),
          endDate: now,
          userId: '1',
        ),
        throwsAssertionError,
      );
    });

    test('should handle localId field correctly', () {
      final now = DateTime.now();
      final event = Event(
        id: '1',
        title: 'Test Event',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        userId: '1',
        localId: 'local_123',
      );

      expect(event.localId, 'local_123');

      final map = event.toMap();
      expect(map['local_id'], 'local_123');

      final fromMap = Event.fromMap(map);
      expect(fromMap.localId, 'local_123');

      final json = event.toJson();
      expect(json['localId'], 'local_123');

      final fromJson = Event.fromJson(json);
      expect(fromJson.localId, 'local_123');
    });

    test('should handle null values correctly', () {
      final now = DateTime.now();
      final event = Event(
        title: 'Test Event',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
      );

      expect(event.id, null);
      expect(event.description, null);
      expect(event.color, null);
      expect(event.userId, null);
      expect(event.localId, null);
      expect(event.isAllDay, false);

      final map = event.toMap();
      expect(map['id'], null);
      expect(map['description'], null);
      expect(map['color'], null);
      expect(map['user_id'], null);
      expect(map['local_id'], null);
      expect(map['is_all_day'], 0);

      final fromMap = Event.fromMap(map);
      expect(fromMap.id, null);
      expect(fromMap.description, null);
      expect(fromMap.color, null);
      expect(fromMap.userId, null);
      expect(fromMap.localId, null);
      expect(fromMap.isAllDay, false);

      final json = event.toJson();
      expect(json['id'], null);
      expect(json['description'], null);
      expect(json['color'], null);
      expect(json['userId'], null);
      expect(json['localId'], null);
      expect(json['isAllDay'], false);

      final fromJson = Event.fromJson(json);
      expect(fromJson.id, null);
      expect(fromJson.description, null);
      expect(fromJson.color, null);
      expect(fromJson.userId, null);
      expect(fromJson.localId, null);
      expect(fromJson.isAllDay, false);
    });
  });
}
