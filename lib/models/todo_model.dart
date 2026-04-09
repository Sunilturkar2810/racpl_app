class Todo {
  final int id;
  final int userId;
  final int createdBy;
  final int assignedTo;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String creatorName;
  final String assigneeName;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Todo({
    required this.id,
    required this.userId,
    required this.createdBy,
    required this.assignedTo,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.creatorName,
    required this.assigneeName,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String buildName(String first, String last) {
      return [first, last].where((part) => part.trim().isNotEmpty).join(' ');
    }

    final createdBy = parseInt(json['created_by']);
    final assignedTo = parseInt(json['assigned_to']);

    return Todo(
      id: parseInt(json['todo_id'] ?? json['id']),
      userId: assignedTo,
      createdBy: createdBy,
      assignedTo: assignedTo,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'To Do',
      priority: json['priority'] ?? 'Normal',
      creatorName: buildName(
        json['creator_first_name']?.toString() ?? '',
        json['creator_last_name']?.toString() ?? '',
      ),
      assigneeName: buildName(
        json['assignee_first_name']?.toString() ?? '',
        json['assignee_last_name']?.toString() ?? '',
      ),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Todo copyWith({
    int? id,
    int? userId,
    int? createdBy,
    int? assignedTo,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? creatorName,
    String? assigneeName,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      creatorName: creatorName ?? this.creatorName,
      assigneeName: assigneeName ?? this.assigneeName,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
