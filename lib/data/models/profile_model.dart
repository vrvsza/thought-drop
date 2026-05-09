import 'package:flutter/foundation.dart';

@immutable
class ProfileModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
