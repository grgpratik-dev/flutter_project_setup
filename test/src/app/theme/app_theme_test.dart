import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/app/theme/app_colors.dart';
import 'package:flutter_project_setup/src/app/theme/app_radius.dart';
import 'package:flutter_project_setup/src/app/theme/app_spacing.dart';
import 'package:flutter_project_setup/src/app/theme/app_theme.dart';
import 'package:flutter_project_setup/src/app/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    test('creates a Material 3 light theme from the brand seed', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
      expect(AppTheme.light.colorScheme.secondary, AppColors.secondary);
      expect(AppTheme.light.colorScheme.tertiary, AppColors.accent);
      expect(AppTheme.light.colorScheme.error, AppColors.error);
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
    });

    test('creates a Material 3 dark theme from the brand seed', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.colorScheme.surface, AppColors.darkSurface);
      expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.darkBackground);
    });

    test('uses the shared typography and shape tokens', () {
      expect(
        AppTheme.light.textTheme.displayLarge?.fontSize,
        AppTypography.display.fontSize,
      );
      expect(
        AppTheme.light.textTheme.headlineMedium?.fontSize,
        AppTypography.headline.fontSize,
      );
      expect(
        AppTheme.light.textTheme.titleLarge?.fontWeight,
        AppTypography.title.fontWeight,
      );
      expect(
        AppTheme.light.textTheme.bodyMedium?.height,
        AppTypography.body.height,
      );
      expect(
        AppTheme.light.textTheme.labelSmall?.fontSize,
        AppTypography.caption.fontSize,
      );

      final buttonShape =
          AppTheme.light.filledButtonTheme.style?.shape?.resolve({})
              as RoundedRectangleBorder?;
      expect(
        buttonShape?.borderRadius,
        BorderRadius.circular(AppRadius.button),
      );
    });

    test('defines the expected spacing scale', () {
      expect(
        [
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
        ],
        [4, 8, 16, 24, 32, 48],
      );
    });
  });
}
