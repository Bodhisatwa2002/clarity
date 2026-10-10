import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/mock_data.dart';
import '../models/person.dart';
import '../models/place.dart';
import '../models/social.dart';
import '../models/visit.dart';

/// The bottom-navigation tabs. "Add" is an action, not a tab.
enum AppTab { map, feed, friends, profile }

enum FeedStatus { idle, loading, ready, error }

/// Everything the dummy app remembers while it runs.
///
/// One [ChangeNotifier] is plenty until a backend exists; when Supabase is
/// wired, the mock lists here become repository calls.
class AppState extends ChangeNotifier {
  AppState() {
    _loadDemoAccount();
  }

  // ── Session & profile ──────────────────────────────────────────────────

  String _name = MockData.me.name;
  String _username = MockData.me.username!;
  String _phoneDigits = '9876543210';
  String _countryCode = '+91';

  bool _isNewAccount = false;

  /// True after "Get started", false after "I already have an account".
  bool get isNewAccount => _isNewAccount;

  String get name => _name;
  String get firstName => _name.split(' ').first;
  String get username => _username;
  String get phoneDisplay =>
      '$_countryCode ${_phoneDigits.length > 5 ? '${_phoneDigits.substring(0, 5)} ${_phoneDigits.substring(5)}' : _phoneDigits}';

  /// Who you are, as a [Person] (for avatars and member stacks).
  Person get me => Person(
    id: MockData.meId,
    name: _name,
    initials: _initials(_name),
    username: _username,
    avatarBg: MockData.me.avatarBg,
    avatarFg: MockData.me.avatarFg,
  );

  void setPhone({required String countryCode, required String digits}) {
    _countryCode = countryCode;
    _phoneDigits = digits;
  }

  /// "Get started" — a brand-new account with an empty map and no friends.
  void startNewAccount() {
    _loadDemoAccount();
    _isNewAccount = true;
    _name = '';
    _username = '';
    _visits = [];
    _friendIds = [];
    _requestIds = [];
    _sentRequestIds = [];
    _usedSlots = 0;
    _baseStats = (places: 0, cities: 0);
    _olderFriendCount = 0;
    _notificationsRead = true;
    notifyListeners();
  }

  /// "I already have an account" — the populated demo account.
  void signInExisting() {
    _loadDemoAccount();
    notifyListeners();
  }

  void completeProfile({required String name, required String username}) {
    _name = name.trim();
    _username = username;
    notifyListeners();
  }

  void _loadDemoAccount() {
    _isNewAccount = false;
    _name = MockData.me.name;
    _username = MockData.me.username!;
    _visits = List.of(MockData.myVisits);
    _friendIds = List.of(MockData.friendIds);
    _requestIds = List.of(MockData.requestIds);
    _sentRequestIds = List.of(MockData.sentRequestIds);
    _places = {for (final p in MockData.places) p.id: p};
    _saved = {};
    _usedSlots = 0;
    _baseStats = (places: 27, cities: 6);
    _olderFriendCount = 19;
    _notificationsRead = false;
    _feedStatus = FeedStatus.idle;
    _tab = AppTab.map;
  }

  // ── Places & my visits ─────────────────────────────────────────────────

  Map<String, Place> _places = {for (final p in MockData.places) p.id: p};
  List<Visit> _visits = [];
  Set<String> _saved = {};
  int _usedSlots = 0;

  /// Older places that aren't individually modelled in the dummy data,
  /// so the header can still say "34 places across 6 cities".
  ({int places, int cities}) _baseStats = (places: 27, cities: 6);

  Place place(String id) => _places[id]!;
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

  int get placesCount => _baseStats.places + _visits.length;
  int get citiesCount =>
      _baseStats.cities > 0 ? _baseStats.cities : _visits.map((v) => place(v.placeId).area).toSet().length;

  /// "34 places across 6 cities".
  String get mapSummary => '$placesCount places across $citiesCount ${citiesCount == 1 ? 'city' : 'cities'}';

  /// Adds (or replaces) your review of a place and pins it on your map.
  void saveVisit(Visit visit) {
    final place = _places[visit.placeId]!;
    if (place.mapPosition == null) {
      final slot = MockData.freeMapSlots[_usedSlots % MockData.freeMapSlots.length];
      _usedSlots++;
      _places[place.id] = place.copyWith(mapPosition: slot);
    }
    _visits.removeWhere((v) => v.placeId == visit.placeId);
    _visits.add(visit);
    notifyListeners();
  }

  /// Creates a place from "Drop a pin" and returns it.
  Place addCustomPlace({required String name, required Place template}) {
    final id = 'custom-${DateTime.now().microsecondsSinceEpoch}';
    final place = Place(
      id: id,
      name: name,
      area: template.area,
      address: template.address,
      category: template.category,
    );
    _places[id] = place;
    notifyListeners();
    return place;
  }

  bool isSaved(String placeId) => _saved.contains(placeId);

  void toggleSaved(String placeId) {
    _saved.contains(placeId) ? _saved.remove(placeId) : _saved.add(placeId);
    notifyListeners();
  }

  // ── Friends' reviews ───────────────────────────────────────────────────

  /// Friends' visits to a place, newest first.
  List<Visit> friendVisitsFor(String placeId) =>
      MockData.friendVisits.where((v) => v.placeId == placeId && _friendIds.contains(v.authorId)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  /// Friends' average rating, or null if none of them have been.
  double? friendsRating(String placeId) {
    final visits = friendVisitsFor(placeId);
    if (visits.isEmpty) return null;
    return visits.map((v) => v.rating).reduce((a, b) => a + b) / visits.length;
  }

  /// A person's visits, newest first.
  List<Visit> visitsBy(String personId) =>
      MockData.friendVisits.where((v) => v.authorId == personId).toList()..sort((a, b) => b.date.compareTo(a.date));

  // ── People ─────────────────────────────────────────────────────────────

  List<String> _friendIds = [];
  List<String> _requestIds = [];
  List<String> _sentRequestIds = [];

  Person person(String id) => id == MockData.meId ? me : MockData.people.firstWhere((p) => p.id == id);

  List<Person> get friends =>
      _friendIds.map(person).toList()..sort((a, b) => (b.tasteMatch ?? 0).compareTo(a.tasteMatch ?? 0));
  List<Person> get requests => _requestIds.map(person).toList();
  List<Person> get sentRequests => _sentRequestIds.map(person).toList();

  /// Friends who aren't modelled individually (the demo account has 24).
  int _olderFriendCount = 19;
  int get friendCount => _olderFriendCount + _friendIds.length;
  bool get hasFriends => _friendIds.isNotEmpty;
  bool isFriend(String id) => _friendIds.contains(id);
  bool isRequested(String id) => _sentRequestIds.contains(id);

  void acceptRequest(String id) {
    _requestIds.remove(id);
    if (!_friendIds.contains(id)) _friendIds.add(id);
    notifyListeners();
  }

  void declineRequest(String id) {
    _requestIds.remove(id);
    notifyListeners();
  }

  /// Sends (or cancels) a friend request.
  void toggleRequest(String id) {
    _sentRequestIds.contains(id) ? _sentRequestIds.remove(id) : _sentRequestIds.add(id);
    notifyListeners();
  }

  /// Unfriends, or re-adds, someone from their profile.
  void toggleFriend(String id) {
    _friendIds.contains(id) ? _friendIds.remove(id) : _friendIds.add(id);
    notifyListeners();
  }

  /// In the dummy app, contacts you add accept straight away — so a new
  /// account's friends list fills in once they finish "Find friends".
  void confirmRequestedContacts() {
    final accepted = _sentRequestIds.where(MockData.contactsOnClarity.contains).toList();
    for (final id in accepted) {
      _sentRequestIds.remove(id);
      if (!_friendIds.contains(id)) _friendIds.add(id);
    }
    if (accepted.isNotEmpty) notifyListeners();
  }

  // ── Notifications ──────────────────────────────────────────────────────

  bool _notificationsRead = false;
  bool get hasUnreadNotifications => !_notificationsRead;
  int get unreadCount => _notificationsRead ? 0 : MockData.notifications.where((n) => n.unread).length;

  void markAllNotificationsRead() {
    _notificationsRead = true;
    notifyListeners();
  }

  // ── Feed ───────────────────────────────────────────────────────────────

  FeedStatus _feedStatus = FeedStatus.idle;
  FeedStatus get feedStatus => _feedStatus;
  List<FeedPost> get feed => MockData.feed;
  Timer? _feedTimer;

  /// Simulates fetching the feed. Pass [fail] to land on the error state.
  void loadFeed({bool fail = false, Duration delay = const Duration(milliseconds: 1400)}) {
    _feedTimer?.cancel();
    _feedStatus = FeedStatus.loading;
    notifyListeners();
    _feedTimer = Timer(delay, () {
      _feedStatus = fail ? FeedStatus.error : FeedStatus.ready;
      notifyListeners();
    });
  }

  void showFeed() {
    _feedTimer?.cancel();
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

  static String _initials(String name) =>
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
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
