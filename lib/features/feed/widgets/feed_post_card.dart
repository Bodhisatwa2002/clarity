import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/models/social.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../badges/badge_detail_sheet.dart';
import '../../badges/widgets/badge_emblem.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/rating.dart';

/// One card in the friends feed: a visit, a question, or a list update.
class FeedPostCard extends StatefulWidget {
  const FeedPostCard({super.key, required this.post});

  final FeedPost post;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final post = widget.post;
    final author = state.person(post.authorId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              InitialsAvatar.person(
                author,
                size: 42,
                fontSize: 14,
                onTap: () => Navigator.pushNamed(context, Routes.friend, arguments: author.id),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppText.sans(14, weight: FontWeight.w500, height: 1.35, color: AppColors.text),
                    children: [
                      TextSpan(
                        text: author.firstName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: ' ${post.verb} '),
                      TextSpan(
                        text: post.subject,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                post.when,
                style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
          switch (post.type) {
            FeedPostType.visit => _VisitBody(post: post),
            FeedPostType.ask => _AskBody(post: post),
            FeedPostType.list => _ListBody(post: post),
            FeedPostType.badge => _BadgeBody(post: post),
          },
          Row(
            spacing: 8,
            children: [
              if (post.type == FeedPostType.badge && post.badgeId != null)
                Builder(
                  builder: (context) {
                    final from = state.congratsFor(post.authorId, post.badgeId!);
                    final sent = from.contains(state.me.id);
                    return _ReactionPill(
                      active: sent,
                      activeBg: AppColors.ink,
                      activeFg: AppColors.white,
                      onTap: () => state.toggleCongrats(post.authorId, post.badgeId!),
                      child: (fg) => Text(
                        from.isEmpty ? 'Congrats' : '${sent ? 'Congrats sent' : 'Congrats'} · ${from.length}',
                        style: AppText.sans(13, weight: FontWeight.w700, color: fg),
                      ),
                    );
                  },
                )
              else
                _ReactionPill(
                  active: _liked,
                  activeBg: AppColors.ink,
                  activeFg: AppColors.white,
                  onTap: () => setState(() => _liked = !_liked),
                  child: (fg) => Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      AppIconView(AppIcon.heart, size: 15, color: fg, fill: _liked ? AppColors.white : null),
                      Text(
                        '${post.likes + (_liked ? 1 : 0)}',
                        style: AppText.sans(13, weight: FontWeight.w700, color: fg),
                      ),
                    ],
                  ),
                ),
              if (post.type == FeedPostType.visit && post.placeId != null)
                Builder(
                  builder: (context) {
                    final saved = state.isSaved(post.placeId!);
                    return _ReactionPill(
                      active: saved,
                      activeBg: AppColors.successBg,
                      activeFg: AppColors.success,
                      onTap: () => state.toggleSaved(post.placeId!),
                      child: (fg) => Text(
                        saved ? 'Saved to Want to go' : 'Save to Want to go',
                        style: AppText.sans(13, weight: FontWeight.w700, color: fg),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Rahul earned Trekker I": the badge and what it's for. Opens the badge.
class _BadgeBody extends StatelessWidget {
  const _BadgeBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final badge = state.badgesOf(post.authorId).where((b) => b.id == post.badgeId).firstOrNull;
    final latest = badge == null || badge.placeIds.isEmpty ? null : state.place(badge.placeIds.first).name;
    return Pressable(
      onTap: () => showBadgeDetail(context, post.badgeId!, personId: post.authorId),
      pressedOpacity: 0.85,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          spacing: 14,
          children: [
            if (badge != null) BadgeEmblem(badge: badge, size: 56),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(post.quote, style: AppText.sans(14, weight: FontWeight.w600, height: 1.35)),
                  if (latest != null)
                    Text('The latest was $latest.', style: AppText.sans(13, height: 1.35, color: AppColors.slate)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitBody extends StatelessWidget {
  const _VisitBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final category = post.category!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Pressable(
          onTap: () => Navigator.pushNamed(context, Routes.place, arguments: post.placeId),
          pressedOpacity: 0.85,
          child: Stack(
            children: [
              const PhotoPlaceholder(
                width: double.infinity,
                height: 150,
                radius: 18,
                iconSize: 26,
                gradient: AppGradients.feedPhoto,
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    spacing: 6,
                    children: [
                      Dot(color: category.color, size: 7),
                      Text(
                        category.label,
                        style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: RatingBadge(rating: post.rating!, fontSize: 13, starSize: 12, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
        Text('“${post.quote}”', style: AppText.serif(17, height: 1.4, color: AppColors.text)),
      ],
    );
  }
}

class _AskBody extends StatelessWidget {
  const _AskBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.blueLight,
      radius: 18,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text('“${post.quote}”', style: AppText.serif(18, height: 1.35, color: AppColors.navy)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.footnote ?? '',
                    style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.slate),
                  ),
                ),
                PillButton(
                  label: 'Reply with a pin',
                  height: 38,
                  fontWeight: FontWeight.w700,
                  onPressed: () => Navigator.pushNamed(context, Routes.addPlace),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.collabList),
      pressedOpacity: 0.8,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.tintStrong, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.list, size: 22, color: AppColors.blue),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(post.quote, style: AppText.serif(19)),
                  Text(
                    post.footnote ?? '',
                    style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const AppIconView(AppIcon.chevronRight, size: 18, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

/// Like / save pill: dashed when idle, filled when active.
class _ReactionPill extends StatelessWidget {
  const _ReactionPill({
    required this.active,
    required this.activeBg,
    required this.activeFg,
    required this.onTap,
    required this.child,
  });

  final bool active;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onTap;
  final Widget Function(Color foreground) child;

  @override
  Widget build(BuildContext context) {
    final fg = active ? activeFg : AppColors.text;
    final border = active ? (activeBg == AppColors.ink ? AppColors.ink : activeFg) : AppColors.subtle;
    return Pressable(
      onTap: onTap,
      child: DashedBorder(
        color: border,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? activeBg : AppColors.white,
            borderRadius: BorderRadius.circular(19),
          ),
          alignment: Alignment.center,
          child: child(fg),
        ),
      ),
    );
  }
}
