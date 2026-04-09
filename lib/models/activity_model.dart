class ActivityModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String createdAt;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      isRead: json['isRead'] == true,
    );
  }
}
