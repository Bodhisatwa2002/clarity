import 'package:flutter/widgets.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/place_category.dart';
import '../../../core/theme/app_theme.dart';
import 'dashed_border.dart';
import 'glass.dart';
import 'pressable.dart';

/// "● Food · Visited" — the category line on place cards.
class CategoryLine extends StatelessWidget {
  const CategoryLine({super.key, required this.category, this.suffix, this.label});

  final PlaceCategory category;

  /// Text after the separator dot ("Visited", "Want to go").
  final String? suffix;

  /// Overrides the category's own label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Dot(color: category.color),
        const SizedBox(width: 6),
        Text(
          label ?? category.label,
          style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.slate),
        ),
        if (suffix != null) ...[
          const SizedBox(width: 6),
          Text(
            '·',
            style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.subtle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              suffix!,
              overflow: TextOverflow.ellipsis,
              style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.slate),
            ),
          ),
        ],
      ],
    );
  }
}

/// Grey placeholder tile standing in for a photo.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.radius = 20,
    this.label,
    this.iconSize = 22,
    this.gradient = AppGradients.photo,
  });

  final double? width;
  final double? height;
  final double radius;
  final String? label;
  final double iconSize;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(radius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          AppIconView(AppIcon.image, size: iconSize, color: AppColors.photoIcon, strokeWidth: 1.8),
          if (label != null)
            Text(
              label!,
              style: AppText.sans(11, weight: FontWeight.w700, color: AppColors.photoIcon),
            ),
        ],
      ),
    );
  }
}

/// Dashed card with a serif title — "Nothing here yet", "All caught up".
class DashedMessageCard extends StatelessWidget {
  const DashedMessageCard({
    super.key,
    required this.title,
    required this.message,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
    this.borderColor = AppColors.dashed,
  });

  final String title;
  final String message;
  final EdgeInsets padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: borderColor,
      radius: 22,
      child: Container(
        width: double.infinity,
        padding: padding,
        child: Column(
          spacing: 6,
          children: [
            Text(title, textAlign: TextAlign.center, style: AppText.serif(20)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.sans(13, weight: FontWeight.w400, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable grey row ending in a chevron ("Ask friends about it").
class ChevronRow extends StatelessWidget {
  const ChevronRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailingText,
    this.titleStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.minHeight = 56,
    this.radius = 22,
    this.color = AppColors.card,
  });

  final String title;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? leading;
  final String? trailingText;
  final TextStyle? titleStyle;
  final EdgeInsets padding;
  final double minHeight;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
        child: Row(
          spacing: 12,
          children: [
            ?leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(title, style: titleStyle ?? AppText.sans(15, weight: FontWeight.w700)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.muted),
              ),
            const AppIconView(AppIcon.chevronRight, size: 18, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

/// A placeholder bar for loading skeletons, gently pulsing.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius, this.color = AppColors.skeleton});

  final double? width;
  final double height;
  final double? radius;
  final Color color;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.radius ?? widget.height / 2),
      ),
    );
    if (reduceMotion) return box;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // 1 → 0.45 → 1, eased like the CSS keyframes.
        final t = Curves.easeInOut.transform((_pulse.value * 2 - 1).abs());
        return Opacity(opacity: 0.45 + 0.55 * t, child: child);
      },
      child: box,
    );
  }
}
