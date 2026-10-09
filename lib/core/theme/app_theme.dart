import 'package:flutter/material.dart';

/// Central place for the app's colors and theme.
/// Tweak these as the brand/design settles.
class AppColors {
  static const Color primary = Color(0xFF1F6FEB); // map-pin blue
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);

  // Category colors used to color-code pins (food, cafe, stay, trek, etc.)
  static const Color catFood = Color(0xFFEF4444);
  static const Color catCafe = Color(0xFFF59E0B);
  static const Color catStay = Color(0xFF8B5CF6);
  static const Color catTrek = Color(0xFF10B981);
  static const Color catViewpoint = Color(0xFF3B82F6);
  static const Color catOther = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
