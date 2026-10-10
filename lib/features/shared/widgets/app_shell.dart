import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/state/app_state.dart';
import '../../feed/feed_screen.dart';
import '../../friends/friends_screen.dart';
import '../../map/map_screen.dart';
import '../../profile/profile_screen.dart';
import 'floating_nav_bar.dart';

/// The signed-in home: four tabs under one floating nav bar.
/// The (+) in the middle opens "Add a place" as a full-screen flow.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _tabs = [MapScreen(), FeedScreen(), FriendsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    return Stack(
      children: [
        IndexedStack(
          index: state.tab.index,
          children: [
            // Pause animations (e.g. loading skeletons) on hidden tabs.
            for (var i = 0; i < _tabs.length; i++) TickerMode(enabled: i == state.tab.index, child: _tabs[i]),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 26,
          child: FloatingNavBar(
            current: state.tab,
            onSelect: state.selectTab,
            onAdd: () => Navigator.pushNamed(context, Routes.addPlace),
          ),
        ),
      ],
    );
  }
}
