import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place_category.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/layout.dart';
import '../share/share_sheet.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'widgets/badge_grid.dart';
import 'widgets/category_bars.dart';

/// Tab 4 · My profile (19).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final me = state.me;

    // Category counts: the demo account's older history plus visits on the map.
    final counts = <PlaceCategory, int>{if (!state.isNewAccount) ...MockData.olderCategoryCounts};
    for (final v in state.myVisits) {
      final c = state.place(v.placeId).category;
      counts[c] = (counts[c] ?? 0) + 1;
    }
    final top = (counts.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(4)
        .toList();

    return SheetScaffold(
      sheetTop: 364,
      header: Column(
        children: [
          HeaderBar(
            leading: GlassIconButton(
              icon: AppIcon.share,
              semanticLabel: 'Share my map',
              onPressed: () => showShareSheet(context, target: ShareTarget.map),
            ),
            trailing: GlassIconButton(
              icon: AppIcon.settings,
              iconSize: 20,
              semanticLabel: 'Settings',
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
            ),
          ),
          const SizedBox(height: 2),
          GlassOrb(
            size: 88,
            child: Text(
              me.initials,
              style: AppText.sans(30, weight: FontWeight.w800, letterSpacing: -1, color: AppColors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            me.name,
            textAlign: TextAlign.center,
            style: AppText.serif(28, height: 1.05, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '@${state.username} · clarity.in/${state.username}',
            style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.onBlueSoft),
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: GlassStatTile(value: '${state.placesCount}', label: 'PLACES'),
              ),
              Expanded(
                child: GlassStatTile(value: '${state.citiesCount}', label: 'CITIES'),
              ),
              Expanded(
                child: GlassStatTile(
                  value: '${state.friendCount}',
                  label: 'FRIENDS',
                  onTap: () => state.selectTab(AppTab.friends),
                ),
              ),
            ],
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, Layout.navClearance),
        children: [
          const SectionLabel('TOP CATEGORIES'),
          const SizedBox(height: 10),
          if (top.isEmpty)
            const DashedMessageCard(title: 'Nothing yet', message: 'Your top categories appear after a few places.')
          else
            CategoryBars(counts: top),
          const SizedBox(height: 18),
          const BadgeGrid(),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Lists', style: AppText.sans(20, weight: FontWeight.w700, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 8),
          for (final list in MockData.myLists) ...[
            ChevronRow(
              title: list.title,
              subtitle: list.subtitle,
              titleStyle: AppText.serif(19),
              onTap: () => Navigator.pushNamed(context, Routes.collabList),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
