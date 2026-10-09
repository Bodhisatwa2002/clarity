import 'package:flutter/material.dart';
import '../shared/widgets/placeholder_screen.dart';

/// My profile — header with places visited, cities, top categories, your map,
/// badges, and a link into settings/privacy. (MVP feature: "Profile")
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Profile',
      icon: Icons.person_outline,
      message:
          'Your profile — places visited, cities, top categories, badges, '
          'and your shareable map link. Settings and privacy live here too.',
    );
  }
}
