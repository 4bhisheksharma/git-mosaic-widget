import 'package:flutter/material.dart';
import 'package:widgets/core/constants.dart';
import 'package:widgets/core/home_widget_manager.dart';
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
              ),
              const SizedBox(width: 10),
              Text(
                success
                    ? 'Home widget updated successfully!'
                    : 'Rendered preview. Add the widget to your home screen!',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF161B22),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF30363D)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitMosaic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Header
            const Text(
              'LIVE WIDGET PREVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B949E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Live Widget Preview Card
            Center(
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
                        color: Colors.black54,
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
            const SizedBox(height: 28),

            // GitHub Username Input Section
            const Text(
              'GITHUB USERNAME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B949E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter GitHub username...',
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                    onSubmitted: (_) => _loadUserContributions(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loadUserContributions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Theme Palette Selector
            const Text(
              'COLOR THEME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B949E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ContributionPalette.allPalettes.map((palette) {
                final isSelected = _selectedPalette.id == palette.id;
                return InkWell(
                  onTap: () => setState(() => _selectedPalette = palette),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2EA043) : const Color(0xFF30363D),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mini color dots
                        Row(
                          children: palette.colors.map((c) {
                            return Container(
                              margin: const EdgeInsets.only(right: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          palette.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF8B949E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Sync to Home Widget Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncToHomeWidget,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.widgets_rounded),
                label: Text(
                  _isSyncing ? 'Updating Widget...' : 'Sync to Home Widget',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
