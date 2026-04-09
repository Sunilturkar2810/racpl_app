import 'dio_service.dart';
import '../models/dashboard_stats_model.dart';
import '../models/dashboard_trend_model.dart';
import '../models/activity_model.dart';
import '../models/todo_summary_model.dart';

class DashboardService {
  final DioService _dioService;

  DashboardService({required DioService dioService}) : _dioService = dioService;

  Future<DashboardStats> fetchDashboardStats() async {
    return await _dioService.get(
      '/dashboard/stats',
      fromJson: (json) => DashboardStats.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<DashboardTrend>> fetchDashboardTrends(String period) async {
    final response = await _dioService.get(
      '/dashboard/charts/trend?period=$period',
      fromJson: (json) => (json as Map<String, dynamic>)['trend'] as List<dynamic>? ?? [],
    );
    return response.map((data) => DashboardTrend.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<List<ActivityModel>> fetchRecentActivity() async {
    // Note: Depends on whether /activity returns { data: [] } or just [] 
    // Usually standard responses have data object or returned directly.
    final response = await _dioService.get(
      '/dashboard/activity',
      fromJson: (json) {
        if (json is List) return json;
        return (json as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      },
    );
    return response.map((data) => ActivityModel.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<TodoSummary> fetchTodoSummary() async {
    // This endpoint isn't fully separated in backend yet; UI uses TodoProvider.
    return TodoSummary(
      pending: 0,
      inProgress: 0,
      completed: 0,
      topTodos: [],
    );
  }
}
