import 'dart:convert';

import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.userId,
    required super.id,
    required super.title,
    required super.body,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'id': id,
    'title': title,
    'body': body,
  };

  factory PostModel.fromRawJson(String raw) =>
      PostModel.fromJson(json.decode(raw) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  Post toEntity() => Post(userId: userId, id: id, title: title, body: body);
}
