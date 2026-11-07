import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF101114);
  static const surface = Color(0xFF191B20);
  static const raised = Color(0xFF23262D);
  static const border = Color(0xFF2C2F37);
  static const text = Color(0xFFF3F3F5);
  static const muted = Color(0xFF969BA6);
  static const accent = Color(0xFFF3B658);
  static const accentSurface = Color(0xFF3B2C1C);
  static const error = Color(0xFFFF9890);
}

ThemeData calendarTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      primaryContainer: AppColors.accentSurface,
      onPrimaryContainer: AppColors.accent,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accentSurface,
      onSecondaryContainer: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surface,
      surfaceContainerHighest: AppColors.raised,
      surfaceTint: Colors.transparent,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      helperMaxLines: 2,
      errorMaxLines: 3,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}
