class Delegation {
  final int id;
  final int delegatedById;
  final String delegatedByName;
  final int delegatedToId;
  final String delegatedToName;
  final String taskName;
  final String description;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Delegation({
    required this.id,
    required this.delegatedById,
    required this.delegatedByName,
    required this.delegatedToId,
    required this.delegatedToName,
    required this.taskName,
    required this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Delegation.fromJson(Map<String, dynamic> json) {
    return Delegation(
      id: json['id'] ?? 0,
      delegatedById: json['delegated_by'] ?? json['delegatedById'] ?? 0,
      delegatedByName:
          json['delegated_by_name'] ?? json['delegatedByName'] ?? '',
      delegatedToId: json['delegated_to'] ?? json['delegatedToId'] ?? 0,
      delegatedToName:
          json['delegated_to_name'] ?? json['delegatedToName'] ?? '',
      taskName: json['task_name'] ?? json['taskName'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
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

  Delegation copyWith({
    int? id,
    int? delegatedById,
    String? delegatedByName,
    int? delegatedToId,
    String? delegatedToName,
    String? taskName,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Delegation(
      id: id ?? this.id,
      delegatedById: delegatedById ?? this.delegatedById,
      delegatedByName: delegatedByName ?? this.delegatedByName,
      delegatedToId: delegatedToId ?? this.delegatedToId,
      delegatedToName: delegatedToName ?? this.delegatedToName,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
