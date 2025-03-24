import 'package:flutter/material.dart';

class Event {
  final int? id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Color? color;
  final bool isAllDay;

  Event({
    this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.color,
    required this.isAllDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'color': color?.value,
      'isAllDay': isAllDay ? 1 : 0,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      color: map['color'] != null ? Color(map['color']) : null,
      isAllDay: map['isAllDay'] == 1,
    );
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? isAllDay,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}
