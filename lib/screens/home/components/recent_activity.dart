import 'package:flutter/material.dart';

class Activity {
  final String module;
  final String description;
  final String user;
  final String time;
  final ActivityStatus status;
  final Color color;

  Activity({
    required this.module,
    required this.description,
    required this.user,
    required this.time,
    required this.status,
    required this.color,
  });
}

enum ActivityStatus { completed, pending, processing }

class RecentActivityCard extends StatelessWidget {
  final List<Activity> activities;
  final VoidCallback? onFilterTap;

  const RecentActivityCard({
    super.key,
    required this.activities,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time log of company-wide updates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onFilterTap,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity List
            if (activities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No recent activities',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              Column(
                children: [
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _buildActivityItem(context, activity);
                    },
                  ),
                  // View All Button (Footer)
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.grey[700]!
                            : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'View All Activity Logs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Activity activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left-side icon based on status
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(activity.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(activity.status),
              color: _getStatusColor(activity.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Module Name and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activity.module,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          activity.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusLabel(activity.status).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(activity.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                // Bottom row: User and Time
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.user,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.pending:
        return Icons.schedule;
      case ActivityStatus.processing:
        return Icons.sync;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.pending:
        return Colors.orange;
      case ActivityStatus.processing:
        return Colors.blue;
    }
  }

  String _getStatusLabel(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.pending:
        return 'Pending';
      case ActivityStatus.processing:
        return 'Processing';
    }
  }
}
