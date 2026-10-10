import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/place.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/layout.dart';

/// Blue header of the place screen: category, save, the friends' rating
/// ring and the place's name.
class PlaceHeader extends StatelessWidget {
  const PlaceHeader({
    super.key,
    required this.place,
    required this.friendsRating,
    required this.friendCount,
    required this.saved,
    required this.showSave,
    required this.onToggleSave,
  });

  final Place place;
  final double? friendsRating;
  final int friendCount;
  final bool saved;
  final bool showSave;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final rating = friendsRating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBar(
          leading: GlassIconButton(
            icon: AppIcon.back,
            iconSize: 20,
            semanticLabel: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          center: GlassTag(
            label: place.category.label,
            leading: const Dot(color: AppColors.white),
          ),
          trailing: showSave
              ? GlassIconButton(
                  icon: AppIcon.bookmark,
                  semanticLabel: saved ? 'Saved to Want to go' : 'Save to Want to go',
                  fill: saved ? AppColors.white : null,
                  onPressed: onToggleSave,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 18,
          children: [
            rating == null ? const _NoRatingOrb() : _RatingOrb(rating: rating),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.serif(
                      place.name.length > 14 ? 32 : 36,
                      height: 1.02,
                      letterSpacing: -0.5,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    place.address,
                    style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onBlueSoft),
                  ),
                  if (friendCount > 0)
                    Text(
                      '${Fmt.count(friendCount, 'friend')} ${friendCount == 1 ? 'has' : 'have'} been here',
                      style: AppText.sans(13, color: AppColors.onBlueSoft),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingOrb extends StatelessWidget {
  const _RatingOrb({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      size: 128,
      progress: rating / 5,
      child: GlassOrb(
        size: 104,
        strength: 0.92,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Fmt.rating(rating),
              style: AppText.sans(34, weight: FontWeight.w800, letterSpacing: -1, height: 1, color: AppColors.white),
            ),
            const SizedBox(height: 3),
            Text(
              "FRIENDS' RATING",
              style: AppText.sans(10, weight: FontWeight.w700, color: AppColors.onBlueSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoRatingOrb extends StatelessWidget {
  const _NoRatingOrb();

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.whiteA(0.75),
      shape: BoxShape.circle,
      child: SizedBox(
        width: 128,
        height: 128,
        child: Center(
          child: GlassOrb(
            size: 104,
            strength: 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '–',
                  style: AppText.sans(34, weight: FontWeight.w800, height: 1, color: AppColors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  'NO RATINGS',
                  style: AppText.sans(10, weight: FontWeight.w700, color: AppColors.onBlueSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
