import 'package:flutter/material.dart';

import '../../core/models/place_category.dart';
import '../../core/state/app_state.dart';
import 'widgets/empty_map_view.dart';
import 'widgets/home_header.dart';
import 'widgets/map_view.dart';
import 'widgets/place_list_view.dart';
import '../shared/widgets/layout.dart';

/// Tab 1 · My Map (07 map, 08 list, 23a empty).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showList = false;
  PlaceCategory? _category;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    if (!state.hasPlaces) return const EmptyMapView();

    return SheetScaffold(
      sheetTop: 196,
      headerPadding: const EdgeInsets.symmetric(horizontal: 22),
      sheetColor: _showList ? Colors.white : const Color(0xFFEEF3F9),
      header: HomeHeader(
        greeting: 'Hi, ${state.firstName}',
        summary: state.mapSummary,
        showList: _showList,
        onToggle: (list) => setState(() => _showList = list),
      ),
      sheet: _showList
          ? PlaceListView(category: _category, onCategory: (c) => setState(() => _category = c))
          : MapView(category: _category, onCategory: (c) => setState(() => _category = c)),
    );
  }
}
