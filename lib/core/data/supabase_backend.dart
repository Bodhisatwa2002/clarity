import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/badge.dart';
import '../models/person.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/social.dart';
import '../models/visit.dart';
import '../utils/formatters.dart';
import 'backend.dart';

/// [Backend] on Supabase: Auth for phone OTP, the Data API for tables, RPCs
/// for the feed and stats. Every query runs as the signed-in user, so
/// row-level security decides what comes back (supabase/schemas/).
class SupabaseBackend implements Backend {
  SupabaseBackend(this._db);

  final SupabaseClient _db;

  /// Lake Road, Agartala: stands in for the phone's location ("I'm here",
  /// dropped pins) until Core Location is wired.
  static const double demoLat = 23.8361;
  static const double demoLng = 91.2832;

  String get _uid => _db.auth.currentUser!.id;

  @override
  bool get isRemote => true;

  @override
  bool get isSignedIn => _db.auth.currentSession != null;

  // ── Auth ────────────────────────────────────────────────────────────────

  @override
  Future<void> sendCode(String phone) => _db.auth.signInWithOtp(phone: phone);

  @override
  Future<void> verifyCode(String phone, String code) async {
    await _db.auth.verifyOTP(phone: phone, token: code, type: OtpType.sms);
  }

  @override
  Future<void> signOut() => _db.auth.signOut();

  @override
  Future<void> deleteAccount() async {
    await _db.rpc<void>('delete_my_account');
    await _db.auth.signOut();
  }

  // ── Reads ───────────────────────────────────────────────────────────────

  @override
  Future<AppSnapshot> load() async {
    final uid = _uid;
    final r = await Future.wait<dynamic>([
      _db.from('profiles').select(),
      _db.from('places').select('id, name, category, lat, lng, area, address, city, state'),
      _db.from('visits').select('*, visit_photos(count)').order('visited_on', ascending: false),
      _db.from('friendships').select(),
      _db.from('saved_places').select('place_id'),
      _db.from('notifications').select().order('created_at', ascending: false).limit(50),
      _db
          .from('lists')
          .select(
            'id, title, planning_note, owner_id, list_members(profile_id), '
            'list_items(id, place_id, added_by, created_at, list_item_votes(count))',
          )
          .order('created_at', ascending: false),
      _db.rpc<List<dynamic>>('get_feed'),
      _db.rpc<List<dynamic>>('nearby_places', params: {'at_lat': demoLat, 'at_lng': demoLng, 'radius_m': 1000}),
      _db.rpc<List<dynamic>>('my_badges'),
      _db
          .from('user_badges')
          .select('profile_id, badge_id, level, progress, earned_at, leveled_at')
          .neq('profile_id', uid),
      _db.from('badge_congrats').select('owner_id, badge_id, from_id'),
      _db.from('visit_thanks').select('visit_id, profile_id'),
    ]);

    final profileRows = _rows(r[0]);
    final summaries = {
      for (final s in _rows(
        await _db.rpc<List<dynamic>>('profile_summaries', params: {'ids': profileRows.map((p) => p['id']).toList()}),
      ))
        s['profile_id'] as String: s,
    };
    final people = [for (final p in profileRows) _person(p, summaries[p['id']])];
    final byId = {for (final p in people) p.id: p};
    final meRow = profileRows.where((p) => p['id'] == uid).firstOrNull;
    final me =
        byId[uid] ?? Person(id: uid, name: '', initials: '', avatarBg: _hex('#F2F7FF'), avatarFg: _hex('#1D4E9E'));

    final places = [for (final p in _rows(r[1])) _place(p)];
    final placesById = {for (final p in places) p.id: p};
    final visits = [for (final v in _rows(r[2])) _visit(v)];

    final friendIds = <String>[], requestIds = <String>[], sentIds = <String>[];
    for (final f in _rows(r[3])) {
      final requester = f['requester_id'] as String, addressee = f['addressee_id'] as String;
      final other = requester == uid ? addressee : requester;
      if (f['status'] == 'accepted') {
        friendIds.add(other);
      } else if (requester == uid) {
        sentIds.add(other);
      } else {
        requestIds.add(other);
      }
    }
    final others = people.where((p) => p.id != uid).map((p) => p.id).toList();

    return AppSnapshot(
      me: me,
      hasProfile: meRow != null,
      people: people,
      places: places,
      myVisits: visits.where((v) => v.authorId == uid).toList(),
      otherVisits: visits.where((v) => v.authorId != uid).toList(),
      friendIds: friendIds,
      requestIds: requestIds,
      sentRequestIds: sentIds,
      savedPlaceIds: {for (final s in _rows(r[4])) s['place_id'] as String},
      feed: [for (final f in _rows(r[7])) _feedPost(f)],
      notifications: [for (final n in _rows(r[5])) _notification(n, byId)],
      lists: [for (final l in _rows(r[6])) _list(l, uid, byId, placesById, visits)],
      // Until contact sync is wired (roadmap step 8), "Find friends" lists
      // everyone else on the project — fine for seeded staging data only.
      contactsOnClarity: others,
      suggestedPeopleIds: others.where((id) => !friendIds.contains(id)).toList(),
      addPlaceSuggestionIds: (List.of(places)..sort((a, b) => a.name.compareTo(b.name))).map((p) => p.id).toList(),
      nearbyHere: [
        for (final n in _rows(r[8]).take(3))
          (placeId: n['place_id'] as String, distance: _distance((n['distance_m'] as num).toDouble())),
      ],
      badgeRecords: [for (final b in _rows(r[9])) _badgeRecord(b)],
      friendBadgeRecords: _byPerson([for (final b in _rows(r[10])) (b['profile_id'] as String, _badgeRecord(b))]),
      badgeCongrats: [
        for (final c in _rows(r[11]))
          BadgeCongrats(
            ownerId: c['owner_id'] as String,
            badgeId: c['badge_id'] as String,
            fromId: c['from_id'] as String,
          ),
      ],
      mapShared: meRow?['map_shared_at'] != null,
      visitThanks: [
        for (final t in _rows(r[12]))
          VisitThanks(visitId: t['visit_id'] as String, profileId: t['profile_id'] as String),
      ],
    );
  }

  @override
  Future<List<FeedPost>> loadFeed() async => [for (final f in _rows(await _db.rpc('get_feed'))) _feedPost(f)];

  @override
  Future<bool> isUsernameAvailable(String username) async =>
      await _db.rpc<bool>('is_username_available', params: {'candidate': username});

  // ── Writes ──────────────────────────────────────────────────────────────

  @override
  Future<void> createProfile({required String name, required String username}) =>
      _db.from('profiles').insert({'id': _uid, 'display_name': name, 'username': username});

  @override
  Future<void> createPlace(Place place) => _db.from('places').insert({
    'id': place.id,
    'name': place.name,
    'category': place.category.name,
    'lat': demoLat,
    'lng': demoLng,
    'area': place.area,
    'address': place.address,
    'city': place.city ?? place.area,
    'state': place.state,
  });

  @override
  Future<void> saveVisit(Visit visit, {required bool isNew}) {
    final row = {
      'visited_on': _date(visit.date),
      'recommended': visit.recommended,
      'rating': visit.rating,
      'tip': visit.tip,
      'body': visit.text,
      'companions': visit.companions,
      'tags': visit.tags,
      'budget_per_person': visit.budgetPerPerson,
    };
    return isNew
        ? _db.from('visits').insert({...row, 'id': visit.id, 'place_id': visit.placeId})
        : _db.from('visits').update(row).eq('id', visit.id);
  }

  @override
  Future<void> setSaved(String placeId, {required bool saved}) => saved
      ? _db.from('saved_places').insert({'place_id': placeId})
      : _db.from('saved_places').delete().eq('place_id', placeId);

  @override
  Future<void> sendFriendRequest(String personId) => _db.from('friendships').insert({'addressee_id': personId});

  @override
  Future<void> removeFriendship(String personId) => _db
      .from('friendships')
      .delete()
      .or('and(requester_id.eq.$_uid,addressee_id.eq.$personId),and(requester_id.eq.$personId,addressee_id.eq.$_uid)');

  @override
  Future<void> acceptFriendRequest(String personId) =>
      _db.from('friendships').update({'status': 'accepted'}).eq('requester_id', personId).eq('addressee_id', _uid);

  @override
  Future<void> markNotificationsRead() =>
      _db.from('notifications').update({'read_at': DateTime.now().toUtc().toIso8601String()}).isFilter('read_at', null);

  @override
  Future<String> createList(String title) async {
    // The owner and first member are filled in by the database (owner_id
    // defaults to auth.uid(); a trigger adds the list_members row).
    final row = await _db.from('lists').insert({'title': title}).select('id').single();
    return row['id'] as String;
  }

  @override
  Future<void> addToList(String listId, String placeId) =>
      _db.from('list_items').insert({'list_id': listId, 'place_id': placeId});

  @override
  Future<void> removeFromList(String listId, String placeId) =>
      _db.from('list_items').delete().eq('list_id', listId).eq('place_id', placeId);

  @override
  Future<void> markBadgesSeen(List<String> badgeIds) =>
      _db.rpc<void>('mark_badges_seen', params: {'badge_ids': badgeIds});

  @override
  Future<void> recordMapShared() => _db.rpc<void>('record_map_shared');

  @override
  Future<void> sendCongrats(String ownerId, String badgeId) =>
      _db.from('badge_congrats').insert({'owner_id': ownerId, 'badge_id': badgeId});

  @override
  Future<void> removeCongrats(String ownerId, String badgeId) =>
      _db.from('badge_congrats').delete().eq('owner_id', ownerId).eq('badge_id', badgeId).eq('from_id', _uid);

  @override
  Future<void> sendThanks(String visitId) => _db.from('visit_thanks').insert({'visit_id': visitId});

  @override
  Future<void> removeThanks(String visitId) =>
      _db.from('visit_thanks').delete().eq('visit_id', visitId).eq('profile_id', _uid);

  // ── Row → model mapping ─────────────────────────────────────────────────

  static BadgeRecord _badgeRecord(Map<String, dynamic> b) => BadgeRecord(
    badgeId: b['badge_id'] as String,
    level: (b['level'] as num).toInt(),
    progress: (b['progress'] as num?)?.toInt() ?? 0,
    earnedAt: b['earned_at'] == null ? null : DateTime.parse(b['earned_at'] as String).toLocal(),
    leveledAt: b['leveled_at'] == null ? null : DateTime.parse(b['leveled_at'] as String).toLocal(),
    seenLevel: (b['seen_level'] as num?)?.toInt() ?? 0,
  );

  static Map<String, List<BadgeRecord>> _byPerson(List<(String, BadgeRecord)> rows) {
    final out = <String, List<BadgeRecord>>{};
    for (final (person, record) in rows) {
      (out[person] ??= []).add(record);
    }
    return out;
  }

  static List<Map<String, dynamic>> _rows(dynamic result) => [
    for (final row in (result as List? ?? const [])) Map<String, dynamic>.from(row as Map),
  ];

  static Color _hex(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _distance(double metres) =>
      metres < 1000 ? '${metres.round()} m' : '${(metres / 1000).toStringAsFixed(1)} km';

  static PlaceCategory _category(Object? value) =>
      PlaceCategory.values.where((c) => c.name == value).firstOrNull ?? PlaceCategory.other;

  static Person _person(Map<String, dynamic> p, Map<String, dynamic>? s) {
    final name = p['display_name'] as String;
    final mutual = (s?['mutual_friends'] as int?) ?? 0;
    return Person(
      id: p['id'] as String,
      name: name,
      initials: Fmt.initials(name),
      username: p['username'] as String?,
      city: p['home_city'] as String?,
      avatarBg: _hex(p['avatar_bg'] as String),
      avatarFg: _hex(p['avatar_fg'] as String),
      placesCount: (s?['places_count'] as int?) ?? 0,
      citiesCount: (s?['cities_count'] as int?) ?? 0,
      tasteMatch: s?['taste_match'] as int?,
      lastPlace: s?['last_place'] as String?,
      note: mutual == 0 ? null : Fmt.count(mutual, 'mutual friend'),
    );
  }

  static Place _place(Map<String, dynamic> p) => Place(
    id: p['id'] as String,
    name: p['name'] as String,
    area: p['area'] as String,
    address: p['address'] as String,
    category: _category(p['category']),
    city: p['city'] as String?,
    state: p['state'] as String?,
  );

  static Visit _visit(Map<String, dynamic> v) {
    final photos = v['visit_photos'] as List? ?? const [];
    return Visit(
      id: v['id'] as String,
      placeId: v['place_id'] as String,
      authorId: v['author_id'] as String,
      date: DateTime.parse(v['visited_on'] as String),
      recommended: v['recommended'] as bool,
      rating: (v['rating'] as num).toDouble(),
      tip: v['tip'] as String,
      text: v['body'] as String,
      companions: List<String>.from(v['companions'] as List),
      tags: List<String>.from(v['tags'] as List),
      budgetPerPerson: v['budget_per_person'] as int?,
      photoCount: photos.isEmpty ? 0 : (photos.first as Map)['count'] as int,
      verified: v['verified'] as bool,
    );
  }

  static FeedPost _feedPost(Map<String, dynamic> f) => FeedPost(
    id: f['id'] as String,
    type: FeedPostType.values.byName(f['kind'] as String),
    authorId: f['author_id'] as String,
    verb: f['verb'] as String,
    subject: f['subject'] as String,
    when: Fmt.ago(DateTime.parse(f['created_at'] as String).toLocal()),
    quote: f['quote'] as String,
    likes: f['like_count'] as int,
    placeId: f['place_id'] as String?,
    category: f['category'] == null ? null : _category(f['category']),
    rating: (f['rating'] as num?)?.toDouble(),
    footnote: f['footnote'] as String?,
    badgeId: f['badge_id'] as String?,
  );

  static AppNotification _notification(Map<String, dynamic> n, Map<String, Person> people) {
    final created = DateTime.parse(n['created_at'] as String).toLocal();
    final now = DateTime.now();
    final actor = people[n['actor_id']];
    final payload = Map<String, dynamic>.from(n['payload'] as Map);
    final first = actor?.firstName ?? 'Someone';
    final place = payload['place'] as String? ?? 'a place';
    final others = (payload['others'] as int?) ?? 0;

    final (who, text, cta) = switch (n['kind']) {
      'joined' => (first, 'from your contacts just joined Clarity.', 'Open map'),
      'friend_request' => (actor?.name ?? 'Someone', 'sent you a friend request.', null),
      'liked' => (
        others > 0 ? '$first and ${Fmt.count(others, 'other')}' : first,
        'liked your review of $place.',
        null,
      ),
      'thanks' => (first, 'went to $place because of you. "Thanks, went there!"', null),
      'nudge' => (
        'Clarity:',
        'You were at $place for ${payload['minutes']} minutes. Rate it while it’s fresh?',
        'Rate it',
      ),
      'list_invite' => (first, 'added you to the list ${payload['list']}.', 'View list'),
      _ => (first, '', null),
    };

    return AppNotification(
      id: n['id'] as String,
      kind: switch (n['kind']) {
        'friend_request' => NotificationKind.friendRequest,
        'list_invite' => NotificationKind.listInvite,
        final String k => NotificationKind.values.byName(k),
        _ => NotificationKind.nudge,
      },
      who: who,
      text: text,
      when: Fmt.ago(created),
      initials: actor?.initials ?? 'C',
      personId: actor?.id,
      cta: cta,
      isToday: created.year == now.year && created.month == now.month && created.day == now.day,
      unread: n['read_at'] == null,
    );
  }

  static CollabList _list(
    Map<String, dynamic> l,
    String uid,
    Map<String, Person> people,
    Map<String, Place> places,
    List<Visit> visits,
  ) {
    final memberIds = [for (final m in l['list_members'] as List) (m as Map)['profile_id'] as String];
    final items = [
      for (final raw in l['list_items'] as List)
        () {
          final i = Map<String, dynamic>.from(raw as Map);
          final place = places[i['place_id']];
          final addedBy = i['added_by'] as String;
          final visitor = visits
              .where((v) => v.placeId == i['place_id'] && memberIds.contains(v.authorId))
              .map((v) => v.authorId)
              .firstOrNull;
          final votes = i['list_item_votes'] as List? ?? const [];
          return CollabListItem(
            id: i['id'] as String,
            name: place?.name ?? 'A place',
            category: place?.category ?? PlaceCategory.other,
            status: switch (visitor) {
              null => 'Want to go',
              final id when id == uid => 'You visited',
              final id => '${people[id]?.firstName ?? 'A friend'} visited',
            },
            addedBy: addedBy == uid ? 'you' : (people[addedBy]?.firstName ?? 'A friend'),
            votes: votes.isEmpty ? 0 : (votes.first as Map)['count'] as int,
            placeId: i['place_id'] as String,
          );
        }(),
    ]..sort((a, b) => b.votes.compareTo(a.votes));

    return CollabList(
      id: l['id'] as String,
      title: l['title'] as String,
      planning: l['planning_note'] as String,
      memberIds: memberIds,
      items: items,
      ownerId: l['owner_id'] as String?,
    );
  }
}
