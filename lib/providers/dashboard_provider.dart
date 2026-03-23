import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../models/attendance_trend_model.dart';
import '../models/activity_model.dart';
import '../models/todo_summary_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider({required DashboardService dashboardService})
    : _dashboardService = dashboardService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DashboardStats _stats = DashboardStats.empty();
  DashboardStats get stats => _stats;

  List<AttendanceTrend> _attendanceTrends = [];
  List<AttendanceTrend> get attendanceTrends => _attendanceTrends;

  List<ActivityModel> _recentActivities = [];
  List<ActivityModel> get recentActivities => _recentActivities;

  TodoSummary _todoSummary = TodoSummary.empty();
  TodoSummary get todoSummary => _todoSummary;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _dashboardService.fetchDashboardStats();
      _attendanceTrends = await _dashboardService.fetchAttendanceTrends(
        'current',
      );
      _recentActivities = await _dashboardService.fetchRecentActivity();
      _todoSummary = await _dashboardService.fetchTodoSummary();
    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
