import 'dart:ui';

import '../models/badge.dart';
import '../models/person.dart';
import '../models/place.dart';
import '../models/place_category.dart';
import '../models/social.dart';
import '../models/visit.dart';

/// Dummy data used until Supabase is wired. Mirrors the design mockups.
abstract final class MockData {
  static final DateTime now = DateTime.now();

  // ── People ──────────────────────────────────────────────────────────────

  static const String meId = 'me';

  static const Color meAvatarBg = Color(0xFFF2F7FF);
  static const Color meAvatarFg = Color(0xFF1D4E9E);

  static const Person me = Person(
    id: meId,
    name: 'Bodhi Chakraborty',
    initials: 'BC',
    username: 'bodhi',
    city: 'Agartala',
    avatarBg: meAvatarBg,
    avatarFg: meAvatarFg,
  );

  static const Person rahul = Person(
    id: 'rahul',
    name: 'Rahul Sen',
    initials: 'RS',
    username: 'rahul',
    city: 'Agartala',
    placesCount: 42,
    citiesCount: 9,
    tasteMatch: 86,
    lastPlace: 'Dzükou Valley',
    note: 'In your contacts',
    avatarBg: Color(0xFFDDEAFB),
    avatarFg: Color(0xFF1D4E9E),
  );

  static const Person priya = Person(
    id: 'priya',
    name: 'Priya Kar',
    initials: 'PK',
    username: 'priya',
    city: 'Agartala',
    placesCount: 61,
    citiesCount: 14,
    tasteMatch: 78,
    lastPlace: 'Hilltop Momo Stall',
    note: 'In your contacts',
    avatarBg: Color(0xFFDDF6EC),
    avatarFg: Color(0xFF11694E),
  );

  static const Person asha = Person(
    id: 'asha',
    name: 'Asha Debbarma',
    initials: 'AD',
    username: 'asha',
    city: 'Agartala',
    placesCount: 27,
    citiesCount: 5,
    tasteMatch: 64,
    lastPlace: 'Ward Lake',
    note: 'In your contacts',
    avatarBg: Color(0xFFFFE3CC),
    avatarFg: Color(0xFF9A3412),
  );

  static const Person meera = Person(
    id: 'meera',
    name: 'Meera Saha',
    initials: 'MS',
    username: 'meera',
    city: 'Udaipur',
    placesCount: 19,
    citiesCount: 4,
    tasteMatch: 52,
    lastPlace: 'Unakoti',
    note: 'In your contacts',
    avatarBg: Color(0xFFFDE2EC),
    avatarFg: Color(0xFFA61E4D),
  );

  static const Person kabir = Person(
    id: 'kabir',
    name: 'Kabir Roy',
    initials: 'KR',
    username: 'kabir',
    city: 'Goa',
    placesCount: 33,
    citiesCount: 7,
    tasteMatch: 41,
    lastPlace: 'Baga Beach',
    avatarBg: Color(0xFFEEF0F4),
    avatarFg: Color(0xFF3F4857),
  );

  static const Person arjun = Person(
    id: 'arjun',
    name: 'Arjun Nath',
    initials: 'AN',
    username: 'arjun.n',
    city: 'Agartala',
    placesCount: 8,
    citiesCount: 2,
    tasteMatch: 58,
    lastPlace: 'Rabindra Kanan',
    note: 'In your contacts',
    avatarBg: Color(0xFFEDE5FF),
    avatarFg: Color(0xFF5B3CC4),
  );

  static const Person tanmoy = Person(
    id: 'tanmoy',
    name: 'Tanmoy Paul',
    initials: 'TP',
    placesCount: 14,
    tasteMatch: 60,
    lastPlace: 'Ujjayanta Palace',
    note: 'In your contacts',
    avatarBg: Color(0xFFE3F0FF),
    avatarFg: Color(0xFF1D4E9E),
  );

  static const Person sneha = Person(
    id: 'sneha',
    name: 'Sneha Ghosh',
    initials: 'SG',
    placesCount: 22,
    tasteMatch: 55,
    lastPlace: 'Neermahal',
    note: '3 mutual friends',
    avatarBg: Color(0xFFFFF1C9),
    avatarFg: Color(0xFF8A5A00),
  );

  static const Person dev = Person(
    id: 'dev',
    name: 'Dev Majumder',
    initials: 'DM',
    placesCount: 6,
    tasteMatch: 47,
    lastPlace: 'Heritage Park',
    note: 'In your contacts',
    avatarBg: Color(0xFFE6F7EE),
    avatarFg: Color(0xFF11694E),
  );

  static const Person rahulDey = Person(
    id: 'rahuldey',
    name: 'Rahul Dey',
    initials: 'RD',
    username: 'rahuldey',
    note: '2 mutual friends',
    avatarBg: Color(0xFFEEF0F4),
    avatarFg: Color(0xFF3F4857),
  );

  static const List<Person> people = [me, rahul, priya, asha, meera, kabir, arjun, tanmoy, sneha, dev, rahulDey];

  /// Friends of the demo account, in taste-match order.
  static const List<String> friendIds = ['rahul', 'priya', 'asha', 'meera', 'kabir'];

  /// Friends who said Congrats on Rahul's newest badge (Trekker, from Dzükou).
  /// Asha went to Hilltop Momo Stall and Priya to Neermahal because of you.
  static const List<VisitThanks> visitThanks = [
    VisitThanks(visitId: 'v-momo', profileId: 'asha'),
    VisitThanks(visitId: 'v-neermahal', profileId: 'priya'),
  ];

  static const List<BadgeCongrats> badgeCongrats = [
    BadgeCongrats(ownerId: 'rahul', badgeId: 'trekker', fromId: 'priya'),
    BadgeCongrats(ownerId: 'rahul', badgeId: 'trekker', fromId: 'asha'),
  ];

  /// Incoming friend requests.
  static const List<String> requestIds = ['tanmoy', 'sneha', 'dev'];

  /// Requests you sent that are still pending.
  static const List<String> sentRequestIds = ['arjun'];

  /// Totals shown on "Find friends" (only the first few matches are modelled).
  static const int matchedContacts = 12;
  static const int sharedContacts = 46;

  /// Contacts who are already on Clarity (shown on "Find friends").
  static const List<String> contactsOnClarity = ['rahul', 'asha', 'priya', 'arjun', 'meera'];

  /// Contacts not on Clarity yet — invite only, never stored server-side.
  static const List<({String id, String name, String initials})> contactsToInvite = [
    (id: 'baba', name: 'Baba', initials: 'B'),
    (id: 'sourav', name: 'Sourav Das', initials: 'SD'),
    (id: 'nikita', name: 'Nikita Roy', initials: 'NR'),
  ];

  /// Category counts shown on a friend's mini map.
  static const Map<String, List<(PlaceCategory, int)>> topCategoriesByPerson = {
    'rahul': [(PlaceCategory.trek, 14), (PlaceCategory.food, 11)],
    'priya': [(PlaceCategory.food, 22), (PlaceCategory.cafe, 12)],
    'asha': [(PlaceCategory.cafe, 9), (PlaceCategory.viewpoint, 7)],
  };

  // ── Places ──────────────────────────────────────────────────────────────

  static const List<Place> places = [
    Place(
      id: 'neermahal',
      name: 'Neermahal',
      area: 'Melaghar',
      address: 'Melaghar, Tripura',
      city: 'Melaghar',
      state: 'Tripura',
      category: PlaceCategory.viewpoint,
      mapPosition: Offset(280, 268),
    ),
    Place(
      id: 'tripura-sundari',
      name: 'Tripura Sundari Temple',
      area: 'Udaipur',
      address: 'Udaipur, Gomati',
      city: 'Udaipur',
      state: 'Tripura',
      category: PlaceCategory.temple,
      mapPosition: Offset(200, 348),
      distance: '54 km',
    ),
    Place(
      id: 'jampui',
      name: 'Jampui Hills',
      area: 'North Tripura',
      address: 'North Tripura',
      city: 'Jampui Hills',
      state: 'Tripura',
      category: PlaceCategory.trek,
      mapPosition: Offset(330, 128),
    ),
    Place(
      id: 'momo',
      name: 'Hilltop Momo Stall',
      area: 'Agartala',
      address: 'Battala, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.food,
      mapPosition: Offset(104, 194),
      distance: '1.6 km',
    ),
    Place(
      id: 'lakeside-cafe',
      name: 'Lakeside Reading Café',
      area: 'Agartala',
      address: 'Lake Road, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.cafe,
      mapPosition: Offset(64, 300),
      distance: '0.8 km',
    ),
    Place(
      id: 'rudra-homestay',
      name: 'Rudra Homestay',
      area: 'Melaghar',
      address: 'Melaghar, Tripura',
      city: 'Melaghar',
      state: 'Tripura',
      category: PlaceCategory.stay,
      mapPosition: Offset(214, 150),
    ),
    Place(
      id: 'night-chaat',
      name: 'Night Market Chaat',
      area: 'Agartala',
      address: 'Night Market, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.food,
      mapPosition: Offset(290, 350),
    ),
    Place(
      id: 'ujjayanta',
      name: 'Ujjayanta Palace',
      area: 'Agartala',
      address: 'Palace Compound, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.viewpoint,
      distance: '1.2 km',
    ),
    Place(
      id: 'rabindra-kanan',
      name: 'Rabindra Kanan',
      area: 'Agartala',
      address: 'Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.viewpoint,
      distance: '2.1 km',
    ),
    Place(
      id: 'heritage-park',
      name: 'Heritage Park',
      area: 'Agartala',
      address: 'Kunjaban, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.trek,
      distance: '3.4 km',
    ),
    Place(
      id: 'lake-road-books',
      name: 'Lake Road Book Store',
      area: 'Agartala',
      address: 'Lake Road, Agartala',
      city: 'Agartala',
      state: 'Tripura',
      category: PlaceCategory.other,
      distance: '40 m',
    ),
    Place(
      id: 'dzukou',
      name: 'Dzükou Valley',
      area: 'Nagaland',
      address: 'Kohima, Nagaland',
      city: 'Kohima',
      state: 'Nagaland',
      category: PlaceCategory.trek,
    ),
    Place(
      id: 'ward-lake',
      name: 'Ward Lake',
      area: 'Shillong',
      address: 'Shillong, Meghalaya',
      city: 'Shillong',
      state: 'Meghalaya',
      category: PlaceCategory.viewpoint,
    ),
  ];

  /// Results for the "Search" mode of Add a place (Google Places later).
  static const List<String> addPlaceSearchIds = [
    'ujjayanta',
    'rabindra-kanan',
    'heritage-park',
    'lakeside-cafe',
    'momo',
    'tripura-sundari',
  ];

  /// "Are you at…" candidates for the "I'm here" mode (GPS later).
  static const List<({String placeId, String distance})> nearbyHere = [
    (placeId: 'lakeside-cafe', distance: '12 m'),
    (placeId: 'lake-road-books', distance: '40 m'),
  ];

  /// Places in the demo account's history that aren't modelled one by one.
  static const Map<PlaceCategory, int> olderCategoryCounts = {
    PlaceCategory.food: 9,
    PlaceCategory.viewpoint: 7,
    PlaceCategory.cafe: 5,
    PlaceCategory.trek: 4,
  };

  /// Spare spots on the illustrated map for places you add during a session.
  static const List<Offset> freeMapSlots = [
    Offset(176, 96),
    Offset(250, 206),
    Offset(36, 238),
    Offset(352, 300),
    Offset(130, 340),
    Offset(356, 200),
    Offset(60, 120),
  ];

  // ── Visits ──────────────────────────────────────────────────────────────

  static DateTime _d(int y, int m, [int d = 15]) => DateTime(y, m, d);

  /// The demo account's own reviews.
  static final List<Visit> myVisits = [
    Visit(
      id: 'v-momo',
      placeId: 'momo',
      authorId: meId,
      date: _d(2026, 9, 6),
      rating: 4.2,
      tip: 'Order the fried pork momos, skip the soup.',
      text: 'Tiny stall, big flavour. The fried pork momos are the reason to come.',
      companions: ['Asha'],
      tags: ['Worth it'],
      budgetPerPerson: 150,
      photoCount: 2,
    ),
    Visit(
      id: 'v-neermahal',
      placeId: 'neermahal',
      authorId: meId,
      date: _d(2026, 8, 9),
      rating: 4.5,
      tip: 'Take the boat from the jetty; sunset is the best hour.',
      text:
          'A palace right in the middle of the lake. The boat ride over is half the fun. '
          'Inside is a bit bare, but the views from the terrace are worth it.',
      companions: ['Rahul'],
      tags: ['Worth it', 'Best at sunset', 'Good for groups'],
      budgetPerPerson: 400,
      photoCount: 4,
      verified: true,
    ),
    Visit(
      id: 'v-rudra',
      placeId: 'rudra-homestay',
      authorId: meId,
      date: _d(2026, 8, 8),
      rating: 4.4,
      tip: 'Ask for the lake-facing room upstairs.',
      companions: ['Rahul'],
      budgetPerPerson: 1200,
      photoCount: 1,
    ),
    Visit(
      id: 'v-lakeside',
      placeId: 'lakeside-cafe',
      authorId: meId,
      date: _d(2026, 7, 12),
      rating: 3.5,
      tip: 'Quiet before noon, good for work, weak Wi‑Fi.',
      companions: ['solo'],
      tags: ['Solo-friendly'],
      budgetPerPerson: 350,
    ),
    Visit(
      id: 'v-chaat',
      placeId: 'night-chaat',
      authorId: meId,
      date: _d(2026, 6, 20),
      recommended: false,
      rating: 3.0,
      tip: 'Busy after 8pm; parking is tough.',
      companions: ['Priya'],
      tags: ['Skip it'],
      budgetPerPerson: 120,
    ),
    Visit(
      id: 'v-temple',
      placeId: 'tripura-sundari',
      authorId: meId,
      date: _d(2026, 3, 2),
      rating: 4.0,
      tip: 'Go early on weekdays to skip the queue.',
      companions: ['family'],
      tags: ['Go early'],
    ),
    Visit(
      id: 'v-jampui',
      placeId: 'jampui',
      authorId: meId,
      date: _d(2025, 11, 10),
      rating: 4.8,
      tip: 'November for the orange festival; carry a jacket.',
      companions: ['solo'],
      tags: ['Worth it'],
    ),
  ];

  /// Friends' reviews — what powers "Who's been here" and friends' ratings.
  static final List<Visit> friendVisits = [
    Visit(
      id: 'f-rahul-dzukou',
      placeId: 'dzukou',
      authorId: 'rahul',
      date: now.subtract(const Duration(hours: 2)),
      rating: 5.0,
      tip: 'Start before 6am, the last stretch is steep.',
      text: 'Hardest climb of my life and worth every step. Start before 6am.',
    ),
    Visit(
      id: 'f-rahul-jampui',
      placeId: 'jampui',
      authorId: 'rahul',
      date: _d(2026, 3, 14),
      rating: 4.0,
      tip: 'Orange season is November; book the homestay early.',
    ),
    Visit(
      id: 'f-rahul-heritage',
      placeId: 'heritage-park',
      authorId: 'rahul',
      date: _d(2026, 1, 25),
      rating: 3.5,
      tip: 'Fine for a morning walk, not a real trek.',
    ),
    Visit(
      id: 'f-rahul-neermahal',
      placeId: 'neermahal',
      authorId: 'rahul',
      date: _d(2026, 8, 9),
      rating: 5.0,
      tip: 'Boat ride plus sunset is unbeatable.',
      text: 'Boat ride plus sunset is unbeatable. Go on a weekday.',
      companions: ['you'],
    ),
    Visit(
      id: 'f-rahul-rudra',
      placeId: 'rudra-homestay',
      authorId: 'rahul',
      date: _d(2026, 8, 8),
      rating: 4.0,
      tip: 'Simple rooms, great breakfast.',
      text: 'Simple rooms, great breakfast.',
      companions: ['you'],
    ),
    Visit(
      id: 'f-asha-neermahal',
      placeId: 'neermahal',
      authorId: 'asha',
      date: _d(2026, 2, 14),
      rating: 4.5,
      tip: 'Carry snacks, nothing to eat on the island.',
      text: 'Carry snacks, nothing to eat on the island.',
    ),
    Visit(
      id: 'f-priya-neermahal',
      placeId: 'neermahal',
      authorId: 'priya',
      date: _d(2025, 12, 20),
      rating: 4.0,
      tip: 'Go early, the jetty queue gets long.',
      text: 'Pretty from the shore too. Go early, the jetty queue gets long.',
    ),
    Visit(
      id: 'f-meera-neermahal',
      placeId: 'neermahal',
      authorId: 'meera',
      date: _d(2025, 10, 3),
      rating: 4.5,
      tip: 'Light and sound show is worth staying for.',
      text: 'Stay for the light and sound show if you can.',
    ),
    Visit(
      id: 'f-kabir-neermahal',
      placeId: 'neermahal',
      authorId: 'kabir',
      date: _d(2025, 4, 18),
      rating: 5.0,
      tip: 'Hire a private boat if you are four or more.',
      text: 'Hire a private boat if you are four or more. Totally worth it.',
    ),
    Visit(
      id: 'f-priya-momo',
      placeId: 'momo',
      authorId: 'priya',
      date: now.subtract(const Duration(days: 1)),
      rating: 4.0,
      tip: 'The fried ones really are better.',
      text: 'Thanks Bodhi, went because of your pin. The fried ones really are better.',
    ),
    Visit(
      id: 'f-asha-ward',
      placeId: 'ward-lake',
      authorId: 'asha',
      date: _d(2026, 9, 28),
      rating: 4.0,
      tip: 'Paddle boats close at 5pm.',
      text: 'Lovely for an evening walk. Paddle boats close at 5pm.',
    ),
    Visit(
      id: 'f-asha-lakeside',
      placeId: 'lakeside-cafe',
      authorId: 'asha',
      date: _d(2026, 8, 30),
      rating: 4.0,
      tip: 'Try the cold coffee.',
    ),
    Visit(
      id: 'f-meera-lakeside',
      placeId: 'lakeside-cafe',
      authorId: 'meera',
      date: _d(2026, 5, 2),
      rating: 4.0,
      tip: 'Window seats go first.',
    ),
  ];

  // ── Feed, notifications, lists ─────────────────────────────────────────

  static const List<FeedPost> feed = [
    FeedPost(
      id: 'a',
      type: FeedPostType.visit,
      authorId: 'rahul',
      verb: 'visited',
      subject: 'Dzükou Valley',
      when: '2h',
      placeId: 'dzukou',
      category: PlaceCategory.trek,
      rating: 5.0,
      quote: 'Hardest climb of my life and worth every step. Start before 6am.',
      likes: 8,
    ),
    FeedPost(
      id: 'a-badge',
      type: FeedPostType.badge,
      authorId: 'rahul',
      verb: 'earned',
      subject: 'Trekker I',
      when: '2h',
      quote: 'Review different treks and hikes.',
      likes: 2,
      badgeId: 'trekker',
    ),
    FeedPost(
      id: 'b',
      type: FeedPostType.ask,
      authorId: 'asha',
      verb: 'is going to',
      subject: 'Shillong',
      when: '5h',
      quote: 'Going next week for 3 days. Cafés and one easy hike?',
      footnote: '4 friends replied with pins',
      likes: 2,
    ),
    FeedPost(
      id: 'c',
      type: FeedPostType.visit,
      authorId: 'priya',
      verb: 'visited',
      subject: 'Hilltop Momo Stall',
      when: 'Yesterday',
      placeId: 'momo',
      category: PlaceCategory.food,
      rating: 4.0,
      quote: 'Thanks Bodhi, went because of your pin. The fried ones really are better.',
      likes: 5,
    ),
    FeedPost(
      id: 'd',
      type: FeedPostType.list,
      authorId: 'priya',
      verb: 'added 3 places to',
      subject: 'Goa trip 2027',
      when: '2d',
      quote: 'Goa trip 2027',
      footnote: '9 places · 4 friends',
      likes: 3,
    ),
  ];

  static const List<AppNotification> notifications = [
    AppNotification(
      id: 'j',
      kind: NotificationKind.joined,
      personId: 'rahul',
      initials: 'RS',
      who: 'Rahul',
      text: 'from your contacts just joined Clarity.',
      when: '10m',
      cta: 'Open his map',
      unread: true,
    ),
    AppNotification(
      id: 'r',
      kind: NotificationKind.friendRequest,
      personId: 'sneha',
      initials: 'SG',
      who: 'Sneha Ghosh',
      text: 'sent you a friend request.',
      when: '1h',
      unread: true,
    ),
    AppNotification(
      id: 'l',
      kind: NotificationKind.liked,
      personId: 'priya',
      initials: 'PK',
      who: 'Priya and 3 others',
      text: 'liked your review of Neermahal.',
      when: '3h',
      unread: true,
    ),
    AppNotification(
      id: 'c',
      kind: NotificationKind.thanks,
      personId: 'asha',
      initials: 'AD',
      who: 'Asha',
      text: 'went to Hilltop Momo Stall because of you. "Thanks, went there!"',
      when: 'Tue',
      isToday: false,
    ),
    AppNotification(
      id: 'n',
      kind: NotificationKind.nudge,
      initials: 'C',
      who: 'Clarity:',
      text: 'You were at Lakeside Reading Café for 40 minutes. Rate it while it’s fresh?',
      when: 'Mon',
      cta: 'Rate it',
      isToday: false,
    ),
    AppNotification(
      id: 'i',
      kind: NotificationKind.listInvite,
      personId: 'priya',
      initials: 'PK',
      who: 'Priya',
      text: 'added you to the list Goa trip 2027.',
      when: 'Sun',
      cta: 'View list',
      isToday: false,
    ),
  ];

  static const CollabList goaTrip = CollabList(
    id: 'goa-2027',
    title: 'Goa trip 2027',
    planning: 'planning for Jan 2027',
    ownerId: 'priya',
    memberIds: ['me', 'priya', 'rahul', 'asha'],
    items: [
      CollabListItem(
        id: 'a',
        name: 'Butterfly Beach',
        category: PlaceCategory.beach,
        status: 'Want to go',
        addedBy: 'Priya',
        votes: 3,
      ),
      CollabListItem(
        id: 'b',
        name: 'Fort Aguada',
        category: PlaceCategory.viewpoint,
        status: 'Rahul visited',
        addedBy: 'Rahul',
        votes: 3,
      ),
      CollabListItem(
        id: 'c',
        name: 'Fontainhas walk',
        category: PlaceCategory.other,
        status: 'Want to go',
        addedBy: 'you',
        votes: 2,
      ),
      CollabListItem(
        id: 'd',
        name: 'Dudhsagar Falls',
        category: PlaceCategory.trek,
        status: 'Asha visited',
        addedBy: 'Asha',
        votes: 2,
      ),
      CollabListItem(
        id: 'e',
        name: 'Beach shack, Palolem',
        category: PlaceCategory.food,
        status: 'Want to go',
        addedBy: 'Priya',
        votes: 1,
      ),
      CollabListItem(
        id: 'f',
        name: 'Hostel in Anjuna',
        category: PlaceCategory.stay,
        status: 'Want to go',
        addedBy: 'Rahul',
        votes: 1,
      ),
    ],
  );

  /// The two lists on the profile screen.
  static const List<({String title, String subtitle})> myLists = [
    (title: 'Goa trip 2027', subtitle: '6 places · with Priya, Rahul, Asha'),
    (title: 'Agartala food crawl', subtitle: '11 places · just you'),
  ];

  static const List<String> recentSearches = ['Shillong', 'Rahul', 'momo', 'Goa'];
  static const List<String> askSuggestions = [
    'quiet café where friends said the coffee is good',
    'best sunset spot near Agartala',
  ];
}
