import 'package:flutter/material.dart';
import '../shared/widgets/placeholder_screen.dart';

/// Friends feed — chronological list of friends' recent visits.
/// No algorithm, newest first. (MVP feature: "Friends feed")
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Feed',
      icon: Icons.dynamic_feed_outlined,
      message:
          'A chronological feed of where your friends have been — '
          '"Rahul visited Dzükou Valley, 5/5". No algorithm.',
    );
  }
}
