import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/glass.dart';

/// "Hi, Bodhi" + search, notifications and the Map / List toggle.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.summary,
    required this.showList,
    required this.onToggle,
  });

  final String greeting;
  final String summary;
  final bool showList;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final unread = context.app.unreadCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(greeting, style: AppText.screenTitle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(summary, style: AppText.headerSubtitle()),
                ],
              ),
            ),
            GlassIconButton(
              icon: AppIcon.search,
              semanticLabel: 'Search',
              onPressed: () => Navigator.pushNamed(context, Routes.search),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: AppIcon.bell,
              semanticLabel: unread > 0 ? 'Notifications, $unread new' : 'Notifications',
              badge: unread > 0,
              onPressed: () => Navigator.pushNamed(context, Routes.notifications),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GlassTabs(
          tabs: const [
            GlassTab('Map', icon: AppIcon.map),
            GlassTab('List', icon: AppIcon.list),
          ],
          selected: showList ? 1 : 0,
          onChanged: (i) => onToggle(i == 1),
        ),
      ],
    );
  }
}
