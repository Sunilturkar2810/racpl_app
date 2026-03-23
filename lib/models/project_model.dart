class Project {
  final int id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final List<String> teamMembers;
  final double? budget;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.teamMembers,
    this.budget,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final teamList =
        (json['team_members'] as List?)?.map((m) => m.toString()).toList() ??
        [];

    return Project(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : null,
      status: json['status'] ?? 'pending',
      teamMembers: teamList,
      budget: json['budget'] != null
          ? (json['budget'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
}
