import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/layout.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'widgets/feed_error_view.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/feed_skeleton.dart';

/// Tab 2 · Friends feed (12), with loading (24c) and error (24b) states.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final status = state.feedStatus;
    final loading = status == FeedStatus.loading || status == FeedStatus.idle;

    return SheetScaffold(
      sheetTop: 152,
      headerPadding: const EdgeInsets.symmetric(horizontal: 22),
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                const AccentTitle(lead: "Friends' ", accent: 'feed'),
                Text(
                  loading ? 'Loading what your friends have been up to…' : 'Newest first. No algorithm.',
                  style: AppText.headerSubtitle(),
                ),
              ],
            ),
          ),
          if (status == FeedStatus.ready)
            GlassIconButton(
              icon: AppIcon.search,
              semanticLabel: 'Search',
              onPressed: () => Navigator.pushNamed(context, Routes.search),
            ),
        ],
      ),
      sheet: switch (status) {
        FeedStatus.idle || FeedStatus.loading => const FeedSkeleton(),
        FeedStatus.error => FeedErrorView(onRecovered: state.showFeed),
        FeedStatus.ready => state.hasFriends ? const _FeedList() : const _QuietFeed(),
      },
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList();

  @override
  Widget build(BuildContext context) {
    final posts = context.app.feed;
    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: () => Future.delayed(const Duration(milliseconds: 900)),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, Layout.navClearance),
        itemCount: posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) => FeedPostCard(post: posts[i]),
      ),
    );
  }
}

/// A new account with no friends yet has nothing to show.
class _QuietFeed extends StatelessWidget {
  const _QuietFeed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        spacing: 16,
        children: [
          const DashedMessageCard(
            title: 'Your feed is quiet',
            message: 'Add friends to see where they go and what they think.',
          ),
          DashedButton(
            label: 'Find friends from contacts',
            expand: true,
            borderColor: AppColors.ink,
            foreground: AppColors.ink,
            onPressed: () => Navigator.pushNamed(context, Routes.consent),
          ),
        ],
      ),
    );
  }
}
