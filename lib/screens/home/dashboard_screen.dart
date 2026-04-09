import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/auto_scroll_row.dart';
import 'dart:developer' as developer;
import 'components/welcome_card.dart';
import 'components/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        developer.log('📊 Dashboard loading all data...');
        context.read<DashboardProvider>().fetchDashboardData();
        context.read<TodoProvider>().fetchTodos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section (centered, no card)
            const WelcomeCard(),
            const SizedBox(height: 16),

            // Stats Grid — auto-scrolling horizontal row
            _buildStatsGrid(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        if (dashboardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = dashboardProvider.stats;
        final cardWidth = MediaQuery.of(context).size.width * 0.45;

        return AutoScrollRow(
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Total Employees',
                value: stats.totalEmployees.toString(),
                icon: Icons.groups,
                trend: '+2%',
                trendLabel: 'vs last month',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Active Projects',
                value: stats.activeProjects.toString(),
                icon: Icons.folder_open,
                trend: 'All',
                trendLabel: 'ongoing projects',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Pending Tasks',
                value: stats.pendingTasks.toString(),
                icon: Icons.pending_actions,
                trend: 'Urgent',
                trendLabel: 'To-do items',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                title: 'Open Tickets',
                value: stats.openTickets.toString(),
                icon: Icons.confirmation_number,
                trend: 'Low',
                trendLabel: 'Support tickets',
                color: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }
}
