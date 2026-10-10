import 'package:flutter/material.dart';

import '../../../core/models/place.dart';
import '../../../core/models/visit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/rating.dart';

/// The floating card above the nav showing the selected pin.
class PlacePreviewCard extends StatelessWidget {
  const PlacePreviewCard({super.key, required this.place, required this.visit, required this.onTap});

  final Place place;
  final Visit visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = place.category;
    return Pressable(
      onTap: onTap,
      pressedOpacity: 0.85,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashedBorder(
                  color: category.color,
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Dot(color: category.color, size: 7),
                        Text(
                          category.label,
                          style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                ),
                RatingBadge(rating: visit.rating),
              ],
            ),
            const SizedBox(height: 8),
            Text(place.name, style: AppText.serif(23, height: 1.15)),
            const SizedBox(height: 8),
            Text(
              '${place.area} · Visited ${Fmt.monthYear(visit.date)} · ${visit.companionsLabel}',
              style: AppText.sans(13, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.tipBox, borderRadius: BorderRadius.circular(14)),
              child: Text.rich(
                TextSpan(
                  style: AppText.sans(13, weight: FontWeight.w400, height: 1.4, color: AppColors.textSoft),
                  children: [
                    const TextSpan(
                      text: 'One thing to know: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: visit.tip),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
