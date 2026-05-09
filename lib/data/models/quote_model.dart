import 'dart:math' as math;
import 'package:flutter/foundation.dart';

@immutable
class QuoteModel {
  final String id;
  final String userId;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;
  final String? avatarUrl;
  final bool isLiked;

  const QuoteModel({
    required this.id,
    required this.userId,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.avatarUrl,
    this.isLiked = false,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      likesCount: map['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.parse(map['created_at'] as String),
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isLiked: map['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get rankingScore {
    final hoursSince = DateTime.now().difference(createdAt).inMinutes / 60.0;
    return (likesCount + 1) / math.pow(hoursSince + 2, 1.5);
  }

  QuoteModel copyWith({
    String? id,
    String? userId,
    String? content,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? avatarUrl,
    bool? isLiked,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
