import 'package:flutter/material.dart';

import '../../../core/models/person.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/pressable.dart';

/// Color of a taste-match score: green when high, blue when middling.
Color tasteMatchColor(int match) {
  if (match >= 75) return AppColors.success;
  if (match >= 55) return const Color(0xFF1D4E9E);
  return AppColors.muted;
}

/// A friend with their taste-match score.
class FriendTile extends StatelessWidget {
  const FriendTile({super.key, required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final match = person.tasteMatch ?? 0;
    return Pressable(
      onTap: onTap,
      pressedOpacity: 0.8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
        child: Row(
          spacing: 12,
          children: [
            InitialsAvatar.person(person, fontSize: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(person.name, style: AppText.sans(15, weight: FontWeight.w700)),
                  Text(
                    '${person.placesCount} places · last: ${person.lastPlace ?? '—'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 1,
              children: [
                Text(
                  '$match%',
                  style: AppText.sans(17, weight: FontWeight.w800, color: tasteMatchColor(match)),
                ),
                Text(
                  'TASTE MATCH',
                  style: AppText.sans(10, weight: FontWeight.w700, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// An incoming friend request with Accept / Decline.
class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.person, required this.onAccept, required this.onDecline});

  final Person person;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.dashed,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                InitialsAvatar.person(person, fontSize: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(person.name, style: AppText.sans(15, weight: FontWeight.w700)),
                      Text('${person.note} · ${person.placesCount} places', style: AppText.meta()),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: PillButton(label: 'Accept', height: 44, fontSize: 14, expand: true, onPressed: onAccept),
                ),
                Expanded(
                  child: PillButton(
                    label: 'Decline',
                    height: 44,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    expand: true,
                    background: AppColors.white,
                    foreground: AppColors.text,
                    dashedBorder: AppColors.subtle,
                    onPressed: onDecline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A request you sent that hasn't been answered.
class PendingTile extends StatelessWidget {
  const PendingTile({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
      child: Row(
        spacing: 12,
        children: [
          InitialsAvatar.person(person, size: 40, fontSize: 13),
          Expanded(
            child: Text(person.name, style: AppText.sans(14, weight: FontWeight.w700)),
          ),
          Text(
            'Pending',
            style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// A contact row on "Find friends" with an action pill on the right.
class ContactRow extends StatelessWidget {
  const ContactRow({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final Widget avatar;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          avatar,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(title, style: AppText.sans(15, weight: FontWeight.w700)),
                Text(subtitle, style: AppText.meta()),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}
