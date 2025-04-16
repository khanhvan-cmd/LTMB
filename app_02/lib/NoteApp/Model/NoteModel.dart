import 'dart:convert';

class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final int priority;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color;
  final bool isCompleted;
  final String? imagePath; // Thêm thuộc tính imagePath

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    this.isCompleted = false,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','),
      'color': color,
      'isCompleted': isCompleted ? 1 : 0,
      'imagePath': imagePath, // Lưu đường dẫn hình ảnh
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'] ?? 1,
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
      color: map['color'],
      isCompleted: map['isCompleted'] == 1,
      imagePath: map['imagePath'], // Lấy đường dẫn hình ảnh
    );
  }

  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
    bool? isCompleted,
    String? imagePath,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, userId: $userId, title: $title, content: $content, priority: $priority, createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, color: $color, isCompleted: $isCompleted, imagePath: $imagePath)';
  }
}