import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A box with a dashed outline — the design's signature "unselected" look.
///
/// Flutter has no dashed [Border], so this paints one over [child].
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.color = const Color(0xFF8A94A6),
    this.strokeWidth = 1.5,
    this.radius = 999,
    this.dash = 4,
    this.gap = 3,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final Color color;
  final double strokeWidth;

  /// Corner radius; clamped to half the shortest side (so 999 = pill).
  final double radius;
  final double dash;
  final double gap;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dash: dash,
        gap: gap,
        circle: shape == BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.circle,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth);
    final path = Path();
    if (circle) {
      path.addOval(rect);
    } else {
      final r = radius.clamp(0, rect.shortestSide / 2).toDouble();
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.circle != circle;
}
