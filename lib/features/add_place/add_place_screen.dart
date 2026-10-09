import 'package:flutter/material.dart';
import '../shared/widgets/placeholder_screen.dart';

/// Add a place — search via Google Places, "I'm here" via GPS, or drop a pin.
/// Then write a review. (MVP features: "Add a place" + "Write a review")
class AddPlaceScreen extends StatelessWidget {
  const AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Add a Place',
      icon: Icons.add_location_alt_outlined,
      message:
          'Search for a place, use "I\'m here" with GPS, or drop a pin — '
          'then rate it, add photos, and write your review.',
    );
  }
}
