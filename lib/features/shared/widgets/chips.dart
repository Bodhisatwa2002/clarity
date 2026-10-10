import 'package:flutter/widgets.dart';

import '../../../core/models/place_category.dart';
import '../../../core/theme/app_theme.dart';
import 'dashed_border.dart';
import 'glass.dart';
import 'pressable.dart';

/// How a [TagChip] is filled.
enum ChipLook {
  /// White with a grey dashed outline — the default, unselected look.
  outline,

  /// Solid black with white text — selected.
  selected,

  /// Pale blue with a blue dashed outline — highlighted / recommended.
  tinted,
}

/// The dashed pill used for tags, quick picks and filters across the app.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.look = ChipLook.outline,
    this.onTap,
    this.height = 38,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
    this.serif = false,
    this.dotColor,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.outlineColor = AppColors.subtle,
    this.background = AppColors.white,
    this.foreground = AppColors.text,
    this.minWidth = 0,
  });

  final String label;
  final ChipLook look;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;

  /// Set the label in Newsreader (quick tags, recent searches).
  final bool serif;
  final Color? dotColor;
  final Widget? leading;
  final EdgeInsets padding;
  final Color outlineColor;
  final Color background;
  final Color foreground;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? dashed) = switch (look) {
      ChipLook.outline => (background, foreground, outlineColor),
      ChipLook.selected => (AppColors.ink, AppColors.white, null),
      ChipLook.tinted => (AppColors.tintStrong, AppColors.navy, AppColors.blueLight),
    };
    final style = serif
        ? AppText.serif(fontSize + 3, color: fg)
        : AppText.sans(fontSize, weight: fontWeight, color: fg);

    Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: height,
      constraints: BoxConstraints(minWidth: minWidth),
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(height / 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (dotColor != null) ...[Dot(color: dotColor!), const SizedBox(width: 6)],
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(label, style: style),
        ],
      ),
    );
    if (dashed != null) chip = DashedBorder(color: dashed, child: chip);
    return onTap == null ? chip : Pressable(onTap: onTap, child: chip);
  }
}

/// A solid, non-interactive status pill ("Visited", "Verified visit").
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.background = AppColors.ink,
    this.foreground = AppColors.white,
    this.leading,
    this.height = 32,
    this.fontSize = 12,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Widget? leading;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(height / 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Text(
            label,
            style: AppText.sans(fontSize, weight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}

/// One option in the horizontal category filter ("All", "Food", "Café"…).
class CategoryFilterChip extends StatelessWidget {
  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: active ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Dot(color: color, border: active ? AppColors.white : null),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppText.sans(
              13,
              weight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? AppColors.white : AppColors.text,
            ),
          ),
        ],
      ),
    );
    return Pressable(
      onTap: onTap,
      child: active ? content : DashedBorder(color: AppColors.chipBorder, child: content),
    );
  }
}

/// "All" plus every pickable category, scrolling horizontally.
/// A null [selected] means "All".
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key, required this.selected, required this.onChanged});

  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          CategoryFilterChip(
            label: 'All',
            color: AppColors.mint,
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final c in PlaceCategory.pickable)
            CategoryFilterChip(label: c.label, color: c.color, active: selected == c, onTap: () => onChanged(c)),
        ],
      ),
    );
  }
}
