class DashboardTrend {
  final String bucket;
  final String label;
  final int tasksCreated;
  final int tasksCompleted;
  final int ticketsRaised;
  final double expenseAmount;

  DashboardTrend({
    required this.bucket,
    required this.label,
    required this.tasksCreated,
    required this.tasksCompleted,
    required this.ticketsRaised,
    required this.expenseAmount,
  });

  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      bucket: json['bucket']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      tasksCreated: (json['tasksCreated'] as num?)?.toInt() ?? 0,
      tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
      ticketsRaised: (json['ticketsRaised'] as num?)?.toInt() ?? 0,
      expenseAmount: (json['expenseAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
