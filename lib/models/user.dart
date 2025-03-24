import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.preferences = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferences': preferences,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      preferences: map['preferences'] ?? {},
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}
