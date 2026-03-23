class ChecklistItem {
  final int id;
  final String title;
  final bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted,
  };
}

class Checklist {
  final int id;
  final int userId;
  final String title;
  final String description;
  final List<ChecklistItem> items;
  final String status;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Checklist({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.items,
    required this.status,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List?)
            ?.map(
              (item) => ChecklistItem.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return Checklist(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items: itemsList,
      status: json['status'] ?? 'pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
}
