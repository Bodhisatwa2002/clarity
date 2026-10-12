import 'package:flutter/material.dart';

import '../../../core/models/badge.dart';
import '../../../core/models/person.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/layout.dart';
import '../badge_detail_sheet.dart';
import 'badge_emblem.dart';

/// A friend's badges on their profile (PRD BDG-11, design board 33): a badge
/// they earned recently with one Congrats, the badges you share, then theirs.
/// No counts to compare, no ranking.
class FriendBadgesSection extends StatelessWidget {
  const FriendBadgesSection({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final theirs = state.badgesOf(person.id);
    if (theirs.isEmpty) return const SizedBox.shrink();
    final recent = state.recentBadgeOf(person.id);
    final mine = {for (final b in state.badges.where((b) => b.earned)) b.id};
    final shared = theirs.where((b) => mine.contains(b.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recent != null) ...[_RecentBadgeCard(person: person, badge: recent), const SizedBox(height: 16)],
        if (shared.isNotEmpty) ...[
          const SectionLabel('BADGES YOU SHARE'),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              [
                'You and ${person.firstName} both have ${shared.length == 1 ? 'this' : 'these'}.',
                if (person.tasteMatch != null) 'Taste match ${person.tasteMatch}%.',
              ].join(' '),
              style: AppText.sans(13, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 10),
          _Row(badges: shared, personId: person.id),
          const SizedBox(height: 16),
        ],
        SectionLabel("${person.firstName.toUpperCase()}'S BADGES"),
        const SizedBox(height: 10),
        _Row(badges: theirs, personId: person.id),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.badges, required this.personId});

  final List<BadgeProgress> badges;
  final String personId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (_, i) => BadgeTile(
          badge: badges[i],
          size: 52,
          width: 84,
          showSub: false,
          onTap: () => showBadgeDetail(context, badges[i].id, personId: personId),
        ),
      ),
    );
  }
}

class _RecentBadgeCard extends StatelessWidget {
  const _RecentBadgeCard({required this.person, required this.badge});

  final Person person;
  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final from = state.congratsFor(person.id, badge.id);
    final sent = from.contains(state.me.id);
    final others = [for (final id in from.where((id) => id != state.me.id)) state.person(id).firstName];
    final names = [if (sent) 'You', ...others];
    final note = names.isEmpty ? null : '${_join(names)} said congrats';
    final latest = badge.placeIds.isEmpty ? null : state.place(badge.placeIds.first);
    final when = badge.leveledAt ?? badge.earnedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 14,
            children: [
              BadgeEmblem(badge: badge, size: 60),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    if (when != null)
                      Text(
                        Fmt.relative(when).toUpperCase(),
                        style: AppText.sans(11, weight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.muted),
                      ),
                    AccentTitle(
                      lead: '${person.firstName} earned ',
                      accent: badge.titleWithLevel,
                      size: 18,
                      accentSize: 21,
                      letterSpacing: -0.3,
                      color: AppColors.ink,
                    ),
                    if (latest != null)
                      Text(
                        'The latest was ${latest.name}${latest.state == null ? '' : ', ${latest.state}'}.',
                        style: AppText.sans(13, height: 1.35, color: AppColors.slate),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              PillButton(
                label: sent ? 'Congrats sent' : 'Congrats',
                height: 40,
                fontSize: 14,
                background: sent ? AppColors.ink : AppColors.white,
                foreground: sent ? AppColors.white : AppColors.ink,
                dashedBorder: sent ? null : AppColors.ink,
                onPressed: () => context.appRead.toggleCongrats(person.id, badge.id),
              ),
              if (note != null)
                Expanded(
                  child: Text(
                    note,
                    style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.muted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _join(List<String> names) => switch (names.length) {
    1 => names.single,
    2 => '${names[0]} and ${names[1]}',
    _ => '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}',
  };
}
