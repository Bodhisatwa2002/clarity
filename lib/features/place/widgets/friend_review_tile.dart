import 'package:flutter/material.dart';

import '../../../core/models/person.dart';
import '../../../core/models/visit.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/buttons.dart';
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
                    if (context.app.canThank(visit)) ...[
                      const SizedBox(height: 6),
                      _ThanksButton(visitId: visit.id, firstName: person.firstName),
                    ],
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

/// "Thanks, went there!" (PRD BDG-13): you went because of this review.
/// Counts toward the author's Trusted voice badge and tells them.
class _ThanksButton extends StatelessWidget {
  const _ThanksButton({required this.visitId, required this.firstName});

  final String visitId;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final sent = context.app.hasThanked(visitId);
    return Semantics(
      button: true,
      label: sent ? 'You thanked $firstName for this review' : 'Thank $firstName: you went because of this review',
      excludeSemantics: true,
      child: PillButton(
        label: sent ? 'Thanked $firstName' : 'Thanks, went there!',
        height: 34,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        background: sent ? AppColors.successBg : AppColors.white,
        foreground: sent ? AppColors.success : AppColors.ink,
        dashedBorder: sent ? null : AppColors.subtle,
        onPressed: () => context.appRead.toggleThanks(visitId),
      ),
    );
  }
}
