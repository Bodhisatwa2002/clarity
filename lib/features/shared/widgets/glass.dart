import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import 'dashed_border.dart';
import 'pressable.dart';

/// The 44pt translucent circle button used on blue headers (back, search,
/// share, settings…). Shows a mint dot when [badge] is true.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.iconSize = 19,
    this.badge = false,
    this.fill,
  });

  final AppIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double iconSize;
  final bool badge;

  /// Optional icon fill (e.g. a saved bookmark).
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whiteA(0.18),
          border: Border.all(color: AppColors.whiteA(0.5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppIconView(icon, size: iconSize, color: AppColors.white, fill: fill),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint,
                    border: Border.all(color: AppColors.blue, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The frosted sphere used for avatars, icons and scores on blue.
class GlassOrb extends StatelessWidget {
  const GlassOrb({
    super.key,
    required this.size,
    this.child,
    this.strength = 1,
    this.dashedBorder = false,
    this.shadow = false,
  });

  final double size;
  final Widget? child;

  /// Scales the highlight opacity (the rating orbs are slightly dimmer).
  final double strength;
  final bool dashedBorder;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.glass(strength: strength),
        border: dashedBorder ? null : Border.all(color: AppColors.whiteA(0.65 * strength.clamp(0, 1))),
      ),
      alignment: Alignment.center,
      child: child,
    );
    final outlined = dashedBorder
        ? DashedBorder(color: AppColors.whiteA(0.9), shape: BoxShape.circle, child: orb)
        : orb;
    return shadow ? CircleOuterShadow(shadows: AppShadows.orb, child: outlined) : outlined;
  }
}

/// Drops a shadow around a circular [child] without painting it underneath.
///
/// CSS `box-shadow` is never visible through a translucent element; Flutter's
/// [BoxShadow] is. This keeps the frosted orbs clean.
class CircleOuterShadow extends StatelessWidget {
  const CircleOuterShadow({super.key, required this.shadows, required this.child});

  final List<BoxShadow> shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _OuterShadowPainter(shadows), child: child);
}

class _OuterShadowPainter extends CustomPainter {
  _OuterShadowPainter(this.shadows);

  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Path()..addOval(Offset.zero & size);
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect((Offset.zero & size).inflate(size.shortestSide)),
      circle,
    );
    canvas.save();
    canvas.clipPath(outside);
    for (final s in shadows) {
      canvas.drawPath(circle.shift(s.offset), s.toPaint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter old) => old.shadows != shadows;
}

/// A thin circular track with a mint arc showing [progress] (0–1).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.size,
    required this.progress,
    this.strokeWidth = 3.5,
    this.trackWidth = 2,
    this.color = AppColors.mint,
    this.startAngle = -math.pi / 2,
    this.inset = 4,
    this.trackColor,
    this.child,
  });

  final double size;
  final double progress;
  final double strokeWidth;
  final double trackWidth;
  final Color color;

  /// Radians, measured clockwise from 3 o'clock.
  final double startAngle;

  /// Gap between the widget's edge and the ring's centerline.
  final double inset;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress,
          strokeWidth,
          trackWidth,
          color,
          startAngle,
          inset,
          trackColor ?? AppColors.whiteA(0.3),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(
    this.progress,
    this.strokeWidth,
    this.trackWidth,
    this.color,
    this.startAngle,
    this.inset,
    this.trackColor,
  );

  final double progress;
  final double strokeWidth;
  final double trackWidth;
  final Color color;
  final double startAngle;
  final double inset;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(inset);
    canvas.drawOval(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth
        ..color = trackColor,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      ring,
      startAngle,
      2 * math.pi * progress.clamp(0, 1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}

/// "42 / PLACES" tiles on profile headers.
class GlassStatTile extends StatelessWidget {
  const GlassStatTile({
    super.key,
    required this.value,
    required this.label,
    this.highlight = false,
    this.height = 60,
    this.onTap,
  });

  final String value;
  final String label;

  /// Mint outline for the stat that matters most (taste match).
  final bool highlight;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.whiteA(0.16),
          borderRadius: BorderRadius.circular(18),
          border: highlight ? Border.all(color: AppColors.mint, width: 1.5) : Border.all(color: AppColors.whiteA(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppText.sans(20, weight: FontWeight.w800, color: AppColors.white),
            ),
            Text(
              label,
              style: AppText.sans(11, weight: FontWeight.w700, color: AppColors.onBlueSoft),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small dashed white label on blue headers ("Viewpoint", "Your consent").
class GlassTag extends StatelessWidget {
  const GlassTag({super.key, required this.label, this.leading});

  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.whiteA(0.9),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// A plain colored dot (category markers).
class Dot extends StatelessWidget {
  const Dot({super.key, required this.color, this.size = 8, this.border});

  final Color color;
  final double size;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: border == null ? null : Border.all(color: border!),
      ),
    );
  }
}
