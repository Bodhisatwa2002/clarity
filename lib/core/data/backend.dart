import 'dart:ui';

import '../models/badge.dart';
import '../models/person.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/social.dart';
import '../models/visit.dart';

/// Everything one signed-in person can see, loaded in one go after sign-in.
///
/// [AppState] keeps this in memory and the screens read it synchronously;
/// writes go to the [Backend] in the background.
class AppSnapshot {
  const AppSnapshot({
    required this.me,
    required this.hasProfile,
    this.people = const [],
    this.places = const [],
    this.myVisits = const [],
    this.otherVisits = const [],
    this.friendIds = const [],
    this.requestIds = const [],
    this.sentRequestIds = const [],
    this.savedPlaceIds = const {},
    this.feed = const [],
    this.notifications = const [],
    this.lists = const [],
    this.contactsOnClarity = const [],
    this.suggestedPeopleIds = const [],
    this.addPlaceSuggestionIds = const [],
    this.nearbyHere = const [],
    this.extraPlaces = 0,
    this.extraCities = 0,
    this.extraFriends = 0,
    this.extraCategoryCounts = const {},
    this.badgeRecords = const [],
    this.friendBadgeRecords = const {},
    this.badgeCongrats = const [],
    this.mapShared = false,
    this.visitThanks = const [],
  });

  /// Nobody signed in yet (Supabase, before the OTP is verified).
  static const AppSnapshot signedOut = AppSnapshot(
    me: Person(id: '', name: '', initials: '', avatarBg: Color(0xFFF2F7FF), avatarFg: Color(0xFF1D4E9E)),
    hasProfile: false,
  );

  final Person me;

  /// False right after a first sign-in, until "Create profile" is done.
  final bool hasProfile;

  /// Everyone the app may show, including [me].
  final List<Person> people;
  final List<Place> places;
  final List<Visit> myVisits;
  final List<Visit> otherVisits;
  final List<String> friendIds;
  final List<String> requestIds;
  final List<String> sentRequestIds;
  final Set<String> savedPlaceIds;
  final List<FeedPost> feed;
  final List<AppNotification> notifications;
  final List<CollabList> lists;

  /// People on "Find friends". Matched contacts once contact sync is wired.
  final List<String> contactsOnClarity;

  /// People search can find beyond your friends.
  final List<String> suggestedPeopleIds;

  /// What "Add a place" offers before Google Places search is wired.
  final List<String> addPlaceSuggestionIds;

  /// "Are you at…" candidates for "I'm here", nearest first.
  final List<({String placeId, String distance})> nearbyHere;

  /// Demo-only history that isn't modelled row by row (0 for real accounts).
  final int extraPlaces;
  final int extraCities;
  final int extraFriends;
  final Map<PlaceCategory, int> extraCategoryCounts;

  /// Your badges as the server stored them (`my_badges()`); empty on demo
  /// data, where the app counts them itself.
  final List<BadgeRecord> badgeRecords;

  /// Other people's earned badges you're allowed to see, by person id.
  final Map<String, List<BadgeRecord>> friendBadgeRecords;
  final List<BadgeCongrats> badgeCongrats;

  /// You've shared your map link at least once (Map sharer badge).
  final bool mapShared;

  /// "Thanks, went there!" on reviews you can see, yours included.
  final List<VisitThanks> visitThanks;
}

/// Where the app's data comes from: the built-in demo ([MockBackend]) or
/// Supabase ([SupabaseBackend]). Screens never talk to a backend directly.
abstract interface class Backend {
  /// True for Supabase, false for the demo data.
  bool get isRemote;

  /// Whether a session exists (restored from the keychain on launch).
  bool get isSignedIn;

  // ── Auth (Supabase Auth, phone OTP) ─────────────────────────────────────

  /// Texts a 6-digit code. [phone] is E.164, e.g. "+919876543210".
  Future<void> sendCode(String phone);

  /// Verifies the code and starts a session.
  Future<void> verifyCode(String phone, String code);

  Future<void> signOut();

  Future<void> deleteAccount();

  // ── Reads ───────────────────────────────────────────────────────────────

  Future<AppSnapshot> load();

  Future<List<FeedPost>> loadFeed();

  Future<bool> isUsernameAvailable(String username);

  // ── Writes ──────────────────────────────────────────────────────────────

  Future<void> createProfile({required String name, required String username});

  /// A dropped pin. Its location is the phone's once GPS is wired.
  Future<void> createPlace(Place place);

  /// Inserts or updates one of your visits ([isNew] says which).
  Future<void> saveVisit(Visit visit, {required bool isNew});

  Future<void> setSaved(String placeId, {required bool saved});

  Future<void> sendFriendRequest(String personId);

  /// Cancels a request you sent, declines one you got, or unfriends.
  Future<void> removeFriendship(String personId);

  Future<void> acceptFriendRequest(String personId);

  Future<void> markNotificationsRead();

  /// Creates a list you own (you become its first member) and returns its id.
  Future<String> createList(String title);

  Future<void> addToList(String listId, String placeId);

  Future<void> removeFromList(String listId, String placeId);

  // ── Badges (PRD §9.15) ──────────────────────────────────────────────────

  /// The celebrations for these badges were shown.
  Future<void> markBadgesSeen(List<String> badgeIds);

  /// You copied or sent your map link.
  Future<void> recordMapShared();

  Future<void> sendCongrats(String ownerId, String badgeId);

  Future<void> removeCongrats(String ownerId, String badgeId);

  /// "Thanks, went there!" on a friend's review.
  Future<void> sendThanks(String visitId);

  Future<void> removeThanks(String visitId);
}
