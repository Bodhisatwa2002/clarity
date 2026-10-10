import 'package:flutter/material.dart';

import '../../../core/models/person.dart';
import '../../../core/models/visit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/rating.dart';

/// One friend's take on a place, under "Who's been here".
class FriendReviewTile extends StatelessWidget {
  const FriendReviewTile({super.key, required this.visit, required this.person, required this.onTap});

  final Visit visit;
  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final withYou = visit.companions.contains('you');
    final quote = visit.text.isNotEmpty ? visit.text : visit.tip;
    return Pressable(
      onTap: onTap,
      pressedOpacity: 0.8,
      child: DashedBorder(
        color: AppColors.dashedLight,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              InitialsAvatar.person(person, size: 42, fontSize: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(person.firstName, style: AppText.sans(15, weight: FontWeight.w700)),
                        RatingBadge(rating: visit.rating, fontSize: 14, starSize: 13),
                      ],
                    ),
                    Text('“$quote”', style: AppText.serif(16, height: 1.35, color: AppColors.text)),
                    Text('${Fmt.monthYear(visit.date)}${withYou ? ' · with you' : ''}', style: AppText.meta()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
