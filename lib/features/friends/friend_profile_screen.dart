import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place_category.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../share/share_sheet.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/chips.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/map_art.dart';
import '../shared/widgets/pressable.dart';
import '../shared/widgets/rating.dart';

/// 15 · A friend's profile: stats, their map and recent visits.
class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final person = state.person(personId);
    final isFriend = state.isFriend(personId);
    final requested = state.isRequested(personId);
    final visits = state.visitsBy(personId);
    final topCategories =
        MockData.topCategoriesByPerson[personId] ?? const [(PlaceCategory.food, 6), (PlaceCategory.viewpoint, 4)];

    return SheetScaffold(
      sheetTop: 386,
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
            trailing: GlassIconButton(
              icon: AppIcon.share,
              semanticLabel: "Share ${person.firstName}'s map",
              onPressed: () => showShareSheet(context, target: ShareTarget.map),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            spacing: 16,
            children: [
              GlassOrb(
                size: 88,
                child: Text(
                  person.initials,
                  style: AppText.sans(30, weight: FontWeight.w800, letterSpacing: -1, color: AppColors.white),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(person.name, style: AppText.serif(30, height: 1.05, color: AppColors.white)),
                    Text(
                      [person.handle, ?person.city].where((s) => s.isNotEmpty).join(' · '),
                      style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onBlueSoft),
                    ),
                    if (person.note != null)
                      Text(
                        person.note!,
                        style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.onBlueSoft),
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
              Expanded(
                child: GlassStatTile(value: '${person.placesCount}', label: 'PLACES', height: 62),
              ),
              Expanded(
                child: GlassStatTile(value: '${person.citiesCount}', label: 'CITIES', height: 62),
              ),
              Expanded(
                child: GlassStatTile(
                  value: '${person.tasteMatch ?? 0}%',
                  label: 'TASTE MATCH',
                  height: 62,
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FriendButton(
            isFriend: isFriend,
            requested: requested,
            onTap: () => isFriend ? state.toggleFriend(personId) : state.toggleRequest(personId),
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          Row(
            children: [
              Expanded(
                child: AccentTitle(
                  lead: "${person.firstName}'s ",
                  accent: 'map',
                  size: 20,
                  accentSize: 20,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                ),
              ),
              for (final (category, count) in topCategories) ...[
                const SizedBox(width: 6),
                TagChip(
                  label: '${category.label} $count',
                  dotColor: category.color,
                  height: 30,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.mapLand, borderRadius: BorderRadius.circular(24)),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: FittedBox(fit: BoxFit.cover, child: MapArtView(MapArt.friend)),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: PillButton(
                    label: 'Open full map',
                    height: 36,
                    fontWeight: FontWeight.w700,
                    onPressed: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("${person.firstName}'s full map arrives with Google Maps."))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionLabel('RECENT VISITS'),
          const SizedBox(height: 14),
          if (visits.isEmpty)
            DashedMessageCard(
              title: 'No public reviews yet',
              message: '${person.firstName} hasn’t shared any places with you.',
            ),
          for (final v in visits) ...[
            _RecentVisitCard(
              placeId: v.placeId,
              when: Fmt.relative(v.date),
              rating: v.rating,
              tip: v.tip,
              youToo: state.myVisitFor(v.placeId) != null,
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _FriendButton extends StatelessWidget {
  const _FriendButton({required this.isFriend, required this.requested, required this.onTap});

  final bool isFriend;
  final bool requested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isFriend ? 'Friends' : (requested ? 'Requested' : 'Add friend');
    final filled = !isFriend && !requested;
    return PillButton(
      label: label,
      height: 46,
      fontSize: 15,
      expand: true,
      background: filled ? AppColors.white : Colors.transparent,
      foreground: filled ? AppColors.navy : AppColors.white,
      dashedBorder: filled ? null : AppColors.white,
      solidBorder: filled ? AppColors.white : null,
      onPressed: onTap,
    );
  }
}

class _RecentVisitCard extends StatelessWidget {
  const _RecentVisitCard({
    required this.placeId,
    required this.when,
    required this.rating,
    required this.tip,
    required this.youToo,
  });

  final String placeId;
  final String when;
  final double rating;
  final String tip;
  final bool youToo;

  @override
  Widget build(BuildContext context) {
    final place = context.app.place(placeId);
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.place, arguments: placeId),
      pressedOpacity: 0.8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryLine(category: place.category, label: '${place.category.label} · $when'),
                RatingBadge(rating: rating, fontSize: 14, starSize: 13),
              ],
            ),
            Text(place.name, style: AppText.placeName()),
            Text(
              '“$tip”',
              style: AppText.sans(13, weight: FontWeight.w400, color: AppColors.textSoft),
            ),
            if (youToo)
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: AppColors.tintStrong, borderRadius: BorderRadius.circular(13)),
                alignment: Alignment.center,
                child: Text(
                  "You've been here too",
                  style: AppText.sans(11, weight: FontWeight.w800, color: AppColors.navy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
