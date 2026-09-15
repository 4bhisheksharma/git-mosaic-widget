import 'package:flutter/material.dart';
import 'package:widgets/widgets/github_contributions/models.dart';

/// Pixel-perfect, high performance heatmap renderer for both in-app and home widget rendering
class HeatmapCanvas extends StatelessWidget {
  final List<ContributionDay> days;
  final ContributionPalette palette;
  final int columnCount;
  final double cellSize;
  final double spacing;
  final double borderRadius;

  const HeatmapCanvas({
    super.key,
    required this.days,
    required this.palette,
    this.columnCount = 18,
    this.cellSize = 12.0,
    this.spacing = 3.0,
    this.borderRadius = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        (columnCount * cellSize) + ((columnCount - 1) * spacing),
        (7 * cellSize) + (6 * spacing),
      ),
      painter: _HeatmapPainter(
        days: days,
        palette: palette,
        columnCount: columnCount,
        cellSize: cellSize,
        spacing: spacing,
        borderRadius: borderRadius,
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<ContributionDay> days;
  final ContributionPalette palette;
  final int columnCount;
  final double cellSize;
  final double spacing;
  final double borderRadius;

  _HeatmapPainter({
    required this.days,
    required this.palette,
    required this.columnCount,
    required this.cellSize,
    required this.spacing,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rradius = Radius.circular(borderRadius);

    // Map days by (YYYY-MM-DD) for O(1) lookup
    final Map<String, ContributionDay> dayMap = {};
    for (final day in days) {
      final key = _formatDate(day.date);
      dayMap[key] = day;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find weekday offset (Monday = 1, Sunday = 7 in Dart)
    final todayWeekday = today.weekday; // 1 = Mon, ..., 7 = Sun

    // Calculate start date so the bottom of the last column is today
    // Total cells = columnCount * 7
    // Total days back = ((columnCount - 1) * 7) + (todayWeekday - 1)
    final daysBack = ((columnCount - 1) * 7) + (todayWeekday - 1);
    final startDate = today.subtract(Duration(days: daysBack));

    var currentDate = startDate;

    for (int col = 0; col < columnCount; col++) {
      for (int row = 0; row < 7; row++) {
        // If current date is in the future, don't draw or draw empty cell
        if (currentDate.isAfter(today)) {
          break;
        }

        final dateKey = _formatDate(currentDate);
        final day = dayMap[dateKey];
        final level = day?.level ?? 0;

        paint.color = palette.colorForLevel(level);

        final x = col * (cellSize + spacing);
        final y = row * (cellSize + spacing);

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          rradius,
        );

        canvas.drawRRect(rrect, paint);

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.palette != palette ||
        oldDelegate.columnCount != columnCount;
  }
}
