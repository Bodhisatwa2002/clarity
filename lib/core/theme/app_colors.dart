import 'package:flutter/material.dart';

/// Every color used by the Clarity design, named by role.
///
/// Values come straight from the design file — keep them in sync with it
/// rather than inventing new shades in widgets.
abstract final class AppColors {
  // Brand blues
  static const Color blue = Color(0xFF2A66CF);
  static const Color blueLight = Color(0xFF4C8BE3);
  static const Color blueSky = Color(0xFF9DC0F0);
  static const Color blueMist = Color(0xFFC3DAF7);
  static const Color navy = Color(0xFF10264D);
  static const Color navyInk = Color(0xFF0F1E3A);
  static const Color avatarRing = Color(0xFF3A78DA);

  /// The mint accent used for rating rings, "new" dots and highlights.
  static const Color mint = Color(0xFF7FE3C4);

  // Neutrals
  static const Color ink = Color(0xFF111111);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textSoft = Color(0xFF2B2B2B);
  static const Color slate = Color(0xFF3F4857);
  static const Color muted = Color(0xFF5B6577);
  static const Color subtle = Color(0xFF8A94A6);
  static const Color navIdle = Color(0xFF9AA3B2);
  static const Color chipBorder = Color(0xFF9AA6B8);
  static const Color dashed = Color(0xFFC3CBD8);
  static const Color dashedLight = Color(0xFFD0D7E2);
  static const Color line = Color(0xFFE6EAF0);
  static const Color fieldBorder = Color(0xFFD5DCE6);
  static const Color disabled = Color(0xFFC9CED6);
  static const Color starEmpty = Color(0xFFC9D1DD);
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces
  static const Color card = Color(0xFFF4F6FA);
  static const Color segment = Color(0xFFF1F4F9);
  static const Color filter = Color(0xFFF4F7FB);
  static const Color tint = Color(0xFFEEF5FE);
  static const Color tintStrong = Color(0xFFDDEAFB);
  static const Color selectedRow = Color(0xFFE4EEFC);
  static const Color tipBox = Color(0xFFF1F5FB);
  static const Color onBlueSoft = Color(0xFFF2F7FF);
  static const Color onBlueMuted = Color(0xFFEAF2FF);
  static const Color photoTop = Color(0xFFDDEAFB);
  static const Color photoBottom = Color(0xFFC3DAF7);
  static const Color photoIcon = Color(0xFF3F5B87);
  static const Color barTrack = Color(0xFFEEF1F6);
  static const Color skeleton = Color(0xFFDDE3EC);
  static const Color skeletonLight = Color(0xFFE6EAF1);
  static const Color skeletonBlock = Color(0xFFE3E9F2);

  // Map illustration
  static const Color mapLand = Color(0xFFEEF3F9);
  static const Color mapWater = Color(0xFFD4E5F8);
  static const Color mapLake = Color(0xFFCFE2F7);
  static const Color mapPark = Color(0xFFDCEEE2);
  static const Color mapLabelWater = Color(0xFF5B7BA6);
  static const Color mapLabelPark = Color(0xFF4E7A5E);
  static const Color mapLabelCity = Color(0xFF7A8699);
  static const Color emptyRing = Color(0xFF8AA9D6);

  // Status
  static const Color success = Color(0xFF11694E);
  static const Color successBg = Color(0xFFDDF6EC);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerBg = Color(0xFFFEF1EF);
  static const Color dangerRing = Color(0xFFE8A598);
  static const Color dangerSoft = Color(0xFFFFB4A8);
  static const Color warning = Color(0xFFC2410C);
  static const Color takenFg = Color(0xFF9A3412);
  static const Color takenBg = Color(0xFFFDE7DF);

  // Overlays
  static const Color scrim = Color(0x80081228); // rgba(8,18,40,0.5)
  static const Color shadow = Color(0xFF10264D);

  /// White at the given opacity — the design leans on these for glass UI.
  static Color whiteA(double opacity) => white.withValues(alpha: opacity);
}

/// Gradients reused across screens.
abstract final class AppGradients {
  /// Background behind every in-app screen with a white sheet.
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blue, AppColors.blueLight],
  );

  /// Full-bleed sky gradient used by onboarding and system screens.
  static const LinearGradient sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blue, AppColors.blueLight, AppColors.blueSky, AppColors.blueMist],
    stops: [0, 0.42, 0.78, 1],
  );

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blue, AppColors.blueLight, AppColors.blueSky, AppColors.blueMist],
    stops: [0, 0.48, 0.82, 1],
  );

  /// Placeholder fill for photos until real images exist.
  static const LinearGradient photo = LinearGradient(
    begin: Alignment(-0.35, -1),
    end: Alignment(0.35, 1),
    colors: [AppColors.photoTop, AppColors.photoBottom],
  );

  static const LinearGradient feedPhoto = LinearGradient(
    begin: Alignment(-0.35, -1),
    end: Alignment(0.35, 1),
    colors: [AppColors.photoTop, Color(0xFFB7D2F4)],
  );

  static const LinearGradient askCard = LinearGradient(
    begin: Alignment(-0.35, -1),
    end: Alignment(0.35, 1),
    colors: [AppColors.tint, AppColors.tintStrong],
  );

  static const LinearGradient shareCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blue, AppColors.blueLight, Color(0xFFB7D2F4)],
    stops: [0, 0.55, 1],
  );

  /// The frosted "glass orb" fill used for avatars, rating rings and icons
  /// on the blue backgrounds.
  static RadialGradient glass({double strength = 1}) => RadialGradient(
    center: const Alignment(-0.36, -0.48),
    radius: 0.9,
    colors: [AppColors.whiteA(0.6 * strength), AppColors.whiteA(0.18 * strength), AppColors.whiteA(0.08 * strength)],
    stops: const [0, 0.5, 1],
  );
}

/// Shadows from the design, as Flutter [BoxShadow]s.
abstract final class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> field = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> card = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.18), blurRadius: 34, offset: const Offset(0, 14)),
  ];
  static List<BoxShadow> floating = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.16), blurRadius: 16, offset: const Offset(0, 6)),
  ];
  static List<BoxShadow> button = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> chip = [
    BoxShadow(color: AppColors.shadow.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> orb = [
    BoxShadow(color: const Color(0xFF143C8C).withValues(alpha: 0.22), blurRadius: 34, offset: const Offset(0, 14)),
  ];
}
