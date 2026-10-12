import 'dart:ui';

/// The seven groups on the All badges screen, in display order.
enum BadgeGroup {
  gettingStarted('Getting started'),
  explorer('Explorer'),
  specialist('Specialists'),
  honestVoice('Honest voice'),
  together('Together'),
  seasons('Seasons'),
  secret('Secret');

  const BadgeGroup(this.label);
  final String label;
}

/// One badge in the catalogue (PRD BDG-1). Mirrors a row of `public.badges`.
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.group,
    required this.title,
    required this.howTo,
    required this.icon,
    required this.tone,
    required this.levels,
    this.unit,
    this.unitPlural,
    this.isSecret = false,
  });

  final String id;
  final BadgeGroup group;
  final String title;

  /// One plain sentence: what to do to earn it.
  final String howTo;

  /// Key into `BadgeIcons`.
  final String icon;

  /// Disc colour.
  final Color tone;

  /// Progress needed for level I, II, III. One entry = a single-level badge.
  final List<int> levels;

  /// What progress counts, for copy like "2 more cafés": "café" / "cafés".
  /// Null for badges that aren't a count of things (Taste twin's %).
  final String? unit;
  final String? unitPlural;
  final bool isSecret;

  bool get hasLevels => levels.length > 1;

  /// Level reached with [progress] (0 = not earned).
  int levelFor(int progress) => levels.where((t) => t <= progress).length;

  String units(int n) => n == 1 ? (unit ?? '') : (unitPlural ?? unit ?? '');
}

/// Five ways a badge is drawn (PRD BDG-4).
enum BadgeState { earned, fresh, progress, locked, secret }

/// What the server has stored for one person's badge (`public.user_badges`,
/// or a `my_badges()` row).
class BadgeRecord {
  const BadgeRecord({
    required this.badgeId,
    required this.level,
    this.progress = 0,
    this.earnedAt,
    this.leveledAt,
    this.seenLevel = 0,
  });

  final String badgeId;
  final int level;
  final int progress;
  final DateTime? earnedAt;
  final DateTime? leveledAt;

  /// Level whose celebration has been shown.
  final int seenLevel;
}

/// A friend's Congrats on someone's badge (`public.badge_congrats`).
class BadgeCongrats {
  const BadgeCongrats({required this.ownerId, required this.badgeId, required this.fromId});

  final String ownerId;
  final String badgeId;
  final String fromId;
}

/// A badge as one person has it: the definition plus their progress.
class BadgeProgress {
  const BadgeProgress({
    required this.def,
    required this.progress,
    required this.level,
    this.seenLevel = 0,
    this.earnedAt,
    this.leveledAt,
    this.placeIds = const [],
  });

  final BadgeDef def;
  final int progress;
  final int level;
  final int seenLevel;
  final DateTime? earnedAt;
  final DateTime? leveledAt;

  /// The places that counted, newest first (place badges only).
  final List<String> placeIds;

  String get id => def.id;
  bool get earned => level > 0;
  bool get isNew => level > seenLevel;
  bool get maxed => level >= def.levels.length;

  /// Threshold of the next level, or null when every level is done.
  int? get nextThreshold => maxed ? null : def.levels[level];

  /// How far to the next level, 0–1.
  double get fraction {
    final next = nextThreshold;
    if (next == null) return 1;
    final from = level == 0 ? 0 : def.levels[level - 1];
    return ((progress - from) / (next - from)).clamp(0, 1).toDouble();
  }

  int get remaining => (nextThreshold ?? progress) - progress;

  BadgeState get state {
    if (earned) return isNew ? BadgeState.fresh : BadgeState.earned;
    if (def.isSecret) return BadgeState.secret;
    return progress > 0 ? BadgeState.progress : BadgeState.locked;
  }

  /// "I", "II", "III" — empty for single-level badges.
  String get roman => def.hasLevels && level > 0 ? const ['I', 'II', 'III'][level - 1] : '';

  /// "Trekker II", "First pin".
  String get titleWithLevel => roman.isEmpty ? def.title : '${def.title} $roman';

  /// The next level's name: "Trekker III", "Café hopper I".
  String get nextTitle {
    if (!def.hasLevels) return def.title;
    return '${def.title} ${const ['I', 'II', 'III'][level.clamp(0, 2)]}';
  }

  /// "3 of 5", "86%", "Done".
  String get progressLabel {
    final next = nextThreshold;
    if (def.unit == null) return '$progress%';
    if (next == null) return '$progress ${def.units(progress)}';
    return '$progress of $next';
  }

  /// "2 more cafés to Café hopper II"; null when there's nothing left.
  String? get nextStep {
    final next = nextThreshold;
    if (next == null) return null;
    if (def.unit == null) return 'Reach $next% to unlock ${def.title}';
    return '$remaining more ${def.units(remaining)} to $nextTitle';
  }
}
