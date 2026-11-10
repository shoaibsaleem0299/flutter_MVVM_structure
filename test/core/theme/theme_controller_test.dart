import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeController', () {
    test('initial state defaults to system when no pref saved', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(themeControllerProvider);
      expect(theme, ThemeMode.system);
    });

    test('setThemeMode updates state and persists in SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(themeControllerProvider.notifier);
      await controller.setThemeMode(ThemeMode.dark);

      expect(container.read(themeControllerProvider), ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });
  });
}
