import 'package:flutter/material.dart';

/// Brand color tokens used to generate the application color schemes.
///
/// Widgets should normally read semantic colors from
/// `Theme.of(context).colorScheme` instead of referencing this class directly.
abstract final class AppColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF5C6BC0);
  static const accent = Color(0xFF00ACC1);
  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF2E7D32);

  static const darkBackground = Color(0xFF101214);
  static const darkSurface = Color(0xFF181A1E);

  /// Used to derive accessible container and on-color variants.
  static const brandSeed = primary;
}
