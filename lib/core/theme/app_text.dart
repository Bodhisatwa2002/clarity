import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography for Clarity: Manrope for UI, Newsreader for place names,
/// quotes and the italic accent words in headlines.
abstract final class AppText {
  static const String sansFamily = 'Manrope';
  static const String serifFamily = 'Newsreader';

  /// Manrope at the given size. Defaults match the design's body text.
  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Newsreader at the given size.
  static TextStyle serif(
    double size, {
    bool italic = false,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: serifFamily,
    fontSize: size,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // Named styles that repeat across many screens.

  /// "Hi, Bodhi", "Notifications", "Settings" — big bold screen titles.
  static TextStyle screenTitle({Color color = AppColors.white}) =>
      sans(30, weight: FontWeight.w700, letterSpacing: -0.8, height: 1.1, color: color);

  /// Subtitle under a screen title on the blue header.
  static TextStyle headerSubtitle() => sans(14, color: AppColors.onBlueSoft);

  /// Upper-case section labels such as "ON CLARITY" and "RECENT VISITS".
  static TextStyle sectionLabel({Color color = AppColors.slate}) =>
      sans(13, weight: FontWeight.w800, letterSpacing: 0.4, color: color);

  /// Primary button label.
  static TextStyle button({Color color = AppColors.white, double size = 17}) =>
      sans(size, weight: FontWeight.w700, color: color);

  /// Small grey meta lines ("Agartala · Sep 2026 · with Asha").
  static TextStyle meta({double size = 12, Color color = AppColors.muted}) => sans(size, color: color);

  /// Place names set in the serif.
  static TextStyle placeName({double size = 20, Color color = AppColors.ink}) => serif(size, height: 1.2, color: color);
}
