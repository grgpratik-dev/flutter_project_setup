import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/app/theme/app_colors.dart';
import 'package:flutter_project_setup/src/app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    test('creates a Material 3 light theme from the brand seed', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.light.brightness, Brightness.light);
      expect(
        AppTheme.light.colorScheme,
        ColorScheme.fromSeed(seedColor: AppColors.brandSeed),
      );
    });

    test('creates a Material 3 dark theme from the brand seed', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(
        AppTheme.dark.colorScheme,
        ColorScheme.fromSeed(
          seedColor: AppColors.brandSeed,
          brightness: Brightness.dark,
        ),
      );
    });
  });
}
