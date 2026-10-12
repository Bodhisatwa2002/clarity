import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/models/badge.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/content.dart';
import 'badge_share_sheet.dart';
import 'widgets/badge_emblem.dart';
import 'widgets/badge_stamp.dart';

/// Opens the badge detail sheet (PRD BDG-9, design board 32). With
/// [personId], shows that friend's badge instead of yours.
Future<void> showBadgeDetail(BuildContext context, String badgeId, {String? personId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => BadgeDetailSheet(badgeId: badgeId, personId: personId),
  );
}

class BadgeDetailSheet extends StatefulWidget {
  const BadgeDetailSheet({super.key, required this.badgeId, this.personId});

  final String badgeId;
  final String? personId;

  @override
  State<BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<BadgeDetailSheet> {
  bool _allPlaces = false;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final mine = widget.personId == null || widget.personId == state.me.id;
    final badge = mine
        ? state.badge(widget.badgeId)
        : state.badgesOf(widget.personId!).where((b) => b.id == widget.badgeId).firstOrNull ??
              state.badge(widget.badgeId);
    final secret = badge.state == BadgeState.secret;
    final friends = state.friendsWithBadge(badge.id).where((id) => id != widget.personId).toList();
    final places = _allPlaces ? badge.placeIds : badge.placeIds.take(4).toList();
    // Specialist badges count their own kind ("cafés"); the rest count places.
    final unit = badge.def.group == BadgeGroup.specialist ? badge.def.unitPlural : null;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 18),
              // Earned badges show as a passport stamp here, with the place
              // and month that earned them (design board 27).
              Center(
                child: badge.earned && !secret
                    ? BadgeStamp(
                        badge: badge,
                        caption: stampCaption(
                          badge.placeIds.isEmpty ? null : state.place(badge.placeIds.first).name,
                          badge,
                        ),
                        size: 168,
                      )
                    : BadgeEmblem(badge: badge, size: 120),
              ),
              const SizedBox(height: 12),
              Text(
                secret ? 'Secret badge' : badge.def.title,
                textAlign: TextAlign.center,
                style: AppText.serif(30, height: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                _statusLine(badge, mine ? null : state.person(widget.personId!).firstName),
                textAlign: TextAlign.center,
                style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Text(
                secret ? 'Keep exploring. This one shows itself when you find it.' : badge.def.howTo,
                textAlign: TextAlign.center,
                style: AppText.sans(15, height: 1.5, color: AppColors.text),
              ),
              if (!secret && mine) ...[const SizedBox(height: 20), _LevelTrack(badge: badge)],
              if (places.isNotEmpty && !secret) ...[
                const SizedBox(height: 20),
                Text(
                  '${badge.placeIds.length} ${(unit ?? (badge.placeIds.length == 1 ? 'place' : 'places')).toUpperCase()} THAT COUNTED',
                  style: AppText.sectionLabel(),
                ),
                const SizedBox(height: 8),
                for (final id in places) _CountedPlace(placeId: id),
                if (badge.placeIds.length > 4 && !_allPlaces)
                  TextLinkButton(
                    label: 'Show ${badge.placeIds.length - 4} more',
                    fontSize: 14,
                    height: 40,
                    onPressed: () => setState(() => _allPlaces = true),
                  ),
              ],
              if (friends.isNotEmpty && !secret) ...[
                const SizedBox(height: 16),
                SoftCardRow(
                  leading: AvatarStack(people: [for (final id in friends.take(3)) state.person(id)], size: 32),
                  text: friends.length == 1
                      ? '${state.person(friends.single).firstName} has this too'
                      : '${friends.length} friends have this',
                ),
              ],
              const SizedBox(height: 20),
              if (mine && badge.earned) ...[
                PrimaryButton(label: 'Share badge', onPressed: () => showBadgeShareSheet(context, badge.id)),
                if (badge.placeIds.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  DashedButton(
                    label: unit == null ? 'See them on my map' : 'See $unit on my map',
                    expand: true,
                    onPressed: () => Navigator.of(context).popUntil((r) => r.settings.name == Routes.home || r.isFirst),
                  ),
                ],
              ] else
                PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLine(BadgeProgress b, String? owner) {
    final who = owner == null ? '' : '$owner · ';
    if (b.state == BadgeState.secret) return 'Not found yet';
    if (!b.earned) return '${who}In progress · ${b.progressLabel}';
    final level = b.def.hasLevels ? 'Level ${b.roman} · ' : '';
    final date = b.earnedAt == null ? 'earned' : 'earned ${Fmt.dayMonthYear(b.earnedAt!)}';
    return '$who$level$date';
  }
}

/// I — II — III with thresholds and how far you are (board 32, "LEVELS").
class _LevelTrack extends StatelessWidget {
  const _LevelTrack({required this.badge});

  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    final def = badge.def;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(child: Text(def.hasLevels ? 'LEVELS' : 'PROGRESS', style: AppText.sectionLabel())),
              Text(
                badge.nextStep ?? 'All done',
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.slate),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: badge.maxed ? 1 : _overall(badge),
              minHeight: 8,
              backgroundColor: AppColors.badgeTrack,
              valueColor: const AlwaysStoppedAnimation(AppColors.mint),
            ),
          ),
          if (def.hasLevels)
            Row(
              children: [
                for (var i = 0; i < def.levels.length; i++)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: i == 0
                          ? CrossAxisAlignment.start
                          : i == def.levels.length - 1
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                      spacing: 2,
                      children: [
                        Text(
                          const ['I', 'II', 'III'][i],
                          style: AppText.sans(
                            13,
                            weight: FontWeight.w800,
                            color: badge.level > i ? AppColors.ink : AppColors.subtle,
                          ),
                        ),
                        Text(
                          '${def.levels[i]} ${def.units(def.levels[i])}',
                          style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Progress along the whole track, so level II sits two-thirds along.
  static double _overall(BadgeProgress b) {
    final top = b.def.levels.last;
    return (b.progress / top).clamp(0, 1).toDouble();
  }
}

class _CountedPlace extends StatelessWidget {
  const _CountedPlace({required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final place = state.place(placeId);
    final visit = state.myVisitFor(placeId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ChevronRow(
        title: place.name,
        subtitle: [place.city ?? place.area, if (visit != null) Fmt.monthYear(visit.date)].join(' · '),
        titleStyle: AppText.placeName(size: 17),
        onTap: () => Navigator.pushNamed(context, Routes.place, arguments: placeId),
      ),
    );
  }
}

/// A soft card row with something on the left and one line of text.
class SoftCardRow extends StatelessWidget {
  const SoftCardRow({super.key, required this.leading, required this.text});

  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(18)),
      child: Row(
        spacing: 12,
        children: [
          leading,
          Expanded(
            child: Text(
              text,
              style: AppText.sans(14, weight: FontWeight.w700, color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
