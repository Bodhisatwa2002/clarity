import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/place.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/pressable.dart';

/// White card listing selectable places ("NEARBY", "RESULTS", "ARE YOU AT…").
class PlaceResultCard extends StatelessWidget {
  const PlaceResultCard({
    super.key,
    required this.title,
    required this.places,
    required this.pickedId,
    required this.onPick,
    this.showIcon = true,
    this.emptyMessage,
    this.trailingRow,
    this.distanceFor,
  });

  final String title;
  final List<Place> places;
  final String? pickedId;
  final ValueChanged<String> onPick;
  final bool showIcon;
  final Widget? emptyMessage;

  /// Extra row appended after the places (e.g. "Something else here").
  final Widget? trailingRow;

  /// Overrides the distance shown for a place (defaults to [Place.distance]).
  final String? Function(Place place)? distanceFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              title,
              style: AppText.sans(12, weight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.muted),
            ),
          ),
          for (final p in places)
            PlaceResultRow(
              name: p.name,
              address: p.address,
              distance: (distanceFor?.call(p) ?? p.distance) ?? '',
              iconColor: showIcon ? p.category.color : null,
              selected: p.id == pickedId,
              onTap: () => onPick(p.id),
            ),
          if (places.isEmpty && emptyMessage != null) emptyMessage!,
          ?trailingRow,
        ],
      ),
    );
  }
}

/// One selectable row with an optional pin icon and a distance.
class PlaceResultRow extends StatelessWidget {
  const PlaceResultRow({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
    required this.selected,
    required this.onTap,
    this.iconColor,
  });

  final String name;
  final String address;
  final String distance;
  final bool selected;
  final VoidCallback onTap;

  /// Null hides the leading pin icon.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedOpacity: 0.8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: BoxConstraints(minHeight: iconColor == null ? 56 : 60),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.selectedRow : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 12,
          children: [
            if (iconColor != null)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFFEEF3FA), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppIconView(AppIcon.pin, size: 17, color: iconColor!),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    name,
                    style: AppText.sans(15, weight: FontWeight.w700, color: AppColors.navyInk),
                  ),
                  Text(address, style: AppText.sans(12, color: AppColors.muted)),
                ],
              ),
            ),
            if (distance.isNotEmpty)
              Text(
                distance,
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.slate),
              ),
          ],
        ),
      ),
    );
  }
}
