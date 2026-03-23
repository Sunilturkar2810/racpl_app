import 'package:flutter/material.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class QuickActionsCard extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsCard({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  2.0, // Adjusted to make them wider like the screenshot
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : const Color(0xFFF9FAFB), // Very light gray from UI
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action.icon, color: action.color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
