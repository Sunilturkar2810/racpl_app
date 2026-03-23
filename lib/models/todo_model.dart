class Todo {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
