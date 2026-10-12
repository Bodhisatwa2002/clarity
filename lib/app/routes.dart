import 'package:flutter/cupertino.dart';

import '../features/add_place/add_place_screen.dart';
import '../features/badges/all_badges_screen.dart';
import '../features/badges/unlock_screen.dart';
import '../features/friends/find_friends_screen.dart';
import '../features/friends/friend_profile_screen.dart';
import '../features/legal/legal_content.dart';
import '../features/legal/legal_screen.dart';
import '../features/lists/collab_list_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/contacts_consent_screen.dart';
import '../features/onboarding/create_profile_screen.dart';
import '../features/onboarding/otp_screen.dart';
import '../features/onboarding/permissions_screen.dart';
import '../features/onboarding/phone_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/place/place_detail_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/review/write_review_screen.dart';
import '../features/search/search_screen.dart';
import '../features/shared/widgets/app_shell.dart';
import '../features/system/offline_screen.dart';

/// Named routes for every full-screen page.
///
/// Arguments: [place] takes a place id, [review] a place id or [ReviewArgs],
/// [friend] a person id, [findFriends] a [FindFriendsArgs], [consent]
/// `true` when shown during onboarding, and [unlock] the ids of one or two
/// newly earned badges.
abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const phone = '/phone';
  static const otp = '/otp';
  static const createProfile = '/create-profile';
  static const permissions = '/permissions';
  static const consent = '/consent';
  static const findFriends = '/find-friends';
  static const home = '/home';
  static const addPlace = '/add-place';
  static const review = '/review';
  static const place = '/place';
  static const search = '/search';
  static const friend = '/friend';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const collabList = '/list';
  static const offline = '/offline';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const badges = '/badges';
  static const unlock = '/unlock';

  static Route<dynamic> generate(RouteSettings route) {
    final args = route.arguments;
    final Widget page = switch (route.name) {
      splash => const SplashScreen(),
      welcome => const WelcomeScreen(),
      phone => const PhoneScreen(),
      otp => const OtpScreen(),
      createProfile => const CreateProfileScreen(),
      permissions => const PermissionsScreen(),
      consent => ContactsConsentScreen(fromOnboarding: args == true),
      findFriends => FindFriendsScreen(args: args as FindFriendsArgs? ?? const FindFriendsArgs()),
      home => const AppShell(),
      addPlace => const AddPlaceScreen(),
      review => WriteReviewScreen(args: args is ReviewArgs ? args : ReviewArgs(args! as String)),
      place => PlaceDetailScreen(placeId: args! as String),
      search => const SearchScreen(),
      friend => FriendProfileScreen(personId: args! as String),
      notifications => const NotificationsScreen(),
      settings => const SettingsScreen(),
      collabList => CollabListScreen(listId: args as String?),
      offline => const OfflineScreen(),
      privacy => const LegalScreen(doc: LegalDoc.privacy),
      terms => const LegalScreen(doc: LegalDoc.terms),
      badges => const AllBadgesScreen(),
      unlock => UnlockScreen(badgeIds: (args as List?)?.cast<String>() ?? const ['first_pin']),
      _ => throw ArgumentError('Unknown route ${route.name}'),
    };

    // Fade between the top-level stages and into a badge unlock; slide
    // everything else, iOS style.
    if (route.name == welcome || route.name == home || route.name == unlock) {
      return PageRouteBuilder<void>(
        settings: route,
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      );
    }
    final modal = route.name == addPlace || route.name == review;
    return CupertinoPageRoute<void>(settings: route, fullscreenDialog: modal, builder: (_) => page);
  }
}
