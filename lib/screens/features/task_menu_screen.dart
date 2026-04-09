import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'delegation_list_screen.dart';

class TaskMenuScreen extends StatelessWidget {
  const TaskMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _TaskMenuItem(
        icon: Icons.person_rounded,
        label: 'My Tasks',
        subtitle: 'Tasks assigned directly to you',
        color: AppColors.primary,
        destination: DelegationListScreen(section: TaskSection.myTasks),
      ),
      const _TaskMenuItem(
        icon: Icons.send_rounded,
        label: 'Delegated Tasks',
        subtitle: "Tasks you've assigned to others",
        color: Color(0xFF8B5CF6), // Purple
        destination: DelegationListScreen(section: TaskSection.delegatedTasks),
      ),
      const _TaskMenuItem(
        icon: Icons.notifications_active_rounded,
        label: 'Subscribed Tasks',
        subtitle: 'Tasks you are observing',
        color: Color(0xFFF59E0B), // Amber
        destination: DelegationListScreen(section: TaskSection.subscribedTasks),
      ),
      const _TaskMenuItem(
        icon: Icons.dashboard_rounded,
        label: 'All Tasks',
        subtitle: 'Overview of all accessible tasks',
        color: Color(0xFF10B981), // Emerald
        destination: DelegationListScreen(section: TaskSection.allTasks),
      ),
      const _TaskMenuItem(
        icon: Icons.delete_sweep_rounded,
        label: 'Deleted Tasks',
        subtitle: 'View removed or archived tasks',
        color: Color(0xFFEF4444), // Rose
        destination: DelegationListScreen(section: TaskSection.deletedTasks),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return _TaskMenuCard(item: item);
        },
      ),
    );
  }
}

class _TaskMenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Widget destination;

  const _TaskMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.destination,
  });
}

class _TaskMenuCard extends StatelessWidget {
  final _TaskMenuItem item;

  const _TaskMenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          highlightColor: item.color.withValues(alpha: 0.05),
          splashColor: item.color.withValues(alpha: 0.1),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => item.destination),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
