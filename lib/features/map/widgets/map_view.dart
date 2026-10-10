import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/models/place.dart';
import '../../../core/models/place_category.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/chips.dart';
import '../../shared/widgets/map_art.dart';
import '../../shared/widgets/pressable.dart';
import 'place_preview_card.dart';

/// The home map: your pins on an illustrated map, a category filter and a
/// preview card for the selected pin.
class MapView extends StatefulWidget {
  const MapView({super.key, required this.category, required this.onCategory});

  final PlaceCategory? category;
  final ValueChanged<PlaceCategory?> onCategory;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  String? _selectedId = 'neermahal';

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final pins = [
      for (final v in state.myVisits)
        if (widget.category == null || state.place(v.placeId).category == widget.category)
          (place: state.place(v.placeId), visit: v),
    ].where((p) => p.place.mapPosition != null).toList();

    final selected = pins.where((p) => p.place.id == _selectedId).firstOrNull ?? pins.firstOrNull;

    return Stack(
      children: [
        // The map and its pins scale together to cover the sheet.
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
              size: MapArt.home.size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const MapArtView(MapArt.home),
                  ..._labels,
                  const Positioned(left: 128, top: 262, child: YouAreHereDot()),
                  for (final p in pins)
                    if (p != selected) _pin(p.place, selected: false),
                  if (selected != null) _pin(selected.place, selected: true),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 16,
          child: CategoryFilterBar(selected: widget.category, onChanged: widget.onCategory),
        ),
        Positioned(
          right: 16,
          bottom: 286,
          child: Pressable(
            semanticLabel: 'Center on my location',
            onTap: () => setState(() => _selectedId = pins.firstOrNull?.place.id),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: AppShadows.floating),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.navigate, size: 19, color: AppColors.blue),
            ),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 108,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: PlacePreviewCard(
                key: ValueKey(selected.place.id),
                place: selected.place,
                visit: selected.visit,
                onTap: () => Navigator.pushNamed(context, Routes.place, arguments: selected.place.id),
              ),
            ),
          ),
      ],
    );
  }

  Widget _pin(Place place, {required bool selected}) {
    final pos = place.mapPosition!;
    final marker = MapPinMarker(color: place.category.color, selected: selected);
    return Positioned(
      left: pos.dx - (selected ? 26 : 22),
      top: pos.dy - (selected ? 56 : 40),
      child: Pressable(
        semanticLabel: selected ? '${place.name}, selected' : place.name,
        onTap: () => setState(() => _selectedId = place.id),
        pressedOpacity: 0.8,
        child: selected
            ? marker
            : SizedBox(
                width: 44,
                height: 44,
                child: Align(alignment: Alignment.bottomCenter, child: marker),
              ),
      ),
    );
  }

  static final List<Widget> _labels = [
    _label(262, 282, 'Rudrasagar Lake', 10, FontWeight.w600, AppColors.mapLabelWater),
    _label(30, 118, 'Heritage Park', 10, FontWeight.w600, AppColors.mapLabelPark),
    _label(176, 189, 'AGARTALA', 11, FontWeight.w700, AppColors.mapLabelCity, spacing: 2),
  ];

  static Widget _label(
    double x,
    double y,
    String text,
    double size,
    FontWeight weight,
    Color color, {
    double spacing = 0,
  }) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        text,
        style: AppText.sans(size, weight: weight, color: color, letterSpacing: spacing),
      ),
    );
  }
}
