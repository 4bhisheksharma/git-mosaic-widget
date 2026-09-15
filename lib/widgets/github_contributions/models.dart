import 'package:flutter/material.dart';

/// Single day entry in the contribution calendar
class ContributionDay {
  final DateTime date;
  final int count;
  final int level; // 0 to 4

  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
  });

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: DateTime.parse(json['date'] as String),
      count: (json['count'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Statistics computed from the contribution history
class ContributionStats {
  final int totalCount;
  final int currentStreak;
  final int longestStreak;
  final List<ContributionDay> days;

  const ContributionStats({
    required this.totalCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.days,
  });

  factory ContributionStats.fromDays(List<ContributionDay> days) {
    if (days.isEmpty) {
      return const ContributionStats(
        totalCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        days: [],
      );
    }

    // Sort ascending by date
    final sorted = List<ContributionDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    int total = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (int i = 0; i < sorted.length; i++) {
      final day = sorted[i];
      total += day.count;

      if (day.count > 0) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    // Calculate current streak backwards from today/yesterday
    final reversed = sorted.reversed.toList();
    bool counting = false;

    for (final day in reversed) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
      if (dayDate == today || dayDate == yesterday) {
        if (day.count > 0) {
          counting = true;
          currentStreak++;
          continue;
        } else if (dayDate == today) {
          // If 0 contributions today, can still maintain streak from yesterday
          continue;
        } else {
          break;
        }
      } else if (counting) {
        if (day.count > 0) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return ContributionStats(
      totalCount: total,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      days: sorted,
    );
  }
}

/// Color theme palette for the contribution squares
class ContributionPalette {
  final String id;
  final String name;
  final List<Color> colors; // Exactly 5 colors: level 0 to 4

  const ContributionPalette({
    required this.id,
    required this.name,
    required this.colors,
  });

  Color colorForLevel(int level) {
    final clamped = level.clamp(0, 4);
    return colors[clamped];
  }

  // Pre-configured themes
  static const ContributionPalette classicGreen = ContributionPalette(
    id: 'classic_green',
    name: 'GitHub Green',
    colors: [
      Color(0xFF161B22),
      Color(0xFF0E4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ],
  );

  static const ContributionPalette draculaPurple = ContributionPalette(
    id: 'dracula',
    name: 'Dracula',
    colors: [
      Color(0xFF1E1F29),
      Color(0xFF4D386B),
      Color(0xFF6E43A3),
      Color(0xFF9D65D4),
      Color(0xFFBD93F9),
    ],
  );

  static const ContributionPalette cyberpunkCyan = ContributionPalette(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    colors: [
      Color(0xFF121820),
      Color(0xFF0D3B4C),
      Color(0xFF087E8B),
      Color(0xFF00B4D8),
      Color(0xFF00F0FF),
    ],
  );

  static const ContributionPalette fireOrange = ContributionPalette(
    id: 'fire',
    name: 'Fire',
    colors: [
      Color(0xFF1A1412),
      Color(0xFF5A2A18),
      Color(0xFF9E3D1B),
      Color(0xFFE25822),
      Color(0xFFFF7A00),
    ],
  );

  static const List<ContributionPalette> allPalettes = [
    classicGreen,
    draculaPurple,
    cyberpunkCyan,
    fireOrange,
  ];

  static ContributionPalette fromId(String? id) {
    return allPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => classicGreen,
    );
  }
}
