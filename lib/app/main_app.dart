import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:widgets/app/theme.dart';
import 'package:widgets/widgets/github_contributions/config_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
      themeMode: ThemeMode.dark,
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xFF161920),
        accentColor: Color(0xFF39D353),
        lightSource: LightSource.topLeft,
        depth: 4,
        intensity: 0.65,
      ),
      child: MaterialApp(
        title: 'GitMosaic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const GitHubConfigScreen(),
      ),
    );
  }
}

