import 'package:flutter/material.dart';

class AttendanceChartCard extends StatefulWidget {
  const AttendanceChartCard({super.key});

  @override
  State<AttendanceChartCard> createState() => _AttendanceChartCardState();
}

class _AttendanceChartCardState extends State<AttendanceChartCard> {
  String selectedPeriod = 'This Month';

  final periods = ['This Month', 'Last Month', 'Last Quarter'];

  // Mock data: attendance percentages for 4 weeks
  final chartData = [75.0, 82.0, 88.0, 76.0];

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
            // Header with dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Handle different heights
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Trends',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monthly overview of employee presence',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Provide spacing
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ), // Reduce padding
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    isDense: true, // Make it compact
                    underline: const SizedBox(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedPeriod = value ?? 'This Month';
                      });
                    },
                    items: periods.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(
                          period,
                          style: const TextStyle(
                            fontSize: 12,
                          ), // Reduce text size
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Simple Bar Chart Representation
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: AttendanceChartPainter(
                  data: chartData,
                  primaryColor: Theme.of(context).primaryColor,
                  isDark: isDark,
                ),
                size: const Size(double.infinity, 200),
              ),
            ),

            const SizedBox(height: 24),

            // Week labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                chartData.length,
                (index) => Text(
                  'Week ${index + 1}',
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
  }
}

class AttendanceChartPainter extends CustomPainter {
  final List<double> data;
  final Color primaryColor;
  final bool isDark;

  AttendanceChartPainter({
    required this.data,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.grey[isDark ? 800 : 200]!
      ..strokeWidth = 1;

    final areaFillPaint = Paint()..color = primaryColor.withOpacity(0.1);

    // Draw grid lines
    final maxValue = 100.0;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - (i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate points
    final pointSpacing = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height * (1 - (data[i] / maxValue));
      points.add(Offset(x, y));
    }

    // Draw line path
    if (points.isNotEmpty) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }

      // Draw data points
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

      // Draw area under curve
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
  bool shouldRepaint(AttendanceChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.primaryColor != primaryColor;
  }
}
