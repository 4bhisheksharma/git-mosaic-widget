import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:widgets/core/constants.dart';

/// Helper to coordinate rendering, data persistence, and updating native home widgets.
class HomeWidgetManager {
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);
    } catch (e) {
      debugPrint('HomeWidget initialization warning: $e');
    }
  }

  /// Renders a Flutter widget off-screen into an image file and updates the native widget.
  static Future<bool> renderAndUpdateWidget({
    required Widget widget,
    required String imageKey,
    required Size logicalSize,
    required String androidProviderName,
    required String iOSWidgetName,
  }) async {
    try {
      // 1. Render Flutter widget offscreen to a file
      final path = await HomeWidget.renderFlutterWidget(
        widget,
        key: imageKey,
        logicalSize: logicalSize,
        pixelRatio: 3.0,
      );

      debugPrint('Rendered widget image to: $path');

      // 2. Notify native widget systems to refresh
      await HomeWidget.updateWidget(
        androidName: androidProviderName,
        iOSName: iOSWidgetName,
      );

      return true;
    } catch (e) {
      debugPrint('Failed to render/update widget: $e');
      return false;
    }
  }

  /// Save raw key-value data to shared widget storage
  static Future<bool> saveData<T>(String key, T value) async {
    try {
      return await HomeWidget.saveWidgetData<T>(key, value) ?? false;
    } catch (e) {
      debugPrint('Failed to save widget data: $e');
      return false;
    }
  }
}
