import 'package:flutter/material.dart';
import '../shared/widgets/placeholder_screen.dart';

/// Friends — find friends from contacts (the core hook), friend requests,
/// and friends' profiles. (MVP feature: "Contact sync")
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Friends',
      icon: Icons.people_outline,
      message:
          'Find friends from your contacts — see who\'s already here and '
          'open their map. This is the app\'s core hook.',
    );
  }
}
