class ActivityModel {
  final String id;
  final String module;
  final String description;
  final String user;
  final String time;
  final String status;

  ActivityModel({
    required this.id,
    required this.module,
    required this.description,
    required this.user,
    required this.time,
    required this.status,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      module: json['module'] ?? '',
      description: json['description'] ?? '',
      user: json['user'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
