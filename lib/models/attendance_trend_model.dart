class AttendanceTrend {
  final String week;
  final double percentage;

  AttendanceTrend({required this.week, required this.percentage});

  factory AttendanceTrend.fromJson(Map<String, dynamic> json) {
    return AttendanceTrend(
      week: json['week'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}
