import 'package:flutter/material.dart';
import '../shared/widgets/placeholder_screen.dart';

/// Home / My Map — the main screen. Will show your pins color-coded by
/// category, with a map <-> list toggle. (MVP feature: "Your map")
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'My Map',
      icon: Icons.map_outlined,
      message:
          'Your personal map of every place you\'ve been will live here — '
          'pins color-coded by category, with a list view and filters.',
    );
  }
}
