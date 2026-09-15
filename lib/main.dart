import 'package:flutter/material.dart';
import 'package:widgets/app/main_app.dart';
import 'package:widgets/core/home_widget_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidgetManager.initialize();
  runApp(const MainApp());
}