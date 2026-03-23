class DashboardStats {
  final int totalEmployees;
  final int presentToday;
  final int pendingTasks;
  final int openTickets;

  DashboardStats({
    required this.totalEmployees,
    required this.presentToday,
    required this.pendingTasks,
    required this.openTickets,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: json['totalEmployees'] ?? 0,
      presentToday: json['presentToday'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      openTickets: json['openTickets'] ?? 0,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalEmployees: 0,
      presentToday: 0,
      pendingTasks: 0,
      openTickets: 0,
    );
  }
}
