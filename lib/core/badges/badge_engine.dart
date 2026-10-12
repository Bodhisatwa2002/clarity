import '../models/place.dart';
import '../models/place_category.dart';
import '../models/social.dart';
import '../models/visit.dart';
import 'badge_catalog.dart';
import 'festivals.dart';

/// Progress toward one badge, plus the places that counted.
class BadgeCount {
  const BadgeCount(this.progress, [this.placeIds = const []]);

  final int progress;
  final List<String> placeIds;
}

/// The badge rules in Dart: the same counts as `private.badge_progress` in
/// supabase/schemas/09_badges.sql. The app uses them to celebrate an unlock
/// the moment it happens; the database still decides what is stored. Keep
/// the two in step.
abstract final class BadgeEngine {
  /// Counts for every badge for the person whose visits are [mine].
  ///
  /// [friendVisits] are the visits of that person's friends (for Taste twin
  /// and Hidden gem), and [friendsWhoWent] how many friends said "Thanks,
  /// went there!" on them (Trusted voice). Badges the app can't count (Tip
  /// master needs other people's saves) come back as 0 and use the server's
  /// number.
  static Map<String, BadgeCount> count({
    required String personId,
    required List<Visit> mine,
    required Place Function(String id) place,
    List<Visit> friendVisits = const [],
    int friendCount = 0,
    List<CollabList> lists = const [],
    bool mapShared = false,
    int friendsWhoWent = 0,
  }) {
    // Newest first, so the "places that counted" list leads with the latest.
    final visits = List.of(mine)..sort((a, b) => b.date.compareTo(a.date));
    final placeIds = <String>[];
    for (final v in visits) {
      if (!placeIds.contains(v.placeId)) placeIds.add(v.placeId);
    }

    List<String> placesWhere(bool Function(Place p) test) => placeIds.where((id) => test(place(id))).toList();
    BadgeCount places(List<String> ids) => BadgeCount(ids.length, ids);

    final cities = <String>{for (final id in placeIds) ?_city(place(id))};
    final states = <String>{for (final id in placeIds) ?place(id).state};

    final perPlace = <String, int>{};
    for (final v in visits) {
      perPlace[v.placeId] = (perPlace[v.placeId] ?? 0) + 1;
    }

    final counts = <String, BadgeCount>{
      'first_pin': places(placeIds),
      'one_thing': BadgeCount(visits.where((v) => v.tip.trim().isNotEmpty).length),
      'first_friend': BadgeCount(friendCount),
      'list_maker': BadgeCount(lists.where((l) => l.ownerId == personId).length),
      'map_sharer': BadgeCount(mapShared ? 1 : 0),
      'places': places(placeIds),
      'cities': BadgeCount(cities.length, placeIds),
      'states': BadgeCount(states.length, placeIds.where((id) => place(id).state != null).toList()),
      'seven_sisters': BadgeCount(
        states.where(BadgeCatalog.northEast.contains).length,
        placesWhere((p) => BadgeCatalog.northEast.contains(p.state)),
      ),
      'straight_talker': BadgeCount(visits.where((v) => !v.recommended).length, [
        for (final v in visits.where((v) => !v.recommended)) v.placeId,
      ]),
      'tip_master': const BadgeCount(0),
      'trusted_voice': BadgeCount(friendsWhoWent),
      'been_there': places({for (final v in visits.where((v) => v.verified)) v.placeId}.toList()),
      'festival_lights': places(
        {for (final v in visits.where((v) => Festivals.on(v.date) != null)) v.placeId}.toList(),
      ),
      'taste_twin': BadgeCount(_bestTasteMatch(visits, friendVisits)),
      'squad_explorer': BadgeCount(
        lists
            .where((l) => l.memberIds.contains(personId))
            .fold(0, (best, l) => l.memberIds.length - 1 > best ? l.memberIds.length - 1 : best),
      ),
      'regular': BadgeCount(perPlace.values.fold(0, (a, b) => b > a ? b : a)),
      'monsoon_wanderer': BadgeCount(
        visits.where((v) => v.date.month >= 6 && v.date.month <= 9).length,
        {for (final v in visits.where((v) => v.date.month >= 6 && v.date.month <= 9)) v.placeId}.toList(),
      ),
      'winter_hills': BadgeCount(
        visits.where((v) => _winter(v) && _hillsy(place(v.placeId).category)).length,
        {for (final v in visits.where((v) => _winter(v) && _hillsy(place(v.placeId).category))) v.placeId}.toList(),
      ),
      'hidden_gem': places(_hiddenGems(visits, friendVisits)),
    };
    for (final c in PlaceCategory.values) {
      final id = BadgeCatalog.specialistFor(c);
      if (id != null) counts[id] = places(placesWhere((p) => p.category == c));
    }
    return counts;
  }

  static String? _city(Place p) => p.city ?? (p.area.isEmpty ? null : p.area);

  static bool _winter(Visit v) => v.date.month == 12 || v.date.month <= 2;

  static bool _hillsy(PlaceCategory c) => c == PlaceCategory.trek || c == PlaceCategory.viewpoint;

  /// 100 minus 20 points per star of average gap, over every pair of your
  /// visit and a friend's visit to the same place; friends with 2+ shared
  /// places only. Same formula as `profile_summaries`.
  static int _bestTasteMatch(List<Visit> mine, List<Visit> friends) {
    final byFriend = <String, List<Visit>>{};
    for (final v in friends) {
      (byFriend[v.authorId] ??= []).add(v);
    }
    var best = 0;
    for (final theirs in byFriend.values) {
      final gaps = <double>[];
      final shared = <String>{};
      for (final a in mine) {
        for (final b in theirs.where((b) => b.placeId == a.placeId)) {
          gaps.add((a.rating - b.rating).abs());
          shared.add(a.placeId);
        }
      }
      if (shared.length < 2) continue;
      final avg = gaps.reduce((x, y) => x + y) / gaps.length;
      final match = (100 - avg * 20).clamp(0, 100).round();
      if (match > best) best = match;
    }
    return best;
  }

  /// Places you reviewed before any friend did, where a friend went after.
  static List<String> _hiddenGems(List<Visit> mine, List<Visit> friends) {
    final first = <String, DateTime>{};
    for (final v in mine) {
      final d = first[v.placeId];
      if (d == null || v.date.isBefore(d)) first[v.placeId] = v.date;
    }
    return [
      for (final MapEntry(key: placeId, value: firstOn) in first.entries)
        if (friends.any((f) => f.placeId == placeId) &&
            !friends.any((f) => f.placeId == placeId && !_day(f.date).isAfter(_day(firstOn))))
          placeId,
    ];
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
