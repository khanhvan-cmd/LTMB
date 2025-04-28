class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final String createdBy;
  final String? category;
  final List<String>? attachments;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '', // Backend trả về _id thay vì id
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'To do',
      priority: json['priority'] ?? 1,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      assignedTo: json['assignedTo'],
      createdBy: json['createdBy'] ?? '',
      category: json['category'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachments': attachments,
      'completed': completed,
    };
  }
}

extension TaskExtension on Task {
  Task copyWith({String? status, bool? completed}) {
    return Task(
      id: this.id,
      title: this.title,
      description: this.description,
      status: status ?? this.status,
      priority: this.priority,
      dueDate: this.dueDate,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      assignedTo: this.assignedTo,
      createdBy: this.createdBy,
      category: this.category,
      attachments: this.attachments,
      completed: completed ?? this.completed,
    );
  }
}