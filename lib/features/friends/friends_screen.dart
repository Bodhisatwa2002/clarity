import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/layout.dart';
import '../badges/badge_moments.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/layout.dart';
import 'widgets/empty_friends_view.dart';
import 'widgets/person_tiles.dart';

/// Tab 3 · Friends & requests (14), or 23b when you have none.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _showRequests = false;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    if (!state.hasFriends && state.requests.isEmpty) return const EmptyFriendsView();

    final requests = state.requests;
    return SheetScaffold(
      sheetTop: 196,
      headerPadding: const EdgeInsets.symmetric(horizontal: 22),
      header: Column(
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
                    const AccentTitle(lead: 'Your ', accent: 'people'),
                    Text('${state.friendCount} friends · ${requests.length} requests', style: AppText.headerSubtitle()),
                  ],
                ),
              ),
              PillButton(
                label: 'Find friends',
                height: 44,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                background: AppColors.white,
                foreground: AppColors.navy,
                leading: const AppIconView(AppIcon.plus, size: 16, color: AppColors.navy, strokeWidth: 2.4),
                onPressed: () => Navigator.pushNamed(context, Routes.consent),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GlassTabs(
            tabs: [const GlassTab('Friends'), GlassTab('Requests · ${requests.length}')],
            selected: _showRequests ? 1 : 0,
            onChanged: (i) => setState(() => _showRequests = i == 1),
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, Layout.navClearance),
        children: _showRequests ? _requests(context, state) : _friends(context, state),
      ),
    );
  }

  List<Widget> _friends(BuildContext context, AppState state) => [
    Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
      child: Text(
        'Sorted by taste match. Trust the high ones more.',
        style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
      ),
    ),
    const SizedBox(height: 8),
    for (final f in state.friends) ...[
      FriendTile(
        person: f,
        onTap: () => Navigator.pushNamed(context, Routes.friend, arguments: f.id),
      ),
      const SizedBox(height: 8),
    ],
  ];

  List<Widget> _requests(BuildContext context, AppState state) => [
    for (final r in state.requests) ...[
      RequestCard(
        person: r,
        onAccept: () {
          state.acceptRequest(r.id);
          BadgeMoments.celebrate(Navigator.of(context), state);
        },
        onDecline: () => state.declineRequest(r.id),
      ),
      const SizedBox(height: 8),
    ],
    if (state.requests.isEmpty) ...[
      const DashedMessageCard(title: 'All caught up', message: 'No pending requests.'),
      const SizedBox(height: 8),
    ],
    if (state.sentRequests.isNotEmpty) ...[
      const SectionLabel('SENT BY YOU', size: 12, color: AppColors.muted, padding: EdgeInsets.fromLTRB(6, 10, 6, 8)),
      for (final p in state.sentRequests) ...[PendingTile(person: p), const SizedBox(height: 8)],
    ],
  ];
}
