import 'package:flutter/material.dart';
import 'package:widgets/app/theme.dart';
import 'package:widgets/widgets/github_contributions/config_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anything Widgets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GitHubConfigScreen(),
    );
  }
}

