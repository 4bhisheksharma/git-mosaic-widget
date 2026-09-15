import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:widgets/widgets/github_contributions/models.dart';

class GitHubApi {
  static const String _baseUrl = 'https://github-contributions-api.jogruber.de/v4';

  /// Fetches the last year of contributions for a given GitHub username.
  /// Falls back to sample data if offline or on network failure.
  static Future<ContributionStats> fetchContributions(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return generateSampleStats();
    }

    try {
      final uri = Uri.parse('$_baseUrl/$cleanUsername?y=last');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final contributions = data['contributions'] as List<dynamic>? ?? [];

        final days = contributions
            .map((item) => ContributionDay.fromJson(item as Map<String, dynamic>))
            .toList();

        return ContributionStats.fromDays(days);
      } else {
        debugPrint('GitHub API returned status code: ${response.statusCode}');
        return generateSampleStats();
      }
    } catch (e) {
      debugPrint('Error fetching GitHub contributions: $e');
      return generateSampleStats();
    }
  }

  /// Generates realistic sample contribution data for offline testing or instant preview
  static ContributionStats generateSampleStats() {
    final random = Random(42); // Fixed seed for consistent sample view
    final now = DateTime.now();
    final days = <ContributionDay>[];

    // Generate last 20 weeks (~140 days)
    for (int i = 140; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // 70% chance of contribution
      final hasContribution = random.nextDouble() > 0.3;
      final count = hasContribution ? random.nextInt(8) + 1 : 0;
      final level = count == 0
          ? 0
          : count <= 2
              ? 1
              : count <= 4
                  ? 2
                  : count <= 6
                      ? 3
                      : 4;

      days.add(ContributionDay(date: date, count: count, level: level));
    }

    return ContributionStats.fromDays(days);
  }
}
