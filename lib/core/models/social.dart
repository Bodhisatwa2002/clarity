import 'place_category.dart';

/// The three shapes a friends-feed card can take.
enum FeedPostType { visit, ask, list }

class FeedPost {
  const FeedPost({
    required this.id,
    required this.type,
    required this.authorId,
    required this.verb,
    required this.subject,
    required this.when,
    required this.quote,
    required this.likes,
    this.placeId,
    this.category,
    this.rating,
    this.footnote,
  });

  final String id;
  final FeedPostType type;
  final String authorId;

  /// "visited", "is going to", "added 3 places to".
  final String verb;

  /// The bold object of the sentence — a place, city or list name.
  final String subject;
  final String when;
  final String quote;
  final int likes;
  final String? placeId;
  final PlaceCategory? category;
  final double? rating;

  /// "4 friends replied with pins" / "9 places · 4 friends".
  final String? footnote;
}

enum NotificationKind { joined, friendRequest, liked, thanks, nudge, listInvite }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.who,
    required this.text,
    required this.when,
    required this.initials,
    this.personId,
    this.cta,
    this.isToday = true,
    this.unread = false,
  });

  final String id;
  final NotificationKind kind;
  final String who;
  final String text;
  final String when;
  final String initials;
  final String? personId;
  final String? cta;
  final bool isToday;
  final bool unread;
}

/// A shared trip/wishlist that friends vote on.
class CollabList {
  const CollabList({
    required this.id,
    required this.title,
    required this.planning,
    required this.memberIds,
    required this.items,
  });

  final String id;
  final String title;

  /// "planning for Jan 2027".
  final String planning;
  final List<String> memberIds;
  final List<CollabListItem> items;
}

class CollabListItem {
  const CollabListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.addedBy,
    required this.votes,
    this.placeId,
  });

  final String id;
  final String name;
  final PlaceCategory category;

  /// "Want to go", "Rahul visited".
  final String status;
  final String addedBy;
  final int votes;
  final String? placeId;
}
