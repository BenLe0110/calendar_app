import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAllDay;
  final Color? color;
  final String? userId;
  final String? localId;

  Event({
    this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isAllDay = false,
    this.color,
    this.userId,
    this.localId,
  }) {
    assert(startDate.isBefore(endDate), 'Start date must be before end date');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'is_all_day': isAllDay ? 1 : 0,
      'color': color?.value,
      'user_id': userId,
      'local_id': localId,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      startDate: DateTime.parse(map['start_date'] as String).toLocal(),
      endDate: DateTime.parse(map['end_date'] as String).toLocal(),
      isAllDay: map['is_all_day'] == 1,
      color: map['color'] != null ? Color(map['color'] as int) : null,
      userId: map['user_id'] as String?,
      localId: map['local_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'isAllDay': isAllDay,
      'color': color?.value,
      'userId': userId,
      'localId': localId,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
      isAllDay: json['isAllDay'] as bool? ?? false,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      userId: json['userId'] as String?,
      localId: json['localId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          isAllDay == other.isAllDay &&
          color == other.color &&
          userId == other.userId &&
          localId == other.localId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isAllDay.hashCode ^
      color.hashCode ^
      userId.hashCode ^
      localId.hashCode;
}
