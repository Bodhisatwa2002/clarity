import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/models/place.dart';
import '../../../core/models/place_category.dart';
import '../../../core/models/visit.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/layout.dart';
import '../../shared/widgets/chips.dart';
import '../../shared/widgets/content.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/rating.dart';

/// 08 · List view of your places, with category, rating and year filters.
class PlaceListView extends StatefulWidget {
  const PlaceListView({super.key, required this.category, required this.onCategory});

  final PlaceCategory? category;
  final ValueChanged<PlaceCategory?> onCategory;

  @override
  State<PlaceListView> createState() => _PlaceListViewState();
}

class _PlaceListViewState extends State<PlaceListView> {
  bool _ratedFourPlus = false;
  int? _year;

  void _cycleYear(List<int> years) {
    setState(() {
      if (_year == null) {
        _year = years.firstOrNull;
      } else {
        final i = years.indexOf(_year!);
        _year = i + 1 < years.length ? years[i + 1] : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final visits = state.myVisits;
    final years = visits.map((v) => v.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    final items = [
      for (final v in visits)
        if ((widget.category == null || state.place(v.placeId).category == widget.category) &&
            (!_ratedFourPlus || v.rating >= 4) &&
            (_year == null || v.date.year == _year))
          (place: state.place(v.placeId), visit: v),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        CategoryFilterBar(selected: widget.category, onChanged: widget.onCategory),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              _FilterButton(label: 'All cities', chevron: true, onTap: () {}),
              _FilterButton(
                label: 'Rated 4+',
                active: _ratedFourPlus,
                onTap: () => setState(() => _ratedFourPlus = !_ratedFourPlus),
              ),
              _FilterButton(label: _year?.toString() ?? 'Any year', chevron: true, onTap: () => _cycleYear(years)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Fmt.count(items.length, 'place'),
                style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.muted),
              ),
              Text(
                'Newest first',
                style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DashedMessageCard(
                      title: 'Nothing here yet',
                      message: 'Try another filter, or add a place.',
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                      borderColor: Color(0xFFB8C2D1),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, Layout.navClearance - 4),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => PlaceVisitCard(place: items[i].place, visit: items[i].visit),
                ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.onTap, this.active = false, this.chevron = false});

  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.white : AppColors.text;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.filter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.ink : AppColors.fieldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              label,
              style: AppText.sans(13, weight: FontWeight.w600, color: fg),
            ),
            if (chevron) AppIconView(AppIcon.chevronDown, size: 12, color: fg, strokeWidth: 2.4),
          ],
        ),
      ),
    );
  }
}

/// A row in the list view: category · status, name, meta and the tip.
class PlaceVisitCard extends StatelessWidget {
  const PlaceVisitCard({super.key, required this.place, required this.visit});

  final Place place;
  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.place, arguments: place.id),
      pressedOpacity: 0.8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
        // Intrinsic height lets the rating sit top-right and the chevron bottom-right.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    CategoryLine(category: place.category, suffix: visit.statusLabel),
                    Text(place.name, style: AppText.placeName()),
                    Text(
                      '${place.area} · ${Fmt.monthYear(visit.date)} · ${visit.companionsLabel}',
                      style: AppText.meta(),
                    ),
                    Text(
                      '“${visit.tip}”',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(13, weight: FontWeight.w400, color: AppColors.textSoft),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBadge(rating: visit.rating),
                  const AppIconView(AppIcon.chevronRight, size: 18, color: AppColors.subtle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
