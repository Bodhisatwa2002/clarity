/// One person's review of one [Place] they actually went to — rating, tip,
/// review, photos, budget.
///
/// Kept separate from the place itself so the same place can carry many
/// visits (yours, friends', revisits) and verified visits later. "Want to go"
/// is not a visit: it's a save (`AppState.toggleSaved`).
class Visit {
  const Visit({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.date,
    this.recommended = true,
    this.rating = 0,
    this.tip = '',
    this.text = '',
    this.companions = const [],
    this.tags = const [],
    this.budgetPerPerson,
    this.photoCount = 0,
    this.verified = false,
  });

  final String id;
  final String placeId;
  final String authorId;
  final DateTime date;

  /// "Would you recommend it?" — false shows as Not recommended.
  final bool recommended;

  /// 1–5 (0 only while a review is being written).
  final double rating;

  /// The required "one thing to know".
  final String tip;
  final String text;

  /// Free-form "with" labels: friend first names, "family" or "solo".
  final List<String> companions;

  /// Built-in quick tags plus any the reviewer typed.
  final List<String> tags;

  /// What it cost per person, in whole rupees.
  final int? budgetPerPerson;
  final int photoCount;
  final bool verified;

  /// Up to this many tags per visit, each up to [maxTagLength] characters
  /// (the database enforces the same).
  static const int maxTags = 10;
  static const int maxTagLength = 24;

  /// "Visited" or "Not recommended".
  String get statusLabel => recommended ? 'Visited' : 'Not recommended';

  /// "₹" to "₹₹₹₹", worked out from [budgetPerPerson].
  String? get budgetLevel => budgetLevelFor(budgetPerPerson);

  /// "₹₹ · ₹350 per person", or "Free".
  String? get budgetLabel => switch (budgetPerPerson) {
    null => null,
    0 => 'Free',
    final amount => '${budgetLevelFor(amount)} · ₹$amount per person',
  };

  /// Price levels per person: under ₹250, under ₹750, under ₹2,000, above.
  static String? budgetLevelFor(int? amount) => switch (amount) {
    null || 0 => null,
    < 250 => '₹',
    < 750 => '₹₹',
    < 2000 => '₹₹₹',
    _ => '₹₹₹₹',
  };

  /// "with Rahul", "solo", "with family".
  String get companionsLabel {
    if (companions.isEmpty) return 'solo';
    if (companions.length == 1 && companions.first == 'solo') return 'solo';
    return 'with ${companions.join(', ')}';
  }
}
