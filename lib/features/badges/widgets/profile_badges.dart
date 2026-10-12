import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/models/badge.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/pressable.dart';
import '../badge_detail_sheet.dart';
import 'badge_emblem.dart';
import 'get_started_card.dart';

/// Profile tab, badges (PRD BDG-7, design board 30): Get started until it's
/// done, "Your next badge", then the collection with earned badges first.
class ProfileBadges extends StatelessWidget {
  const ProfileBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final badges = state.badges;
    final next = state.nextBadge;
    final row = [
      ...badges.where((b) => b.earned).toList()..sort(
        (a, b) => (b.leveledAt ?? b.earnedAt ?? DateTime(0)).compareTo(a.leveledAt ?? a.earnedAt ?? DateTime(0)),
      ),
      ...badges.where((b) => !b.earned && b.progress > 0 && !b.def.isSecret),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        if (!state.starterDone) const GetStartedCard(color: AppColors.card),
        if (next != null) _NextBadgeCard(badge: next),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text('Badges', style: AppText.sans(20, weight: FontWeight.w700, letterSpacing: -0.3)),
              ),
              Text(
                '${state.badgesEarned} of ${badges.length}',
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (row.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Your first badge comes with your first place.',
              style: AppText.sans(14, color: AppColors.muted),
            ),
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: row.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (_, i) => BadgeTile(
                badge: row[i],
                size: 64,
                width: 88,
                showSub: false,
                onTap: () => showBadgeDetail(context, row[i].id),
              ),
            ),
          ),
        Pressable(
          onTap: () => Navigator.pushNamed(context, Routes.badges),
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
            alignment: Alignment.center,
            child: Text('See all badges', style: AppText.sans(15, weight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _NextBadgeCard extends StatelessWidget {
  const _NextBadgeCard({required this.badge});

  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => showBadgeDetail(context, badge.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(24)),
        child: Row(
          spacing: 14,
          children: [
            BadgeEmblem(badge: badge, size: 64),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppText.sans(12, weight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.navy),
                      children: [
                        const TextSpan(text: 'YOUR '),
                        TextSpan(
                          text: 'next',
                          style: AppText.serif(14, italic: true, color: AppColors.navy),
                        ),
                        const TextSpan(text: ' BADGE'),
                      ],
                    ),
                  ),
                  Text(badge.nextTitle, style: AppText.serif(21, height: 1.15)),
                  Text(badge.def.howTo, style: AppText.sans(13, height: 1.35, color: AppColors.slate)),
                  const SizedBox(height: 4),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: badge.fraction,
                            minHeight: 6,
                            backgroundColor: AppColors.white,
                            valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                          ),
                        ),
                      ),
                      Text(
                        badge.progressLabel,
                        style: AppText.sans(12, weight: FontWeight.w800, color: AppColors.navy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
