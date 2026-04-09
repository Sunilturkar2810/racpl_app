class DashboardStats {
  final int totalEmployees;
  final int activeProjects;
  final int pendingTasks;
  final int openTickets;
  final double periodExpenseTotal;

  DashboardStats({
    required this.totalEmployees,
    required this.activeProjects,
    required this.pendingTasks,
    required this.openTickets,
    required this.periodExpenseTotal,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: json['employeesTotal'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      pendingTasks: json['openTasks'] ?? 0,
      openTickets: json['openTickets'] ?? 0,
      periodExpenseTotal: (json['periodExpenseTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalEmployees: 0,
      activeProjects: 0,
      pendingTasks: 0,
      openTickets: 0,
      periodExpenseTotal: 0.0,
    );
  }
}
