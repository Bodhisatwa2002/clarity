/// How a person relates to a place.
enum VisitStatus {
  visited('Visited'),
  wantToGo('Want to go'),
  notRecommended('Not recommended');

  const VisitStatus(this.label);
  final String label;
}

/// One person's experience of one [Place] — rating, tip, review, photos.
///
/// Kept separate from the place itself so the same place can carry many
/// visits (yours, friends', revisits) and verified visits later.
class Visit {
  const Visit({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.date,
    this.status = VisitStatus.visited,
    this.rating = 0,
    this.tip = '',
    this.text = '',
    this.companions = const [],
    this.tags = const [],
    this.budget,
    this.photoCount = 0,
    this.verified = false,
  });

  final String id;
  final String placeId;
  final String authorId;
  final DateTime date;
  final VisitStatus status;

  /// 0–5 in half steps; 0 means not rated.
  final double rating;

  /// The required "one thing to know".
  final String tip;
  final String text;

  /// Free-form "with" labels: friend first names, "family" or "solo".
  final List<String> companions;
  final List<String> tags;
  final String? budget;
  final int photoCount;
  final bool verified;

  /// "with Rahul", "solo", "with family".
  String get companionsLabel {
    if (companions.isEmpty) return 'solo';
    if (companions.length == 1 && companions.first == 'solo') return 'solo';
    return 'with ${companions.join(', ')}';
  }
}
