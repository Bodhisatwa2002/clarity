import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/icons/badge_icons.dart';
import '../../../core/models/badge.dart';
import '../../../core/theme/app_theme.dart';

/// A badge drawn as a passport stamp (design board 27): ink rings, the title
/// curved along the top and the place and month along the bottom, slightly
/// rotated. Used where there's room to read it: the badge detail sheet and
/// share cards. Everywhere else uses [BadgeEmblem].
///
/// Drawn on the design's 176-unit grid and scaled to [size].
class BadgeStamp extends StatelessWidget {
  const BadgeStamp({super.key, required this.badge, required this.caption, this.size = 176, this.rotation = -4});

  final BadgeProgress badge;

  /// The line along the bottom: "DZÜKOU VALLEY · OCT 2026".
  final String caption;
  final double size;

  /// Degrees.
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    final ink = earned ? badge.def.tone : AppColors.subtle;
    final k = size / 176;
    return Semantics(
      label: '${badge.titleWithLevel} stamp, $caption',
      child: Transform.rotate(
        angle: rotation * math.pi / 180,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StampPainter(
                    ink: ink,
                    earned: earned,
                    title: badge.def.title.toUpperCase(),
                    caption: caption.toUpperCase(),
                    roman: badge.roman,
                  ),
                ),
              ),
              Positioned(
                left: 64 * k,
                top: 64 * k,
                width: 48 * k,
                height: 48 * k,
                child: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
                  'stroke="${svgColor(earned ? AppColors.white : AppColors.subtle)}" stroke-width="1.6" '
                  'stroke-linecap="round" stroke-linejoin="round">'
                  '<path d="${BadgeIcons.paths[badge.def.icon] ?? BadgeIcons.paths['pin']!}"/></svg>',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampPainter extends CustomPainter {
  _StampPainter({
    required this.ink,
    required this.earned,
    required this.title,
    required this.caption,
    required this.roman,
  });

  final Color ink;
  final bool earned;
  final String title;
  final String caption;
  final String roman;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 176;
    final c = Offset(88 * k, 88 * k);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = ink;

    // Outer ring: solid when earned, dashed otherwise; inner ring when earned.
    if (earned) {
      canvas.drawCircle(c, 80 * k, stroke..strokeWidth = 3.5 * k);
      canvas.drawCircle(c, 70 * k, stroke..strokeWidth = 1.5 * k);
    } else {
      final r = 80 * k;
      final dash = 6 * k;
      for (var a = 0.0; a < 2 * math.pi; a += 2 * dash / r) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, dash / r, false, stroke..strokeWidth = 3.5 * k);
      }
    }
    canvas.drawCircle(c, 36 * k, Paint()..color = earned ? ink : AppColors.white);
    canvas.drawCircle(c, 36 * k, stroke..strokeWidth = 2 * k);

    _arcText(
      canvas,
      title,
      AppText.sans(13 * k, weight: FontWeight.w800, letterSpacing: 2.4 * k, color: ink),
      c,
      56 * k,
      top: true,
    );
    _arcText(
      canvas,
      caption,
      AppText.sans(9 * k, weight: FontWeight.w700, letterSpacing: 1 * k, color: ink),
      c,
      62 * k,
      top: false,
    );

    if (roman.isNotEmpty) {
      final text = TextPainter(
        text: TextSpan(
          text: roman,
          style: AppText.sans(11 * k, weight: FontWeight.w800, letterSpacing: 1 * k, color: AppColors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final w = text.width + 12 * k;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, 123.5 * k), width: w, height: 17 * k),
        Radius.circular(4 * k),
      );
      canvas.drawRRect(rect, Paint()..color = ink);
      text.paint(canvas, Offset(c.dx - text.width / 2, 123.5 * k - text.height / 2));
    }
  }

  /// Letters set along a circle: clockwise across the top, or reading left to
  /// right along the bottom.
  static void _arcText(Canvas canvas, String text, TextStyle style, Offset c, double r, {required bool top}) {
    final letters = [
      for (final ch in text.characters)
        TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final total = letters.fold(0.0, (sum, p) => sum + p.width);
    // Keep long captions on the arc.
    final sweep = math.min(total / r, math.pi * 0.95);
    final scale = sweep / (total / r);
    var angle = top ? -math.pi / 2 - sweep / 2 : math.pi / 2 + sweep / 2;
    for (final p in letters) {
      final step = p.width * scale / r;
      final mid = top ? angle + step / 2 : angle - step / 2;
      canvas.save();
      canvas.translate(c.dx + r * math.cos(mid), c.dy + r * math.sin(mid));
      canvas.rotate(top ? mid + math.pi / 2 : mid - math.pi / 2);
      canvas.scale(scale, 1);
      p.paint(canvas, Offset(-p.width / 2, top ? -p.height / 2 : -p.height / 2));
      canvas.restore();
      angle = top ? angle + step : angle - step;
    }
  }

  @override
  bool shouldRepaint(_StampPainter old) =>
      old.ink != ink || old.earned != earned || old.title != title || old.caption != caption || old.roman != roman;
}

/// The stamp's bottom line for [badge]: the latest place that counted and the
/// month it was earned ("DZÜKOU VALLEY · OCT 2026").
String stampCaption(String? placeName, BadgeProgress badge) {
  final when = badge.leveledAt ?? badge.earnedAt;
  final month = when == null
      ? null
      : '${const ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][when.month - 1]} ${when.year}';
  return [placeName ?? badge.progressLabel, ?month].join(' · ');
}
