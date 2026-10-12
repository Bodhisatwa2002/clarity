import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place.dart';
import '../../core/models/visit.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../review/write_review_screen.dart';
import '../lists/widgets/add_to_list_sheet.dart';
import '../share/share_sheet.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/chips.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/friend_review_tile.dart';
import 'widgets/place_header.dart';
import 'widgets/your_review_card.dart';

/// 10 · Place detail, and 23c · its "no reviews yet" state.
class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final place = state.place(placeId);
    final mine = state.myVisitFor(placeId);
    final friends = state.friendVisitsFor(placeId);
    final hasReviews = mine != null || friends.isNotEmpty;

    return SheetScaffold(
      sheetTop: 300,
      header: PlaceHeader(
        place: place,
        friendsRating: state.friendsRating(placeId),
        friendCount: friends.length,
        saved: state.isSaved(placeId),
        showSave: hasReviews,
        onToggleSave: () => state.toggleSaved(placeId),
      ),
      sheet: hasReviews ? _ReviewedBody(place: place, mine: mine, friends: friends) : _NoReviewsBody(place: place),
      sheetOverlays: [
        Positioned(
          left: hasReviews ? 16 : 20,
          right: hasReviews ? 16 : 20,
          bottom: hasReviews ? 26 : 30,
          child: hasReviews ? _ShareAndListBar(place: place) : _FirstReviewBar(place: place),
        ),
      ],
    );
  }
}

class _ReviewedBody extends StatelessWidget {
  const _ReviewedBody({required this.place, required this.mine, required this.friends});

  final Place place;
  final Visit? mine;
  final List<Visit> friends;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final mine = this.mine;
    final photoCount = mine?.photoCount ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      children: [
        if (mine != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: mine.statusLabel),
              if (mine.verified)
                const StatusPill(
                  label: 'Verified visit',
                  background: AppColors.successBg,
                  foreground: AppColors.success,
                  leading: AppIconView(AppIcon.check, size: 13, color: AppColors.success, strokeWidth: 2.6),
                ),
              TagChip(
                label: _visitedAgo(mine.date),
                height: 32,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                outlineColor: AppColors.chipBorder,
              ),
            ],
          ),
          if (photoCount > 0) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: photoCount,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => PhotoPlaceholder(width: 112, height: 112, label: 'Photo ${i + 1}'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          YourReviewCard(
            visit: mine,
            onEdit: () => Navigator.pushNamed(context, Routes.review, arguments: ReviewArgs(place.id, editing: true)),
          ),
        ] else
          ChevronRow(
            title: "You haven't reviewed this yet",
            subtitle: 'Add your rating and one tip for friends',
            leading: const AppIconView(AppIcon.star, size: 20, color: AppColors.blue),
            onTap: () => Navigator.pushNamed(context, Routes.review, arguments: ReviewArgs(place.id, editing: true)),
          ),
        if (friends.isNotEmpty) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const AccentTitle(
                  lead: "Who's ",
                  accent: 'been here',
                  size: 22,
                  accentSize: 22,
                  letterSpacing: -0.4,
                  color: AppColors.ink,
                ),
                if (friends.length > 3)
                  Text(
                    'See all ${friends.length}',
                    style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.blue),
                  ),
              ],
            ),
          ),
          for (final v in friends.take(3)) ...[
            FriendReviewTile(
              visit: v,
              person: state.person(v.authorId),
              onTap: () => Navigator.pushNamed(context, Routes.friend, arguments: v.authorId),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ],
    );
  }

  static String _visitedAgo(DateTime date) {
    final now = DateTime.now();
    final months = (now.year - date.year) * 12 + now.month - date.month;
    if (months <= 0) return 'Visited this month';
    if (months == 1) return 'Visited last month';
    if (months < 12) return 'Visited $months months ago';
    final years = months ~/ 12;
    return 'Visited $years year${years > 1 ? 's' : ''} ago';
  }
}

class _NoReviewsBody extends StatelessWidget {
  const _NoReviewsBody({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashedBorder(
            color: const Color(0xFFB8C4D6),
            radius: 26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: AppColors.tint, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const AppIconView(AppIcon.chatAlert, size: 26, color: AppColors.blue, strokeWidth: 1.8),
                  ),
                  Text(
                    'None of your friends\nhave been here yet',
                    textAlign: TextAlign.center,
                    style: AppText.serif(22, height: 1.2),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      'Be the first honest opinion your friends see. Or ask if anyone knows it.',
                      textAlign: TextAlign.center,
                      style: AppText.sans(14, weight: FontWeight.w400, height: 1.5, color: AppColors.slate),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ChevronRow(
            title: 'Ask friends about it',
            radius: 20,
            leading: const AppIconView(AppIcon.friends, size: 20, color: AppColors.blue),
            onTap: () {
              context.appRead.selectTab(AppTab.feed);
              Navigator.popUntil(context, (r) => r.settings.name == Routes.home || r.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

class _ShareAndListBar extends StatelessWidget {
  const _ShareAndListBar({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Pressable(
          semanticLabel: 'Share this place',
          onTap: () => showShareSheet(context, target: ShareTarget.place, placeId: place.id),
          child: DashedBorder(
            color: AppColors.ink,
            shape: BoxShape.circle,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.share, size: 20),
            ),
          ),
        ),
        Expanded(
          child: PrimaryButton(
            label: 'Add to a list',
            icon: AppIcon.plus,
            fontSize: 16,
            shadow: true,
            onPressed: () => showAddToListSheet(context, placeId: place.id),
          ),
        ),
      ],
    );
  }
}

class _FirstReviewBar extends StatelessWidget {
  const _FirstReviewBar({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final saved = state.isSaved(place.id);
    return Row(
      spacing: 10,
      children: [
        DashedButton(
          label: saved ? 'Saved' : 'Want to go',
          height: 60,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          borderColor: saved ? AppColors.success : AppColors.ink,
          background: saved ? AppColors.successBg : AppColors.white,
          foreground: saved ? AppColors.success : AppColors.ink,
          onPressed: () => state.toggleSaved(place.id),
        ),
        Expanded(
          child: PrimaryButton(
            label: 'Write the first review',
            fontSize: 16,
            onPressed: () =>
                Navigator.pushNamed(context, Routes.review, arguments: ReviewArgs(place.id, editing: true)),
          ),
        ),
      ],
    );
  }
}
