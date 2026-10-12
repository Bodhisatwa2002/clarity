import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/icons/badge_icons.dart';
import '../../../core/models/badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/pressable.dart';

/// A badge emblem (design board 26): a line icon on a coloured disc inside a
/// ring. Levels: thin ring (I) → double ring (II) → mint ring (III), plus a
/// numeral pill. States: earned, newly earned, in progress, locked, secret.
///
/// Drawn on the design's 112-unit grid and scaled to [size].
class BadgeEmblem extends StatelessWidget {
  const BadgeEmblem({super.key, required this.badge, this.size = 68, this.ringFill});

  final BadgeProgress badge;
  final double size;

  /// 0–1: draws the mint ring filling instead of the level rings (the unlock
  /// animation, BDG-5).
  final double? ringFill;

  @override
  Widget build(BuildContext context) {
    final state = badge.state;
    final k = size / 112;
    final earned = state == BadgeState.earned || state == BadgeState.fresh;
    final iconColor = switch (state) {
      BadgeState.earned || BadgeState.fresh => AppColors.white,
      BadgeState.progress => AppColors.muted,
      _ => AppColors.chipBorder,
    };
    final level = badge.def.hasLevels ? badge.level : 0;
    return Semantics(
      label: _label(state),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _EmblemPainter(
                  state: state,
                  tone: badge.def.tone,
                  level: level,
                  fraction: badge.fraction,
                  ringFill: ringFill,
                ),
              ),
            ),
            if (state != BadgeState.secret)
              Positioned(
                left: 32 * k,
                top: 32 * k,
                width: 48 * k,
                height: 48 * k,
                child: SvgPicture.string(_svg(BadgeIcons.paths[badge.def.icon] ?? BadgeIcons.paths['pin']!, iconColor)),
              )
            else
              Center(
                child: Text('?', style: AppText.serif(38 * k, height: 1, color: AppColors.subtle)),
              ),
            if (level > 0 && state != BadgeState.secret && ringFill == null)
              Positioned(
                left: 0,
                right: 0,
                top: 91 * k,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * k, vertical: 2.5 * k),
                    decoration: BoxDecoration(
                      color: earned ? AppColors.ink : AppColors.subtle,
                      borderRadius: BorderRadius.circular(8.5 * k),
                      border: Border.all(color: AppColors.white, width: 2 * k),
                    ),
                    child: Text(
                      badge.roman,
                      style: AppText.sans(
                        10.5 * k,
                        weight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0.5,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _label(BadgeState state) {
    final name = state == BadgeState.secret ? 'Secret badge' : badge.titleWithLevel;
    return switch (state) {
      BadgeState.fresh => '$name, new',
      BadgeState.progress => '$name, ${(badge.fraction * 100).round()}% done',
      BadgeState.locked => '$name, locked',
      _ => name,
    };
  }

  static String _svg(String path, Color color) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="${svgColor(color)}" '
      'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="$path"/></svg>';
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter({
    required this.state,
    required this.tone,
    required this.level,
    required this.fraction,
    required this.ringFill,
  });

  final BadgeState state;
  final Color tone;
  final int level;
  final double fraction;
  final double? ringFill;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 112;
    final c = Offset(56 * k, 56 * k);
    final earned = state == BadgeState.earned || state == BadgeState.fresh;
    final muted = state == BadgeState.locked || state == BadgeState.secret;
    Paint stroke(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * k
      ..color = color;

    if (state == BadgeState.fresh) {
      canvas.drawCircle(c, 52 * k, Paint()..color = tone.withValues(alpha: 0.2));
    }

    if (ringFill != null) {
      canvas.drawCircle(c, 45 * k, stroke(AppColors.whiteA(0.35), 5));
      _arc(canvas, c, 45 * k, ringFill!, stroke(AppColors.mint, 5)..strokeCap = StrokeCap.round);
    } else if (state == BadgeState.progress) {
      canvas.drawCircle(c, 45 * k, stroke(AppColors.badgeTrack, 5));
      _arc(canvas, c, 45 * k, fraction, stroke(AppColors.mint, 5)..strokeCap = StrokeCap.round);
    } else if (!muted) {
      final ring = earned ? tone : AppColors.badgeRingIdle;
      switch (level) {
        case 2:
          canvas.drawCircle(c, 47 * k, stroke(ring, 1.6));
          canvas.drawCircle(c, 42.5 * k, stroke(ring, 1.6));
        case 3:
          canvas.drawCircle(c, 49 * k, stroke(ring, 1.4));
          canvas.drawCircle(c, 43.5 * k, stroke(AppColors.mint, 6.5));
        default:
          canvas.drawCircle(c, 45 * k, stroke(ring, 2));
      }
    }

    final disc = Paint()
      ..color = earned
          ? tone
          : state == BadgeState.progress
          ? AppColors.badgeDiscIdle
          : AppColors.white;
    canvas.drawCircle(c, 36 * k, disc);
    if (muted) _dashedCircle(canvas, c, 36 * k, stroke(AppColors.badgeLockedStroke, 2), 4 * k);

    if (state == BadgeState.fresh) {
      final dot = Offset(92 * k, 20 * k);
      canvas.drawCircle(dot, 9.5 * k, Paint()..color = AppColors.white);
      canvas.drawCircle(dot, 8 * k, Paint()..color = AppColors.mint);
    }
  }

  static void _arc(Canvas canvas, Offset c, double r, double t, Paint paint) {
    if (t <= 0) return;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * t.clamp(0, 1), false, paint);
  }

  static void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint, double dash) {
    final circumference = 2 * math.pi * r;
    final steps = (circumference / (dash * 2)).floor();
    for (var i = 0; i < steps; i++) {
      final start = i * 2 * dash / r;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, dash / r, false, paint);
    }
  }

  @override
  bool shouldRepaint(_EmblemPainter old) =>
      old.state != state ||
      old.tone != tone ||
      old.level != level ||
      old.fraction != fraction ||
      old.ringFill != ringFill;
}

/// Emblem with its name and a short line under it ("8 cafés", "2 of 3").
class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, this.size = 68, this.width = 104, this.onTap, this.showSub = true});

  final BadgeProgress badge;
  final double size;
  final double width;
  final VoidCallback? onTap;
  final bool showSub;

  @override
  Widget build(BuildContext context) {
    final state = badge.state;
    final muted = state == BadgeState.locked || state == BadgeState.secret;
    final title = state == BadgeState.secret ? 'Secret badge' : badge.def.title;
    final sub = switch (state) {
      BadgeState.secret => 'Keep exploring',
      BadgeState.progress || BadgeState.locked => badge.progressLabel,
      _ => badge.progressLabel,
    };
    final tile = SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          BadgeEmblem(badge: badge, size: size),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(
              13,
              weight: FontWeight.w700,
              height: 1.25,
              color: muted ? AppColors.muted : AppColors.ink,
            ),
          ),
          if (showSub)
            Text(
              sub,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sans(11, weight: FontWeight.w600, height: 1.3, color: AppColors.muted),
            ),
        ],
      ),
    );
    if (onTap == null) return tile;
    return Pressable(onTap: onTap, child: tile);
  }
}
