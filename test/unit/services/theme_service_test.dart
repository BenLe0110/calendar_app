import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/services/theme_service.dart';

void main() {
  late ThemeService themeService;

  setUp(() {
    themeService = ThemeService();
  });

  group('ThemeService Tests', () {
    test('getTheme - should return light theme by default', () {
      final theme = themeService.getTheme();
      expect(theme.brightness, Brightness.light);
    });

    test('getTheme - should return dark theme when dark mode is enabled', () {
      themeService.setDarkMode(true);
      final theme = themeService.getTheme();
      expect(theme.brightness, Brightness.dark);
    });

    test('getTheme - should return light theme when dark mode is disabled', () {
      themeService.setDarkMode(false);
      final theme = themeService.getTheme();
      expect(theme.brightness, Brightness.light);
    });

    test('getTheme - should have correct primary color', () {
      final theme = themeService.getTheme();
      expect(theme.primaryColor, Colors.blue);
    });

    test('getTheme - should have correct accent color', () {
      final theme = themeService.getTheme();
      expect(theme.colorScheme.secondary, Colors.blueAccent);
    });

    test('getTheme - should have correct text styles', () {
      final theme = themeService.getTheme();
      expect(theme.textTheme.headlineMedium?.fontSize, 24.0);
      expect(theme.textTheme.bodyLarge?.fontSize, 16.0);
    });

    test('getTheme - should have correct card theme', () {
      final theme = themeService.getTheme();
      expect(theme.cardTheme.elevation, 2.0);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('getTheme - should have correct app bar theme', () {
      final theme = themeService.getTheme();
      expect(theme.appBarTheme.elevation, 0.0);
      expect(theme.appBarTheme.centerTitle, true);
    });

    test('getTheme - should have correct button theme', () {
      final theme = themeService.getTheme();
      expect(theme.elevatedButtonTheme.style?.padding,
          isA<MaterialStateProperty<EdgeInsets>>());
      expect(theme.elevatedButtonTheme.style?.shape,
          isA<MaterialStateProperty<OutlinedBorder>>());
    });
  });
}
