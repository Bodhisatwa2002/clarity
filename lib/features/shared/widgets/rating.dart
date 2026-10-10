import 'package:flutter/widgets.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

/// "★ 4.5" — the compact rating used on cards.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.fontSize = 15,
    this.starSize = 14,
    this.color = AppColors.ink,
  });

  final double rating;
  final double fontSize;
  final double starSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        StarIcon(size: starSize, color: color),
        Text(
          Fmt.rating(rating),
          style: AppText.sans(fontSize, weight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

/// Five read-only stars supporting halves (4.5 → ★★★★½).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rated ${Fmt.rating(rating)} out of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [for (var i = 0; i < 5; i++) _star((rating - i).clamp(0, 1).toDouble())],
      ),
    );
  }

  Widget _star(double fill) {
    if (fill >= 1) return StarIcon(size: size);
    if (fill <= 0) return StarIcon(size: size, color: AppColors.starEmpty);
    return Stack(
      children: [
        StarIcon(size: size, color: AppColors.starEmpty),
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: fill,
            child: StarIcon(size: size),
          ),
        ),
      ],
    );
  }
}
