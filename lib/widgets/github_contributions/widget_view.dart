import 'package:flutter/material.dart';
import 'package:widgets/widgets/github_contributions/heatmap_canvas.dart';
import 'package:widgets/widgets/github_contributions/models.dart';

/// The layout rendered into a PNG image for iOS WidgetKit / Android AppWidget
class GitHubMediumWidgetView extends StatelessWidget {
  final String username;
  final ContributionStats stats;
  final ContributionPalette palette;

  const GitHubMediumWidgetView({
    super.key,
    required this.username,
    required this.stats,
    required this.palette,
  });

  // Recommended dimensions for medium iOS / Android widgets
  static const Size widgetSize = Size(338, 158);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widgetSize.width,
      height: widgetSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF30363D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Username + Stats Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: palette.colorForLevel(3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.code_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    username.isEmpty ? 'GitHub' : '@$username',
                    style: const TextStyle(
                      color: Color(0xFFF0F6FC),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              // Stats
              Row(
                children: [
                  Text(
                    '${stats.totalCount} contributions',
                    style: TextStyle(
                      color: palette.colorForLevel(4),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (stats.currentStreak > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFF7A00),
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${stats.currentStreak}d',
                            style: const TextStyle(
                              color: Color(0xFFC9D1D9),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Heatmap grid
          Center(
            child: HeatmapCanvas(
              days: stats.days,
              palette: palette,
              columnCount: 19,
              cellSize: 10.5,
              spacing: 2.8,
              borderRadius: 2.0,
              showDayLabels: true,
            ),
          ),

          // Footer: minimal month indicator / status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Less',
                style: TextStyle(color: Color(0xFF8B949E), fontSize: 9),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: palette.colorForLevel(index),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              ),
              const Text(
                'More',
                style: TextStyle(color: Color(0xFF8B949E), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
