class Score {
  final int id;
  final int userId;
  final String userName;
  final double score;
  final String metric;
  final String month;
  final int year;
  final DateTime createdAt;

  Score({
    required this.id,
    required this.userId,
    required this.userName,
    required this.score,
    required this.metric,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      userName: json['user_name'] ?? json['userName'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      metric: json['metric'] ?? '',
      month: json['month'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}
