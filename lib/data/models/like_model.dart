import 'package:flutter/foundation.dart';

@immutable
class LikeModel {
  final String id;
  final String userId;
  final String quoteId;
  final DateTime createdAt;

  const LikeModel({
    required this.id,
    required this.userId,
    required this.quoteId,
    required this.createdAt,
  });

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      quoteId: map['quote_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'quote_id': quoteId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LikeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
