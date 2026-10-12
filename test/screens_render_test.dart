// Renders every screen at the design's iPhone size and fails on any layout
// error (overflow, unbounded constraints, missing route arguments).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clarity/app/clarity_app.dart';
import 'package:clarity/app/routes.dart';
import 'package:clarity/core/state/app_state.dart';
import 'package:clarity/features/friends/find_friends_screen.dart';
import 'package:clarity/features/review/write_review_screen.dart';

void main() {
  final screens = <String, (String, Object?)>{
    'welcome': (Routes.welcome, null),
    'phone': (Routes.phone, null),
    'otp': (Routes.otp, null),
    'privacy': (Routes.privacy, null),
    'terms': (Routes.terms, null),
    'all badges': (Routes.badges, null),
    'unlock (first badge)': (Routes.unlock, ['first_pin']),
    'unlock (level up)': (Routes.unlock, ['cities']),
    'unlock (two at once)': (Routes.unlock, ['straight_talker', 'hidden_gem']),
    'create profile': (Routes.createProfile, null),
    'permissions': (Routes.permissions, null),
    'consent': (Routes.consent, true),
    'find friends': (Routes.findFriends, const FindFriendsArgs()),
    'add place': (Routes.addPlace, null),
    'review': (Routes.review, const ReviewArgs('neermahal', editing: true)),
    'place detail': (Routes.place, 'neermahal'),
    'place without reviews': (Routes.place, 'ujjayanta'),
    'search': (Routes.search, null),
    'friend profile': (Routes.friend, 'rahul'),
    'notifications': (Routes.notifications, null),
    'settings': (Routes.settings, null),
    'collab list': (Routes.collabList, null),
    'offline': (Routes.offline, null),
  };

  for (final MapEntry(key: name, value: (route, args)) in screens.entries) {
    testWidgets('renders $name', (tester) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
      await tester.pump(const Duration(milliseconds: 300));
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pushNamed(route, arguments: args);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }

  for (final tab in AppTab.values) {
    for (final newUser in [false, true]) {
      testWidgets('renders ${tab.name} tab (${newUser ? 'new' : 'demo'} account)', (tester) async {
        tester.view.physicalSize = const Size(390, 844) * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
        await tester.pump(const Duration(milliseconds: 300));
        final state = AppScope.read(tester.element(find.byType(Navigator).first));
        if (newUser) state.startNewAccount();
        state.selectTab(tab);
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
