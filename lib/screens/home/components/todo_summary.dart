import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/todo_provider.dart';

class TodoSummaryCard extends StatelessWidget {
  const TodoSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
        final todos = todoProvider.todos;
        final pending = todos.where((t) => t.status == 'Todo').length;
        final inProgress = todos.where((t) => t.status == 'InProgress').length;
        final completed = todos.where((t) => t.status == 'Done').length;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                _buildStatItem(
                  context,
                  label: 'Pending',
                  count: pending,
                  color: Colors.orange,
                  icon: Icons.hourglass_empty,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  label: 'In Progress',
                  count: inProgress,
                  color: Colors.blue,
                  icon: Icons.loop,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  label: 'Completed',
                  count: completed,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),

                if (todos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
