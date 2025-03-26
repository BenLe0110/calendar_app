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
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Colors.blue,
        userId: '1',
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.startDate, now);
      expect(event.endDate, now.add(const Duration(hours: 1)));
      expect(event.isAllDay, true);
      expect(event.color, Colors.blue);
      expect(event.userId, '1');
    });

    test('should convert event to and from map', () {
      final now = DateTime.now();
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Colors.blue,
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
      expect(fromMap.color, event.color);
      expect(fromMap.userId, event.userId);
    });

    test('should convert event to and from JSON', () {
      final now = DateTime.now();
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
        isAllDay: true,
        color: Colors.blue,
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
      expect(fromJson.color, event.color);
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
  });
}
