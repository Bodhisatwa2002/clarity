import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/models/badge.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/layout.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'badge_detail_sheet.dart';
import 'widgets/badge_emblem.dart';
import 'widgets/get_started_card.dart';

enum _Filter { all, earned, progress }

/// 31 · All badges (PRD BDG-8): grouped by kind with All / Earned / In
/// progress filters. New users see Getting started as a checklist.
class AllBadgesScreen extends StatefulWidget {
  const AllBadgesScreen({super.key});

  @override
  State<AllBadgesScreen> createState() => _AllBadgesScreenState();
}

class _AllBadgesScreenState extends State<AllBadgesScreen> {
  _Filter _filter = _Filter.all;

  bool _keep(BadgeProgress b) => switch (_filter) {
    _Filter.all => true,
    _Filter.earned => b.earned,
    _Filter.progress => !b.earned && b.progress > 0 && !b.def.isSecret,
  };

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final badges = state.badges;
    final earned = badges.where((b) => b.earned).length;
    final checklist = !state.starterDone && _filter != _Filter.progress;
    final sections = [
      for (final g in BadgeGroup.values)
        if (!(checklist && g == BadgeGroup.gettingStarted))
          (group: g, all: badges.where((b) => b.def.group == g).toList()),
    ];
    final visible = [
      for (final s in sections)
        if (s.all.where(_keep).isNotEmpty) (group: s.group, all: s.all, shown: s.all.where(_keep).toList()),
    ];

    return SheetScaffold(
      sheetTop: 212,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 14,
            children: [
              GlassIconButton(
                icon: AppIcon.back,
                iconSize: 20,
                semanticLabel: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All badges', style: AppText.screenTitle()),
                    Text(
                      earned <= 5 && !state.starterDone
                          ? '$earned of ${badges.length} earned · you’re just getting started'
                          : '$earned of ${badges.length} earned',
                      style: AppText.headerSubtitle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 8,
            children: [
              for (final (f, label) in [
                (_Filter.all, 'All'),
                (_Filter.earned, 'Earned'),
                (_Filter.progress, 'In progress'),
              ])
                _FilterPill(label: label, selected: _filter == f, onTap: () => setState(() => _filter = f)),
            ],
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, Layout.navClearance),
        children: [
          if (checklist) ...[const GetStartedCard(color: AppColors.card), const SizedBox(height: 20)],
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                spacing: 6,
                children: [
                  Text('Nothing here yet', style: AppText.sans(18, weight: FontWeight.w700)),
                  Text(
                    'Add a place and your first badges start filling in.',
                    textAlign: TextAlign.center,
                    style: AppText.sans(14, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          for (final s in visible) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: Text(s.group.label.toUpperCase(), style: AppText.sectionLabel())),
                  if (s.group != BadgeGroup.secret)
                    Text(
                      '${s.all.where((b) => b.earned).length} of ${s.all.length}',
                      style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [for (final b in s.shown) BadgeTile(badge: b, onTap: () => showBadgeDetail(context, b.id))],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: selected ? AppColors.white : null, borderRadius: BorderRadius.circular(18)),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppText.sans(13, weight: FontWeight.w700, color: selected ? AppColors.navy : AppColors.white),
      ),
    );
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: selected ? pill : DashedBorder(color: AppColors.white, child: pill),
      ),
    );
  }
}
