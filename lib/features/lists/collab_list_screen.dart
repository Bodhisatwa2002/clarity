import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/social.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/share_links.dart';
import '../share/share_sheet.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';

/// 18 · Collaborative list — friends add places and vote with +1.
class CollabListScreen extends StatefulWidget {
  const CollabListScreen({super.key, this.listId});

  /// Which list; null opens your first shared list.
  final String? listId;

  @override
  State<CollabListScreen> createState() => _CollabListScreenState();
}

class _CollabListScreenState extends State<CollabListScreen> {
  final Set<String> _voted = {};
  bool _inviteCopied = false;

  void _invite(CollabList list) {
    final state = context.appRead;
    Clipboard.setData(ClipboardData(text: ShareLinks.https(ShareLinks.list(state.username, list.title))));
    setState(() => _inviteCopied = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final list = state.list(widget.listId);
    if (list == null) return const _NoLists();
    final items = [
      ...list.items,
    ]..sort((a, b) => (b.votes + (_voted.contains(b.id) ? 1 : 0)).compareTo(a.votes + (_voted.contains(a.id) ? 1 : 0)));

    return SheetScaffold(
      sheetTop: 296,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            leading: GlassIconButton(
              icon: AppIcon.back,
              iconSize: 20,
              semanticLabel: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            center: GlassTag(label: list.memberIds.length > 1 ? 'Collaborative list' : 'Your list'),
            trailing: GlassIconButton(
              icon: AppIcon.share,
              semanticLabel: 'Share list',
              onPressed: () => showShareSheet(context, target: ShareTarget.list),
            ),
          ),
          const SizedBox(height: 14),
          Text(list.title, style: AppText.serif(40, height: 1, color: AppColors.white)),
          const SizedBox(height: 6),
          Text(
            [Fmt.count(items.length, 'place'), if (list.planning.isNotEmpty) list.planning].join(' · '),
            style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onBlueSoft),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AvatarStack(people: [for (final id in list.memberIds) state.person(id)]),
              PillButton(
                label: _inviteCopied ? 'Link copied' : '+ Invite',
                height: 44,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                background: _inviteCopied ? AppColors.white : Colors.transparent,
                foreground: _inviteCopied ? AppColors.navy : AppColors.white,
                dashedBorder: AppColors.white,
                onPressed: () => _invite(list),
              ),
            ],
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MOST WANTED FIRST', style: AppText.sectionLabel()),
                Text(
                  'Tap +1 to vote',
                  style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            _ListItemCard(
              item: item,
              voted: _voted.contains(item.id),
              onVote: () => setState(() => _voted.contains(item.id) ? _voted.remove(item.id) : _voted.add(item.id)),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      sheetOverlays: [
        Positioned(
          left: 16,
          right: 16,
          bottom: 26,
          child: Row(
            spacing: 10,
            children: [
              Pressable(
                semanticLabel: 'See list on map',
                onTap: () {
                  context.appRead.selectTab(AppTab.map);
                  Navigator.popUntil(context, (r) => r.settings.name == Routes.home || r.isFirst);
                },
                child: DashedBorder(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const AppIconView(AppIcon.map, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  label: 'Add places',
                  icon: AppIcon.plus,
                  fontSize: 16,
                  shadow: true,
                  onPressed: () => Navigator.pushNamed(context, Routes.addPlace),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListItemCard extends StatelessWidget {
  const _ListItemCard({required this.item, required this.voted, required this.onVote});

  final CollabListItem item;
  final bool voted;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    final votes = item.votes + (voted ? 1 : 0);
    final fg = voted ? AppColors.white : AppColors.ink;
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: voted ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: voted ? Border.all(color: AppColors.ink, width: 1.5) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+1',
            style: AppText.sans(11, weight: FontWeight.w800, color: fg),
          ),
          Text(
            '$votes',
            style: AppText.sans(17, weight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                CategoryLine(category: item.category, suffix: item.status),
                Text(item.name, style: AppText.serif(19)),
                Text('Added by ${item.addedBy}', style: AppText.meta()),
              ],
            ),
          ),
          Pressable(
            semanticLabel: 'Vote for ${item.name}, $votes votes',
            onTap: onVote,
            child: voted ? box : DashedBorder(color: AppColors.subtle, radius: 18, child: box),
          ),
        ],
      ),
    );
  }
}

/// Shown when there is no list to open yet (a new account).
class _NoLists extends StatelessWidget {
  const _NoLists();

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      sheetTop: 220,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            leading: GlassIconButton(
              icon: AppIcon.back,
              iconSize: 20,
              semanticLabel: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 14),
          Text('Lists', style: AppText.serif(40, height: 1, color: AppColors.white)),
        ],
      ),
      sheet: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
        child: Column(
          spacing: 10,
          children: [
            const AppIconView(AppIcon.listCheck, size: 36, color: AppColors.blue, strokeWidth: 1.6),
            Text('No lists yet', style: AppText.sans(20, weight: FontWeight.w700)),
            Text(
              'Open a place and tap "Add to a list" to start one. Lists you make or are invited to show up here.',
              textAlign: TextAlign.center,
              style: AppText.sans(14, height: 1.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
