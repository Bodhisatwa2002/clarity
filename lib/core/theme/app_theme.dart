import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

export 'app_colors.dart';
export 'app_text.dart';

/// App-wide [ThemeData]. Most styling lives in the widgets themselves
/// (the design is highly custom); this sets the defaults they fall back to.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppText.sansFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.white,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );

    return base.copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: AppColors.tintStrong,
        selectionHandleColor: AppColors.blue,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.sans(13, weight: FontWeight.w600, color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
