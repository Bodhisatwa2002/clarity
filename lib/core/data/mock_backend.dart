import '../models/person.dart';
import '../models/place_category.dart';
import '../models/place.dart';
import '../models/social.dart';
import '../models/visit.dart';
import 'backend.dart';
import 'mock_data.dart';

/// The built-in demo: [MockData] as a [Backend]. Used by tests, CI and any
/// run without `--dart-define-from-file`. Writes are accepted and forgotten.
class MockBackend implements Backend {
  bool _signedIn = false;

  @override
  bool get isRemote => false;

  @override
  bool get isSignedIn => _signedIn;

  /// The populated demo account ("I already have an account").
  static AppSnapshot demo() => AppSnapshot(
    me: MockData.me,
    hasProfile: true,
    people: MockData.people,
    places: MockData.places,
    myVisits: MockData.myVisits,
    otherVisits: MockData.friendVisits,
    friendIds: MockData.friendIds,
    requestIds: MockData.requestIds,
    sentRequestIds: MockData.sentRequestIds,
    feed: MockData.feed,
    notifications: MockData.notifications,
    lists: [MockData.goaTrip, _foodCrawl],
    contactsOnClarity: MockData.contactsOnClarity,
    suggestedPeopleIds: [MockData.rahulDey.id],
    addPlaceSuggestionIds: MockData.addPlaceSearchIds,
    nearbyHere: MockData.nearbyHere,
    extraPlaces: 27,
    extraCities: 6,
    extraFriends: 19,
    extraCategoryCounts: MockData.olderCategoryCounts,
    mapShared: true,
    badgeCongrats: MockData.badgeCongrats,
    visitThanks: MockData.visitThanks,
  );

  /// "Get started": a brand-new account with an empty map and no friends.
  static AppSnapshot newAccount() => AppSnapshot(
    me: const Person(
      id: MockData.meId,
      name: '',
      initials: '',
      avatarBg: MockData.meAvatarBg,
      avatarFg: MockData.meAvatarFg,
    ),
    hasProfile: false,
    people: MockData.people,
    places: MockData.places,
    otherVisits: MockData.friendVisits,
    contactsOnClarity: MockData.contactsOnClarity,
    suggestedPeopleIds: [MockData.rahulDey.id],
    addPlaceSuggestionIds: MockData.addPlaceSearchIds,
    nearbyHere: MockData.nearbyHere,
  );

  static const CollabList _foodCrawl = CollabList(
    id: 'food-crawl',
    title: 'Agartala food crawl',
    planning: '',
    ownerId: MockData.meId,
    memberIds: [MockData.meId],
    items: [
      CollabListItem(
        id: 'fc-1',
        name: 'Hilltop Momo Stall',
        category: PlaceCategory.food,
        status: 'Visited',
        addedBy: 'you',
        votes: 0,
        placeId: 'momo',
      ),
      CollabListItem(
        id: 'fc-2',
        name: 'Night Market Chaat',
        category: PlaceCategory.food,
        status: 'Visited',
        addedBy: 'you',
        votes: 0,
        placeId: 'night-chaat',
      ),
      CollabListItem(
        id: 'fc-3',
        name: 'Lakeside Reading Café',
        category: PlaceCategory.cafe,
        status: 'Visited',
        addedBy: 'you',
        votes: 0,
        placeId: 'lakeside-cafe',
      ),
    ],
  );

  @override
  Future<void> sendCode(String phone) async {}

  @override
  Future<void> verifyCode(String phone, String code) async => _signedIn = true;

  @override
  Future<void> signOut() async => _signedIn = false;

  @override
  Future<void> deleteAccount() async => _signedIn = false;

  @override
  Future<AppSnapshot> load() async => demo();

  @override
  Future<List<FeedPost>> loadFeed() async => MockData.feed;

  /// Names the demo treats as taken.
  static const takenUsernames = {'rahul', 'asha', 'priya', 'admin', 'clarity'};

  @override
  Future<bool> isUsernameAvailable(String username) async => !takenUsernames.contains(username);

  @override
  Future<void> createProfile({required String name, required String username}) async {}

  @override
  Future<void> createPlace(Place place) async {}

  @override
  Future<void> saveVisit(Visit visit, {required bool isNew}) async {}

  @override
  Future<void> setSaved(String placeId, {required bool saved}) async {}

  @override
  Future<void> sendFriendRequest(String personId) async {}

  @override
  Future<void> removeFriendship(String personId) async {}

  @override
  Future<void> acceptFriendRequest(String personId) async {}

  @override
  Future<void> markNotificationsRead() async {}

  @override
  Future<String> createList(String title) async => 'list-${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<void> addToList(String listId, String placeId) async {}

  @override
  Future<void> removeFromList(String listId, String placeId) async {}

  @override
  Future<void> markBadgesSeen(List<String> badgeIds) async {}

  @override
  Future<void> recordMapShared() async {}

  @override
  Future<void> sendCongrats(String ownerId, String badgeId) async {}

  @override
  Future<void> removeCongrats(String ownerId, String badgeId) async {}

  @override
  Future<void> sendThanks(String visitId) async {}

  @override
  Future<void> removeThanks(String visitId) async {}
}
