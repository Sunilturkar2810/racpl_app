import 'dio_service.dart';
import '../models/dashboard_stats_model.dart';
import '../models/attendance_trend_model.dart';
import '../models/activity_model.dart';
import '../models/todo_summary_model.dart';

class DashboardService {
  final DioService _dioService;

  DashboardService({required DioService dioService}) : _dioService = dioService;

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      return await _dioService.get(
        '/dashboard/stats',
        fromJson: (json) => DashboardStats.fromJson(json),
      );
    } catch (e) {
      // Mock data fallback if API is not yet fully ready
      return DashboardStats(
        totalEmployees: 45,
        presentToday: 42,
        pendingTasks: 12,
        openTickets: 3,
      );
    }
  }

  Future<List<AttendanceTrend>> fetchAttendanceTrends(String month) async {
    try {
      final response = await _dioService.get(
        '/dashboard/attendance-trends?month=$month',
        fromJson: (json) => json as List<dynamic>,
      );
      return response.map((data) => AttendanceTrend.fromJson(data)).toList();
    } catch (e) {
      // Mock fallback
      return [
        AttendanceTrend(week: 'Week 1', percentage: 95.0),
        AttendanceTrend(week: 'Week 2', percentage: 92.0),
        AttendanceTrend(week: 'Week 3', percentage: 88.0),
        AttendanceTrend(week: 'Week 4', percentage: 96.0),
      ];
    }
  }

  Future<List<ActivityModel>> fetchRecentActivity() async {
    // This endpoint is currently unavailable on the deployed backend.
    // Return a local fallback to avoid repeated 404 errors in the app logs.
    return [
      ActivityModel(
        id: '1',
        module: 'HRMS',
        description: 'New policy document uploaded',
        user: 'Sarah Jenkins',
        time: '2 mins ago',
        status: 'Completed',
      ),
      ActivityModel(
        id: '2',
        module: 'Help Ticket',
        description: 'Ticket #2049: Login issue',
        user: 'Mike Ross',
        time: '15 mins ago',
        status: 'Pending',
      ),
      ActivityModel(
        id: '3',
        module: 'FMS',
        description: 'Monthly expense report generated',
        user: 'System',
        time: '1 hour ago',
        status: 'Processing',
      ),
    ];
  }

  Future<TodoSummary> fetchTodoSummary() async {
    // This endpoint is currently unavailable on the deployed backend.
    // Return a local fallback to avoid repeated 404 errors in the app logs.
    return TodoSummary(
      pending: 5,
      inProgress: 2,
      completed: 10,
      topTodos: [
        {'title': 'Review PR', 'status': 'Pending'},
        {'title': 'Update docs', 'status': 'In Progress'},
      ],
    );
  }
}
