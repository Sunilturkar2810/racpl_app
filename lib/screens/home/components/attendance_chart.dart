import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';

class DashboardTrendChart extends StatefulWidget {
  const DashboardTrendChart({super.key});

  @override
  State<DashboardTrendChart> createState() => _DashboardTrendChartState();
}

class _DashboardTrendChartState extends State<DashboardTrendChart> {
  String selectedPeriod = 'This Month';
  final periods = ['This Month', 'Last Month', 'Last Quarter'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final trends = provider.trends;
        final List<double> chartData = trends.map((e) => e.tasksCreated.toDouble()).toList();
        final List<String> labels = trends.map((e) {
          final l = e.label.replaceAll(RegExp(r'\s*\([^)]*\)'), ''); // remove (1-7) etc.
          if (l.length > 5) return l.substring(0, 5); // limit length to fit nicely
          return l;
        }).toList();

        // Default empty state
        if (chartData.isEmpty) {
          chartData.addAll([0, 0, 0, 0, 0]);
          labels.addAll(['', '', '', '', '']);
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tasks Activity Trends',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monthly overview of tasks created',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        isDense: true,
                        underline: const SizedBox(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedPeriod = value ?? 'This Month';
                          });
                          // In future: call provider to fetch this period
                        },
                        items: periods.map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(
                              period,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: DashboardTrendPainter(
                      data: chartData,
                      primaryColor: Theme.of(context).primaryColor,
                      isDark: isDark,
                    ),
                    size: const Size(double.infinity, 200),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    labels.length,
                    (index) => Text(
                      labels[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
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
}

class DashboardTrendPainter extends CustomPainter {
  final List<double> data;
  final Color primaryColor;
  final bool isDark;

  DashboardTrendPainter({
    required this.data,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.grey[isDark ? 800 : 200]!
      ..strokeWidth = 1;

    final areaFillPaint = Paint()..color = primaryColor.withOpacity(0.1);

    // Calculate max value for scaling, ensure it's at least 10 for grid
    double maxValue = data.reduce(max);
    if (maxValue < 10) maxValue = 10;
    // Add 20% headroom
    maxValue = maxValue * 1.2;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - (i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pointSpacing = data.length > 1 ? size.width / (data.length - 1) : 0.0;
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height * (1 - (data[i] / maxValue));
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty && data.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }

      for (final point in points) {
        canvas.drawCircle(
          point,
          5,
          Paint()
            ..color = primaryColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );

        canvas.drawCircle(point, 3, Paint()..color = Colors.white);
      }

      final path = Path();
      path.moveTo(points.first.dx, size.height);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path.lineTo(points.last.dx, size.height);
      path.close();

      canvas.drawPath(path, areaFillPaint);
    }
  }

  @override
  bool shouldRepaint(DashboardTrendPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.primaryColor != primaryColor;
  }
}
