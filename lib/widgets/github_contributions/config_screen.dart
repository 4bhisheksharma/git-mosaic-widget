import 'package:flutter/material.dart';
import 'package:widgets/core/constants.dart';
import 'package:widgets/core/home_widget_manager.dart';
import 'package:widgets/core/widgets/neumorphic_box.dart';
import 'package:widgets/widgets/github_contributions/github_api.dart';
import 'package:widgets/widgets/github_contributions/models.dart';
import 'package:widgets/widgets/github_contributions/widget_view.dart';

class GitHubConfigScreen extends StatefulWidget {
  const GitHubConfigScreen({super.key});

  @override
  State<GitHubConfigScreen> createState() => _GitHubConfigScreenState();
}

class _GitHubConfigScreenState extends State<GitHubConfigScreen> {
  final TextEditingController _usernameController = TextEditingController(text: '4bhisheksharma');
  ContributionPalette _selectedPalette = ContributionPalette.classicGreen;
  ContributionStats _stats = GitHubApi.generateSampleStats();
  bool _isLoading = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadUserContributions();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContributions() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);
    final stats = await GitHubApi.fetchContributions(username);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  Future<void> _syncToHomeWidget() async {
    setState(() => _isSyncing = true);

    final username = _usernameController.text.trim();
    final widgetToRender = GitHubMediumWidgetView(
      username: username,
      stats: _stats,
      palette: _selectedPalette,
    );

    // Render snapshot and update native widget
    final success = await HomeWidgetManager.renderAndUpdateWidget(
      widget: widgetToRender,
      imageKey: WidgetConstants.keyGithubImage,
      logicalSize: GitHubMediumWidgetView.widgetSize,
      androidProviderName: WidgetConstants.androidGithubWidgetProvider,
      iOSWidgetName: WidgetConstants.iosGithubWidget,
    );

    // Also persist settings
    await HomeWidgetManager.saveData(WidgetConstants.keyGithubUsername, username);
    await HomeWidgetManager.saveData(WidgetConstants.keyGithubTheme, _selectedPalette.id);

    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: success ? const Color(0xFF39D353) : Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? 'Home widget updated successfully!'
                      : 'Rendered preview. Add the widget to your home screen!',
                  style: const TextStyle(
                    color: Color(0xFFF0F6FC),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF21262D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF30363D)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13161C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Neumorphic Top Bar
              _buildTopBar(),
              const SizedBox(height: 24),

              // Live Preview Section
              _buildSectionHeader(
                title: 'LIVE WIDGET PREVIEW',
                badge: 'MEDIUM 338×158',
              ),
              const SizedBox(height: 12),

              // Widget Pedestal
              Center(
                child: NeumorphicBox(
                  borderRadius: 26,
                  depth: 5,
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GitHubMediumWidgetView(
                        username: _usernameController.text.trim(),
                        stats: _stats,
                        palette: _selectedPalette,
                      ),
                      if (_isLoading)
                        Container(
                          width: GitHubMediumWidgetView.widgetSize.width,
                          height: GitHubMediumWidgetView.widgetSize.height,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF39D353),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Neumorphic Stats Overview
              _buildStatsRow(),
              const SizedBox(height: 28),

              // GitHub Username Input Section
              _buildSectionHeader(title: 'GITHUB USERNAME'),
              const SizedBox(height: 12),
              _buildUsernameInput(),
              const SizedBox(height: 28),

              // Theme Palette Selector
              _buildSectionHeader(title: 'COLOR PALETTE'),
              const SizedBox(height: 12),
              _buildThemeSelector(),
              const SizedBox(height: 32),

              // Sync to Home Widget Button
              _buildSyncButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Mini Neumorphic Logo Tile
            NeumorphicBox(
              borderRadius: 12,
              depth: 3,
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9, (index) {
                    final isLit = index == 0 || index == 4 || index == 7 || index == 8;
                    return Container(
                      decoration: BoxDecoration(
                        color: isLit ? const Color(0xFF39D353) : const Color(0xFF222732),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GitMosaic',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Color(0xFFF0F6FC),
                  ),
                ),
                Text(
                  'Widget Studio',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7D8590),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Status Indicator Pill
        NeumorphicBox(
          borderRadius: 20,
          depth: 2,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF39D353),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x8039D353),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'READY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B949E),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, String? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8B949E),
            letterSpacing: 1.2,
          ),
        ),
        if (badge != null)
          Text(
            badge,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7D8590),
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            label: 'Contributions',
            value: '${_stats.totalCount}',
            icon: Icons.grid_view_rounded,
            accentColor: _selectedPalette.colors[3],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            label: 'Current Streak',
            value: '${_stats.currentStreak}d',
            icon: Icons.local_fire_department_rounded,
            accentColor: const Color(0xFFFF7A00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            label: 'Best Streak',
            value: '${_stats.longestStreak}d',
            icon: Icons.emoji_events_rounded,
            accentColor: const Color(0xFFFFD166),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return NeumorphicBox(
      borderRadius: 16,
      depth: 3,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF0F6FC),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7D8590),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameInput() {
    return Row(
      children: [
        // Recessed (Inset) input slot
        Expanded(
          child: NeumorphicBox(
            borderRadius: 16,
            depth: 2,
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _usernameController,
              style: const TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Enter GitHub username...',
                hintStyle: TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                  size: 19,
                  color: Color(0xFF7D8590),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _loadUserContributions(),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Extruded Neumorphic Refresh Button
        NeumorphicBox(
          borderRadius: 16,
          depth: 4,
          onTap: _isLoading ? null : _loadUserContributions,
          padding: const EdgeInsets.all(15),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF39D353),
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: Color(0xFFF0F6FC),
                ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      children: ContributionPalette.allPalettes.map((palette) {
        final isSelected = _selectedPalette.id == palette.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NeumorphicBox(
            borderRadius: 16,
            depth: isSelected ? 2 : 3,
            isPressed: isSelected,
            isHighlighted: isSelected,
            highlightColor: palette.colors.last,
            onTap: () => setState(() => _selectedPalette = palette),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Mini 5-level palette swatch
                    Row(
                      children: palette.colors.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      palette.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF8B949E),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: palette.colors.last.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: palette.colors.last,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSyncButton() {
    return NeumorphicBox(
      borderRadius: 18,
      depth: 5,
      isHighlighted: true,
      highlightColor: const Color(0xFF2EA043),
      onTap: _isSyncing ? null : _syncToHomeWidget,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF238636),
              Color(0xFF2EA043),
            ],
          ),
        ),
        child: Center(
          child: _isSyncing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.widgets_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Sync to Home Widget',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
