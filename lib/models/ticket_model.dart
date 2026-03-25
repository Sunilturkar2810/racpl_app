class HelpTicket {
  final int id;
  final int createdById;
  final String createdByName;
  final int? assignedToId;
  final String? assignedToName;
  final String title;
  final String description;
  final String category;
  final String location;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HelpTicket({
    required this.id,
    required this.createdById,
    required this.createdByName,
    this.assignedToId,
    this.assignedToName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HelpTicket.fromJson(Map<String, dynamic> json) {
    int parseIntSave(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return HelpTicket(
      id: parseIntSave(json['id']),
      createdById: parseIntSave(
        json['raised_by'] ?? json['created_by'] ?? json['createdById'],
      ),
      createdByName:
          json['raiser_name'] ??
          json['created_by_name'] ??
          json['createdByName'] ??
          '',
      assignedToId: parseIntSave(
        json['problem_solver'] ?? json['assigned_to'] ?? json['assignedToId'],
      ),
      assignedToName:
          json['solver_name'] ??
          json['pc_name'] ??
          json['assigned_to_name'] ??
          json['assignedToName'],
      title: json['issue_description'] ?? json['title'] ?? '',
      description: json['issue_description'] ?? json['description'] ?? '',
      category: json['category'] ?? 'General',
      location: json['location'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
}
