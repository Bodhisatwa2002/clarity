import 'dart:async';

import 'package:flutter/widgets.dart';

import '../badges/badge_catalog.dart';
import '../badges/badge_engine.dart';
import '../data/backend.dart';
import '../data/mock_backend.dart';
import '../models/badge.dart';
import '../models/person.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/social.dart';
import '../models/visit.dart';
import '../utils/formatters.dart';
import '../utils/ids.dart';
import '../utils/map_slots.dart';

/// The bottom-navigation tabs. "Add" is an action, not a tab.
enum AppTab { map, feed, friends, profile }

enum FeedStatus { idle, loading, ready, error }

/// Everything the app shows, held in memory and read synchronously by screens.
///
/// Data comes from a [Backend]: [MockBackend] (tests, CI, no config) or
/// Supabase. Writes update memory first, then go to the backend in the
/// background; a failure is reported through [syncError].
class AppState extends ChangeNotifier {
  AppState({Backend? backend}) : _backend = backend ?? MockBackend() {
    _apply(_backend.isRemote ? AppSnapshot.signedOut : MockBackend.demo());
  }

  final Backend _backend;

  /// True when the data lives in Supabase.
  bool get isRemote => _backend.isRemote;

  bool get isSignedIn => _backend.isSignedIn;

  bool _loading = false;

  /// A Supabase load is in flight.
  bool get isLoading => _loading;

  String? _syncError;

  /// The last background write or load that failed, in plain words.
  String? get syncError => _syncError;

  // ── Session & profile ──────────────────────────────────────────────────

  Person _me = AppSnapshot.signedOut.me;
  String _name = '';
  String _username = '';
  String _phoneDigits = '9876543210';
  String _countryCode = '+91';

  bool _isNewAccount = false;
  bool _hasProfile = false;

  /// True after "Get started" (demo), or after a first sign-in with no
  /// profile yet (Supabase).
  bool get isNewAccount => _isNewAccount;

  /// Signed in and finished "Create profile".
  bool get hasProfile => _hasProfile;

  String get name => _name;
  String get firstName => _name.split(' ').first;
  String get username => _username;
  String get phoneDisplay => '$_countryCode ${Fmt.phone(_phoneDigits)}';
  String get _phoneE164 => '$_countryCode$_phoneDigits';

  /// Who you are, as a [Person] (for avatars and member stacks).
  Person get me => Person(
    id: _me.id,
    name: _name,
    initials: Fmt.initials(_name),
    username: _username,
    city: _me.city,
    avatarBg: _me.avatarBg,
    avatarFg: _me.avatarFg,
  );

  void setPhone({required String countryCode, required String digits}) {
    _countryCode = countryCode;
    _phoneDigits = digits;
  }

  /// "Get started". On demo data, a brand-new account with an empty map.
  void startNewAccount() {
    if (!isRemote) {
      _apply(MockBackend.newAccount());
      _notificationsRead = true;
    }
    _isNewAccount = true;
    notifyListeners();
  }

  /// "I already have an account". On demo data, the populated demo account.
  void signInExisting() {
    if (!isRemote) _apply(MockBackend.demo());
    _isNewAccount = false;
    notifyListeners();
  }

  /// Texts the code to the number from [setPhone]. Returns an error message.
  Future<String?> sendCode() => _attempt(() => _backend.sendCode(_phoneE164));

  /// Checks the code and loads the account. Returns an error message.
  Future<String?> verifyCode(String code) async {
    final error = await _attempt(() => _backend.verifyCode(_phoneE164, code));
    if (error != null || !isRemote) return error;
    await reload();
    _isNewAccount = !_hasProfile;
    notifyListeners();
    return _syncError;
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _backend.isUsernameAvailable(username);
    } catch (_) {
      return false;
    }
  }

  /// Saves name and username. Returns an error message.
  Future<String?> completeProfile({required String name, required String username}) async {
    final error = await _attempt(() => _backend.createProfile(name: name.trim(), username: username));
    if (error != null) return error;
    _name = name.trim();
    _username = username;
    _hasProfile = true;
    notifyListeners();
    return null;
  }

  Future<void> _ready = Future.value();

  /// Completes once the launch-time session restore has finished.
  Future<void> get ready => _ready;

  /// On launch: loads the account if a Supabase session was restored.
  Future<void> restoreSession() => _ready = isRemote && isSignedIn ? reload() : Future.value();

  /// Fetches everything again from the backend.
  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _apply(await _backend.load());
      _syncError = null;
    } catch (e) {
      _syncError = _message(e);
      debugPrint('AppState.reload failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _attempt(_backend.signOut);
    _apply(isRemote ? AppSnapshot.signedOut : MockBackend.demo());
    notifyListeners();
  }

  Future<String?> deleteAccount() async {
    final error = await _attempt(_backend.deleteAccount);
    if (error == null) {
      _apply(isRemote ? AppSnapshot.signedOut : MockBackend.demo());
      notifyListeners();
    }
    return error;
  }

  void _apply(AppSnapshot s) {
    _me = s.me;
    _name = s.me.name;
    _username = s.me.username ?? '';
    _hasProfile = s.hasProfile;
    _isNewAccount = !s.hasProfile;
    _people = {for (final p in s.people) p.id: p};
    _places = {for (final p in s.places) p.id: p};
    _visits = List.of(s.myVisits);
    _otherVisits = List.of(s.otherVisits);
    _friendIds = List.of(s.friendIds);
    _requestIds = List.of(s.requestIds);
    _sentRequestIds = List.of(s.sentRequestIds);
    _saved = Set.of(s.savedPlaceIds);
    _feed = s.feed;
    _notifications = s.notifications;
    _lists = s.lists;
    _contactsOnClarity = s.contactsOnClarity;
    _suggestedPeopleIds = s.suggestedPeopleIds;
    _addPlaceSuggestionIds = s.addPlaceSuggestionIds;
    _nearbyHere = s.nearbyHere;
    _extraPlaces = s.extraPlaces;
    _extraCities = s.extraCities;
    _extraFriends = s.extraFriends;
    _extraCategoryCounts = s.extraCategoryCounts;
    _notificationsRead = !s.notifications.any((n) => n.unread);
    _badgeRecords = {for (final r in s.badgeRecords) r.badgeId: r};
    _friendBadgeRecords = s.friendBadgeRecords;
    _congrats = List.of(s.badgeCongrats);
    _mapShared = s.mapShared;
    _thanks = List.of(s.visitThanks);
    _seenLevels.clear();
    _reachedLevels.clear();
    _feedStatus = FeedStatus.idle;
    _tab = AppTab.map;
    for (final v in myVisits) {
      _pinOnMap(v.placeId);
    }
    // What you already had when this data loaded is not news. On Supabase the
    // server remembers what you've been shown; on demo data nothing has been.
    for (final b in badges) {
      _seenLevels[b.id] = isRemote ? b.seenLevel : b.level;
    }
  }

  // ── Places & my visits ─────────────────────────────────────────────────

  Map<String, Place> _places = {};
  List<Visit> _visits = [];
  Set<String> _saved = {};
  int _extraPlaces = 0;
  int _extraCities = 0;
  Map<PlaceCategory, int> _extraCategoryCounts = const {};
  List<String> _addPlaceSuggestionIds = const [];
  List<({String placeId, String distance})> _nearbyHere = const [];

  Place place(String id) => _places[id] ?? _unknownPlace(id);
  Place? placeOrNull(String id) => _places[id];
  Iterable<Place> get allPlaces => _places.values;

  /// Your visits, newest first.
  List<Visit> get myVisits => List.of(_visits)..sort((a, b) => b.date.compareTo(a.date));

  bool get hasPlaces => _visits.isNotEmpty;

  Visit? myVisitFor(String placeId) {
    for (final v in _visits) {
      if (v.placeId == placeId) return v;
    }
    return null;
  }

  int get placesCount => _extraPlaces + _visits.map((v) => v.placeId).toSet().length;
  int get citiesCount => _extraCities > 0 ? _extraCities : _visits.map((v) => place(v.placeId).area).toSet().length;

  /// "34 places across 6 cities".
  String get mapSummary => '$placesCount places across $citiesCount ${citiesCount == 1 ? 'city' : 'cities'}';

  /// Your places per category, for the profile header.
  Map<PlaceCategory, int> get myCategoryCounts {
    final counts = Map.of(_extraCategoryCounts);
    for (final v in _visits) {
      final c = place(v.placeId).category;
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return counts;
  }

  /// What "Add a place" suggests before Google Places search is wired.
  List<Place> get addPlaceSuggestions => [for (final id in _addPlaceSuggestionIds) ?_places[id]];

  /// "Are you at…" candidates for "I'm here".
  List<({Place place, String distance})> get nearbyHere => [
    for (final n in _nearbyHere)
      if (_places[n.placeId] case final p?) (place: p, distance: n.distance),
  ];

  /// Places whose name, area or category matches [query].
  List<Place> searchPlaces(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final words = q.split(RegExp(r'\s+')).where((w) => w.length > 2);
    return _places.values.where((p) {
      final hay = '${p.name} ${p.area} ${p.address} ${p.category.label}'.toLowerCase();
      return hay.contains(q) || words.any(hay.contains);
    }).toList();
  }

  /// Adds or updates your review of a place and pins it on your map.
  void saveVisit(Visit visit) {
    final isNew = !_visits.any((v) => v.id == visit.id);
    _visits.removeWhere((v) => v.id == visit.id);
    _visits.add(visit);
    _pinOnMap(visit.placeId);
    notifyListeners();
    _sync(() => _backend.saveVisit(visit, isNew: isNew));
  }

  /// Creates a place from "Drop a pin" and returns it.
  Place addCustomPlace({required String name, required Place template}) {
    final place = Place(
      id: isRemote ? Ids.uuid() : 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      area: template.area,
      address: template.address,
      category: template.category,
      city: template.city,
      state: template.state,
    );
    _places[place.id] = place;
    notifyListeners();
    _sync(() => _backend.createPlace(place));
    return place;
  }

  /// A new visit id: the backend accepts ids the app creates.
  String newVisitId(String placeId) => isRemote ? Ids.uuid() : 'v-$placeId';

  bool isSaved(String placeId) => _saved.contains(placeId);

  void toggleSaved(String placeId) {
    final saved = !_saved.contains(placeId);
    saved ? _saved.add(placeId) : _saved.remove(placeId);
    notifyListeners();
    _sync(() => _backend.setSaved(placeId, saved: saved));
  }

  /// Gives a place a spot on the illustrated map if it doesn't have one.
  void _pinOnMap(String placeId) {
    final p = _places[placeId];
    if (p == null || p.mapPosition != null) return;
    final taken = {for (final q in _places.values) ?q.mapPosition};
    final slot = MapSlots.all.firstWhere((s) => !taken.contains(s), orElse: () => MapSlots.at(taken.length));
    _places[placeId] = p.copyWith(mapPosition: slot);
  }

  static Place _unknownPlace(String id) =>
      Place(id: id, name: 'Unknown place', area: '', address: '', category: PlaceCategory.other);

  // ── Friends' reviews ───────────────────────────────────────────────────

  List<Visit> _otherVisits = [];

  /// Friends' visits to a place, newest first.
  List<Visit> friendVisitsFor(String placeId) =>
      _otherVisits.where((v) => v.placeId == placeId && _friendIds.contains(v.authorId)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  /// Friends' average rating, or null if none of them have been.
  double? friendsRating(String placeId) {
    final visits = friendVisitsFor(placeId).where((v) => v.rating > 0);
    if (visits.isEmpty) return null;
    return visits.map((v) => v.rating).reduce((a, b) => a + b) / visits.length;
  }

  /// A person's visits, newest first.
  List<Visit> visitsBy(String personId) =>
      _otherVisits.where((v) => v.authorId == personId).toList()..sort((a, b) => b.date.compareTo(a.date));

  /// A person's top categories, for their mini map.
  List<(PlaceCategory, int)> topCategoriesFor(String personId) {
    final counts = <PlaceCategory, int>{};
    for (final v in visitsBy(personId)) {
      final c = place(v.placeId).category;
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(2)
        .map((e) => (e.key, e.value))
        .toList();
  }

  // ── People ─────────────────────────────────────────────────────────────

  Map<String, Person> _people = {};
  List<String> _friendIds = [];
  List<String> _requestIds = [];
  List<String> _sentRequestIds = [];
  List<String> _contactsOnClarity = const [];
  List<String> _suggestedPeopleIds = const [];
  int _extraFriends = 0;

  Person person(String id) => id == _me.id ? me : _people[id] ?? _unknownPerson(id);

  List<Person> get friends =>
      _friendIds.map(person).toList()..sort((a, b) => (b.tasteMatch ?? 0).compareTo(a.tasteMatch ?? 0));
  List<Person> get requests => _requestIds.map(person).toList();
  List<Person> get sentRequests => _sentRequestIds.map(person).toList();

  /// Ids shown on "Find friends" as already on Clarity.
  List<String> get contactsOnClarity => _contactsOnClarity;

  /// People search can find beyond your friends.
  List<Person> get suggestedPeople => _suggestedPeopleIds.map(person).toList();

  int get friendCount => _extraFriends + _friendIds.length;
  bool get hasFriends => _friendIds.isNotEmpty;
  bool isFriend(String id) => _friendIds.contains(id);
  bool isRequested(String id) => _sentRequestIds.contains(id);

  void acceptRequest(String id) {
    _requestIds.remove(id);
    if (!_friendIds.contains(id)) _friendIds.add(id);
    notifyListeners();
    _sync(() => _backend.acceptFriendRequest(id));
  }

  void declineRequest(String id) {
    _requestIds.remove(id);
    notifyListeners();
    _sync(() => _backend.removeFriendship(id));
  }

  /// Sends (or cancels) a friend request.
  void toggleRequest(String id) {
    final cancel = _sentRequestIds.contains(id);
    cancel ? _sentRequestIds.remove(id) : _sentRequestIds.add(id);
    notifyListeners();
    _sync(() => cancel ? _backend.removeFriendship(id) : _backend.sendFriendRequest(id));
  }

  /// Unfriends someone from their profile, or asks them again. (The demo
  /// re-adds straight away; real friendships need them to accept.)
  void toggleFriend(String id) {
    if (_friendIds.remove(id)) {
      _sync(() => _backend.removeFriendship(id));
    } else if (isRemote) {
      _sentRequestIds.add(id);
      _sync(() => _backend.sendFriendRequest(id));
    } else {
      _friendIds.add(id);
    }
    notifyListeners();
  }

  /// Demo only: contacts you add accept straight away, so a new account's
  /// friends list fills in once they finish "Find friends".
  void confirmRequestedContacts() {
    if (isRemote) return;
    final accepted = _sentRequestIds.where(_contactsOnClarity.contains).toList();
    for (final id in accepted) {
      _sentRequestIds.remove(id);
      if (!_friendIds.contains(id)) _friendIds.add(id);
    }
    if (accepted.isNotEmpty) notifyListeners();
  }

  static Person _unknownPerson(String id) => Person(
    id: id,
    name: 'Someone',
    initials: '?',
    avatarBg: const Color(0xFFEEF0F4),
    avatarFg: const Color(0xFF3F4857),
  );

  // ── Lists ──────────────────────────────────────────────────────────────

  List<CollabList> _lists = const [];
  List<CollabList> get lists => _lists;

  /// The list with [id], or the first shared list when [id] is null.
  CollabList? list(String? id) {
    if (_lists.isEmpty) return null;
    if (id == null) return _lists.firstWhere((l) => l.memberIds.length > 1, orElse: () => _lists.first);
    return _lists.where((l) => l.id == id).firstOrNull;
  }

  bool isInList(String listId, String placeId) => list(listId)?.items.any((i) => i.placeId == placeId) ?? false;

  /// Adds [placeId] to the list, or takes it out if it's already there.
  void toggleInList(String listId, String placeId) {
    final l = list(listId);
    if (l == null) return;
    final adding = !isInList(listId, placeId);
    final items = adding ? [...l.items, _newListItem(placeId)] : l.items.where((i) => i.placeId != placeId).toList();
    _replaceList(l, items);
    notifyListeners();
    _sync(() => adding ? _backend.addToList(listId, placeId) : _backend.removeFromList(listId, placeId));
  }

  /// Creates a list you own, optionally starting with [placeId]. The user
  /// waits on this one: the list's id comes from the server.
  Future<({String? listId, String? error})> createList(String title, {String? placeId}) async {
    String? id;
    final error = await _attempt(() async {
      id = await _backend.createList(title.trim());
      if (placeId != null) await _backend.addToList(id!, placeId);
    });
    if (error != null) return (listId: null, error: error);
    _lists = [
      CollabList(
        id: id!,
        title: title.trim(),
        planning: '',
        memberIds: [_me.id],
        ownerId: _me.id,
        items: [if (placeId != null) _newListItem(placeId)],
      ),
      ..._lists,
    ];
    notifyListeners();
    return (listId: id, error: null);
  }

  CollabListItem _newListItem(String placeId) {
    final p = place(placeId);
    return CollabListItem(
      id: 'item-$placeId-${DateTime.now().microsecondsSinceEpoch}',
      name: p.name,
      category: p.category,
      status: myVisitFor(placeId) != null ? 'You visited' : 'Want to go',
      addedBy: 'you',
      votes: 0,
      placeId: placeId,
    );
  }

  void _replaceList(CollabList l, List<CollabListItem> items) {
    _lists = [
      for (final x in _lists)
        x.id == l.id
            ? CollabList(
                id: l.id,
                title: l.title,
                planning: l.planning,
                memberIds: l.memberIds,
                ownerId: l.ownerId,
                items: items,
              )
            : x,
    ];
  }

  /// "6 places · with Priya, Rahul, Asha" / "3 places · just you".
  String listSubtitle(CollabList l) {
    final others = l.memberIds.where((m) => m != _me.id).map((m) => person(m).firstName).toList();
    return '${Fmt.count(l.items.length, 'place')} · ${others.isEmpty ? 'just you' : 'with ${others.join(', ')}'}';
  }

  // ── Notifications ──────────────────────────────────────────────────────

  List<AppNotification> _notifications = const [];
  List<AppNotification> get notifications => _notifications;

  bool _notificationsRead = false;
  bool get hasUnreadNotifications => !_notificationsRead;
  int get unreadCount => _notificationsRead ? 0 : _notifications.where((n) => n.unread).length;

  void markAllNotificationsRead() {
    _notificationsRead = true;
    notifyListeners();
    _sync(_backend.markNotificationsRead);
  }

  // ── Feed ───────────────────────────────────────────────────────────────

  FeedStatus _feedStatus = FeedStatus.idle;
  FeedStatus get feedStatus => _feedStatus;
  List<FeedPost> _feed = const [];
  List<FeedPost> get feed => _feed;
  Timer? _feedTimer;

  /// Fetches the feed. [fail] and [delay] drive the hidden Design states
  /// sheet on demo data.
  void loadFeed({bool fail = false, Duration delay = const Duration(milliseconds: 1400)}) {
    _feedTimer?.cancel();
    _feedStatus = FeedStatus.loading;
    notifyListeners();
    if (!isRemote || fail) {
      _feedTimer = Timer(delay, () {
        _feedStatus = fail ? FeedStatus.error : FeedStatus.ready;
        notifyListeners();
      });
      return;
    }
    _backend.loadFeed().then(
      (posts) {
        _feed = posts;
        _feedStatus = FeedStatus.ready;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('AppState.loadFeed failed: $e');
        _feedStatus = FeedStatus.error;
        notifyListeners();
      },
    );
  }

  void showFeed() {
    _feedTimer?.cancel();
    if (isRemote) return loadFeed();
    _feedStatus = FeedStatus.ready;
    notifyListeners();
  }

  // ── Navigation shell ───────────────────────────────────────────────────

  AppTab _tab = AppTab.map;
  AppTab get tab => _tab;

  void selectTab(AppTab tab) {
    if (tab == AppTab.feed && _feedStatus == FeedStatus.idle) loadFeed();
    _tab = tab;
    notifyListeners();
  }

  @override
  void dispose() {
    _feedTimer?.cancel();
    super.dispose();
  }

  // ── Badges (PRD §9.15) ─────────────────────────────────────────────────

  Map<String, BadgeRecord> _badgeRecords = {};
  Map<String, List<BadgeRecord>> _friendBadgeRecords = const {};
  List<BadgeCongrats> _congrats = [];
  bool _mapShared = false;

  /// Level whose celebration has been shown, per badge.
  final Map<String, int> _seenLevels = {};

  /// Highest level reached this session, so a badge never drops (BDG-3)
  /// even before the server has stored it.
  final Map<String, int> _reachedLevels = {};

  /// Every badge with your progress, in catalogue order.
  ///
  /// Counted here from your data (so an unlock shows the moment it happens)
  /// and merged with what the server stored: the higher level wins, and Tip
  /// master's count comes from the server only.
  List<BadgeProgress> get badges {
    final friends = _otherVisits.where((v) => _friendIds.contains(v.authorId)).toList();
    final counts = BadgeEngine.count(
      personId: _me.id,
      mine: _visits,
      place: place,
      friendVisits: friends,
      friendCount: _friendIds.length,
      lists: _lists,
      mapShared: _mapShared,
      friendsWhoWent: _friendsWhoWent,
    );
    return [
      for (final def in BadgeCatalog.all)
        () {
          final record = _badgeRecords[def.id];
          final count = counts[def.id] ?? const BadgeCount(0);
          final progress = def.id == 'tip_master' ? (record?.progress ?? 0) : count.progress;
          final level = [
            def.levelFor(progress),
            record?.level ?? 0,
            _reachedLevels[def.id] ?? 0,
          ].reduce((a, b) => a > b ? a : b).clamp(0, def.levels.length);
          _reachedLevels[def.id] = level;
          return BadgeProgress(
            def: def,
            progress: progress,
            level: level,
            seenLevel: _seenLevels[def.id] ?? record?.seenLevel ?? 0,
            earnedAt: record?.earnedAt ?? _localEarnedAt(def, count, level),
            leveledAt: record?.leveledAt,
            placeIds: count.placeIds,
          );
        }(),
    ];
  }

  BadgeProgress badge(String id) => badges.firstWhere((b) => b.id == id);

  int get badgesEarned => badges.where((b) => b.earned).length;

  /// Earned badges whose celebration hasn't been shown, oldest first.
  List<BadgeProgress> get pendingUnlocks => badges.where((b) => b.earned && b.isNew).toList();

  /// The closest badge to its next level by percentage (BDG-7), never a
  /// secret one.
  BadgeProgress? get nextBadge {
    final open = badges.where((b) => !b.maxed && !b.def.isSecret && b.progress > 0).toList()
      ..sort((a, b) => b.fraction.compareTo(a.fraction));
    return open.firstOrNull ?? badges.where((b) => !b.earned && !b.def.isSecret).firstOrNull;
  }

  /// The five Get started steps and whether each is done (BDG-10).
  List<BadgeProgress> get starterBadges => [for (final id in BadgeCatalog.starterIds) badge(id)];

  bool get starterDone => starterBadges.every((b) => b.earned);

  /// The celebrations for [ids] were shown.
  void markBadgesSeen(List<String> ids) {
    if (ids.isEmpty) return;
    final all = badges;
    for (final id in ids) {
      _seenLevels[id] = all.firstWhere((b) => b.id == id).level;
    }
    notifyListeners();
    // After any write still in flight, so the server has the badge to mark.
    final before = _lastWrite;
    _sync(() async {
      await before;
      await _backend.markBadgesSeen(ids);
    });
  }

  /// You copied or sent your map link (Map sharer).
  void recordMapShared() {
    if (_mapShared) return;
    _mapShared = true;
    notifyListeners();
    _sync(_backend.recordMapShared);
  }

  /// Someone else's earned badges, newest first.
  List<BadgeProgress> badgesOf(String personId) {
    if (personId == _me.id) return badges.where((b) => b.earned).toList();
    final List<BadgeProgress> earned;
    if (isRemote) {
      earned = [
        for (final r in _friendBadgeRecords[personId] ?? const <BadgeRecord>[])
          if (BadgeCatalog.byId[r.badgeId] case final def?)
            BadgeProgress(
              def: def,
              progress: r.progress,
              level: r.level.clamp(1, def.levels.length),
              seenLevel: r.level,
              earnedAt: r.earnedAt,
              leveledAt: r.leveledAt,
            ),
      ];
    } else {
      final counts = BadgeEngine.count(personId: personId, mine: visitsBy(personId), place: place);
      earned = [
        for (final def in BadgeCatalog.all)
          if (counts[def.id] case final c? when def.levelFor(c.progress) > 0)
            BadgeProgress(
              def: def,
              progress: c.progress,
              level: def.levelFor(c.progress),
              seenLevel: def.levelFor(c.progress),
              earnedAt: _localEarnedAt(def, c, def.levelFor(c.progress), personId: personId),
              placeIds: c.placeIds,
            ),
      ];
    }
    return earned
      ..sort((a, b) => (b.leveledAt ?? b.earnedAt ?? DateTime(0)).compareTo(a.leveledAt ?? a.earnedAt ?? DateTime(0)));
  }

  /// A friend's badge earned in the last 14 days, for their profile (BDG-11).
  BadgeProgress? recentBadgeOf(String personId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    return badgesOf(personId).where((b) => (b.leveledAt ?? b.earnedAt)?.isAfter(cutoff) ?? false).firstOrNull;
  }

  /// Friends who have [badgeId] too.
  List<String> friendsWithBadge(String badgeId) =>
      _friendIds.where((id) => badgesOf(id).any((b) => b.id == badgeId)).toList();

  /// Who said Congrats on [ownerId]'s [badgeId].
  List<String> congratsFor(String ownerId, String badgeId) => [
    for (final c in _congrats)
      if (c.ownerId == ownerId && c.badgeId == badgeId) c.fromId,
  ];

  void toggleCongrats(String ownerId, String badgeId) {
    final mine = _congrats.any((c) => c.ownerId == ownerId && c.badgeId == badgeId && c.fromId == _me.id);
    if (mine) {
      _congrats.removeWhere((c) => c.ownerId == ownerId && c.badgeId == badgeId && c.fromId == _me.id);
    } else {
      _congrats.add(BadgeCongrats(ownerId: ownerId, badgeId: badgeId, fromId: _me.id));
    }
    notifyListeners();
    _sync(() => mine ? _backend.removeCongrats(ownerId, badgeId) : _backend.sendCongrats(ownerId, badgeId));
  }

  // ── Thanks, went there! (Trusted voice) ────────────────────────────────

  List<VisitThanks> _thanks = [];

  /// Who said "Thanks, went there!" on a review.
  List<String> thanksFor(String visitId) => [
    for (final t in _thanks)
      if (t.visitId == visitId) t.profileId,
  ];

  bool hasThanked(String visitId) => _thanks.any((t) => t.visitId == visitId && t.profileId == _me.id);

  /// You can thank a friend's review if you went there after them, not
  /// with them ("you went because of this").
  bool canThank(Visit visit) {
    if (visit.authorId == _me.id || !_friendIds.contains(visit.authorId)) return false;
    if (visit.companions.contains('you')) return false;
    final mine = _visits.where((v) => v.placeId == visit.placeId);
    return mine.any((v) => !v.date.isBefore(visit.date));
  }

  void toggleThanks(String visitId) {
    final mine = hasThanked(visitId);
    if (mine) {
      _thanks.removeWhere((t) => t.visitId == visitId && t.profileId == _me.id);
    } else {
      _thanks.add(VisitThanks(visitId: visitId, profileId: _me.id));
    }
    notifyListeners();
    _sync(() => mine ? _backend.removeThanks(visitId) : _backend.sendThanks(visitId));
  }

  /// Friends who said "Thanks, went there!" on any of your reviews.
  int get _friendsWhoWent {
    final mine = {for (final v in _visits) v.id};
    return {
      for (final t in _thanks)
        if (mine.contains(t.visitId) && t.profileId != _me.id) t.profileId,
    }.length;
  }

  /// When a badge was earned, from the data, until the server says: the
  /// date of the visit that reached the level's threshold.
  DateTime? _localEarnedAt(BadgeDef def, BadgeCount count, int level, {String? personId}) {
    if (level == 0 || count.placeIds.isEmpty) return null;
    final visits = personId == null ? _visits : visitsBy(personId);
    final firstVisit = <String, DateTime>{};
    for (final v in visits) {
      final d = firstVisit[v.placeId];
      if (d == null || v.date.isBefore(d)) firstVisit[v.placeId] = v.date;
    }
    final dates = [for (final id in count.placeIds) ?firstVisit[id]]..sort();
    if (dates.isEmpty) return null;
    final index = (def.levels[level - 1] - 1).clamp(0, dates.length - 1);
    return dates[index];
  }

  // ── Backend plumbing ───────────────────────────────────────────────────

  /// Runs a call the user is waiting on; returns a message on failure.
  Future<String?> _attempt(Future<void> Function() call) async {
    try {
      await call();
      return null;
    } catch (e) {
      debugPrint('Backend call failed: $e');
      return _message(e);
    }
  }

  /// The most recent background write, so a later call can wait for it.
  Future<void> _lastWrite = Future.value();

  /// Fire-and-forget write after an optimistic update.
  void _sync(Future<void> Function() call) {
    final write = call();
    _lastWrite = write.then((_) {}, onError: (_) {});
    unawaited(
      write.then(
        (_) {},
        onError: (Object e) {
          debugPrint('Background write failed: $e');
          _syncError = _message(e);
          notifyListeners();
        },
      ),
    );
  }

  static String _message(Object e) {
    final text = e.toString();
    if (text.contains('23505') || text.contains('duplicate key')) return 'That username is taken. Try another.';
    if (text.contains('Invalid') || text.contains('expired')) return "That code didn't work. Check it and try again.";
    if (text.contains('SocketException') || text.contains('ClientException')) {
      return "Can't reach Clarity right now. Check your connection.";
    }
    return 'Something went wrong. Try again.';
  }
}

/// Makes [AppState] available to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Reads the state and rebuilds the caller when it changes.
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without subscribing — use in callbacks.
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension AppStateContext on BuildContext {
  AppState get app => AppScope.of(this);
  AppState get appRead => AppScope.read(this);
}
