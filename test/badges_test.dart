// Badges and milestones (PRD §9.15): the rules, and the moments that show them.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clarity/app/clarity_app.dart';
import 'package:clarity/app/routes.dart';
import 'package:clarity/core/badges/badge_catalog.dart';
import 'package:clarity/core/badges/badge_engine.dart';
import 'package:clarity/core/badges/festivals.dart';
import 'package:clarity/core/data/mock_backend.dart';
import 'package:clarity/core/data/mock_data.dart';
import 'package:clarity/core/models/badge.dart';
import 'package:clarity/core/models/place.dart';
import 'package:clarity/core/models/place_category.dart';
import 'package:clarity/core/models/visit.dart';
import 'package:clarity/core/state/app_state.dart';
import 'package:clarity/features/badges/badge_share_sheet.dart';
import 'package:clarity/features/review/write_review_screen.dart';
import 'package:clarity/features/share/share_sheet.dart';

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _settle(WidgetTester tester, [int steps = 8]) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Visit _visit(
  String placeId, {
  String author = MockData.meId,
  DateTime? date,
  double rating = 4,
  bool recommended = true,
}) => Visit(
  id: 'v-$author-$placeId-${date?.millisecondsSinceEpoch ?? 0}',
  placeId: placeId,
  authorId: author,
  date: date ?? DateTime(2026, 10, 1),
  rating: rating,
  tip: 'A tip.',
  recommended: recommended,
);

void main() {
  group('rules', () {
    test('the catalogue matches the rows the migrations insert', () {
      final sql = Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('badges'))
          .map((f) => f.readAsStringSync())
          .join('\n');
      final rows =
          RegExp(r"\('([a-z_]+)',\s+'([a-z_]+)',.*?'(\{[0-9,]+\})',\s+(true|false),\s+(\d+)\)")
              .allMatches(sql)
              .map((m) => (id: m[1]!, levels: m[3]!, secret: m[4] == 'true', sort: int.parse(m[5]!)))
              .toList()
            ..sort((a, b) => a.sort.compareTo(b.sort));
      expect(rows.map((r) => r.id), BadgeCatalog.all.map((b) => b.id), reason: 'same badges, same order');
      for (final (row, def) in [for (var i = 0; i < rows.length; i++) (rows[i], BadgeCatalog.all[i])]) {
        expect(row.levels, '{${def.levels.join(',')}}', reason: '${def.id} thresholds');
        expect(row.secret, def.isSecret, reason: '${def.id} secret');
      }
    });

    test('the demo account earns the same 12 badges the seeded database awards Bodhi', () {
      final state = AppState(backend: MockBackend())..signInExisting();
      expect(state.badges.where((b) => b.earned).map((b) => b.id).toSet(), {
        'first_pin',
        'one_thing',
        'first_friend',
        'list_maker',
        'map_sharer',
        'cities',
        'been_there',
        'straight_talker',
        'taste_twin',
        'squad_explorer',
        'monsoon_wanderer',
        'hidden_gem',
      });
      expect(state.pendingUnlocks, isEmpty, reason: 'what you already had is not news');
      expect(state.nextBadge?.id, 'places', reason: '7 of 10 is the closest');
    });

    test('specialists count different places, not visits; Regular counts going back', () {
      const cafe = Place(id: 'c', name: 'Café', area: 'Agartala', address: '', category: PlaceCategory.cafe);
      final counts = BadgeEngine.count(
        personId: MockData.meId,
        mine: [
          _visit('c', date: DateTime(2026, 1, 1)),
          _visit('c', date: DateTime(2026, 2, 1)),
          _visit('c', date: DateTime(2026, 3, 1)),
        ],
        place: (_) => cafe,
      );
      expect(counts['cafe_hopper']!.progress, 1);
      expect(counts['regular']!.progress, 3);
    });

    test('Hidden gem: you went first and a friend followed', () {
      final counts = BadgeEngine.count(
        personId: MockData.meId,
        mine: [
          _visit('neermahal', date: DateTime(2026, 1, 1)),
          _visit('jampui', date: DateTime(2026, 5, 1)),
        ],
        place: (id) => MockData.places.firstWhere((p) => p.id == id),
        friendVisits: [
          _visit('neermahal', author: 'rahul', date: DateTime(2026, 2, 1)),
          _visit('jampui', author: 'rahul', date: DateTime(2026, 4, 1)),
        ],
      );
      expect(counts['hidden_gem']!.placeIds, ['neermahal']);
    });

    test('Taste twin needs 2 shared places', () {
      Map<String, BadgeCount> count(List<String> shared) => BadgeEngine.count(
        personId: MockData.meId,
        mine: [for (final id in shared) _visit(id, rating: 5)],
        place: (id) => MockData.places.firstWhere((p) => p.id == id),
        friendVisits: [for (final id in shared) _visit(id, author: 'rahul', rating: 4.5)],
      );
      expect(count(['neermahal'])['taste_twin']!.progress, 0);
      expect(count(['neermahal', 'jampui'])['taste_twin']!.progress, 90);
    });

    test('a new level waits to be celebrated, once', () {
      final state = AppState(backend: MockBackend())..signInExisting();
      state.saveVisit(_visit('ujjayanta'));
      state.saveVisit(_visit('rabindra-kanan'));
      expect(state.pendingUnlocks.map((b) => b.titleWithLevel), ['Viewpoint chaser I']);
      state.markBadgesSeen(['viewpoint_chaser']);
      expect(state.pendingUnlocks, isEmpty);
      expect(state.badge('viewpoint_chaser').level, 1);
    });
  });

  group('moments', () {
    Future<(AppState, NavigatorState)> openHome(WidgetTester tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
      await _settle(tester);
      return (
        AppScope.read(tester.element(find.byType(Navigator))),
        tester.state<NavigatorState>(find.byType(Navigator)),
      );
    }

    Future<void> postReview(WidgetTester tester, NavigatorState nav, String placeId) async {
      nav.pushNamed(Routes.review, arguments: ReviewArgs(placeId));
      await _settle(tester);
      await tester.tap(find.bySemanticsLabel('4 stars'));
      await tester.enterText(find.byType(EditableText).first, 'Go before the crowds.');
      await tester.pump();
      await tester.tap(find.text('Post review'));
      await _settle(tester, 10);
    }

    testWidgets('a review that moves a badge shows the progress toast', (tester) async {
      final (_, nav) = await openHome(tester);
      await postReview(tester, nav, 'ujjayanta');
      expect(find.text('Review posted · Ujjayanta Palace counted'), findsOneWidget);
      expect(find.text('2 more places to Places I'), findsOneWidget, reason: 'the closest badge it moved: 8 of 10');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('the review that completes a badge opens the unlock', (tester) async {
      final (state, nav) = await openHome(tester);
      state
        ..saveVisit(_visit('ujjayanta'))
        ..markBadgesSeen([]);
      await postReview(tester, nav, 'rabindra-kanan');
      await _settle(tester, 16);
      expect(find.text('NEW BADGE'), findsOneWidget);
      expect(find.textContaining('Viewpoint chaser I'), findsWidgets);
      expect(state.pendingUnlocks, isEmpty, reason: 'opening the unlock marks it seen');

      await tester.tap(find.text('Keep exploring'));
      await _settle(tester);
      expect(find.text('NEW BADGE'), findsNothing);
      expect(find.text('Rabindra Kanan'), findsWidgets, reason: 'back on the place');
    });

    testWidgets('a new account: copying your map link unlocks Map sharer', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      final (state, nav) = await openHome(tester);
      state.startNewAccount();
      await tester.pump();
      expect(find.text('Get started · 0 of 5'), findsOneWidget, reason: 'on the empty map');

      showShareSheet(tester.element(find.byType(Navigator)), target: ShareTarget.map);
      await _settle(tester);
      await tester.tap(find.text('Copy'));
      await tester.pump();
      nav.pop();
      await _settle(tester, 12);
      expect(find.textContaining('Map sharer'), findsWidgets);
      expect(state.badge('map_sharer').earned, isTrue);
    });

    testWidgets('All badges filters to what is in progress', (tester) async {
      final (_, nav) = await openHome(tester);
      nav.pushNamed(Routes.badges);
      await _settle(tester);
      expect(find.text('12 of 27 earned'), findsOneWidget);
      expect(find.text('First pin'), findsOneWidget);
      await tester.tap(find.text('In progress'));
      await tester.pump();
      expect(find.text('First pin'), findsNothing);
      expect(find.text('Places'), findsOneWidget);
    });

    testWidgets("a friend's new badge takes one Congrats", (tester) async {
      final (state, nav) = await openHome(tester);
      nav.pushNamed(Routes.friend, arguments: 'rahul');
      await _settle(tester);
      await tester.scrollUntilVisible(find.text('Congrats'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.textContaining('Trekker I'), findsWidgets);
      expect(find.text('Priya and Asha said congrats'), findsOneWidget);

      await tester.tap(find.text('Congrats'));
      await tester.pump();
      expect(find.text('Congrats sent'), findsOneWidget);
      expect(find.text('You, Priya and Asha said congrats'), findsOneWidget);
      expect(state.congratsFor('rahul', 'trekker'), contains(state.me.id));
    });

    testWidgets('a friend\'s badge in the feed takes Congrats', (tester) async {
      final (state, _) = await openHome(tester);
      state.selectTab(AppTab.feed);
      await _settle(tester, 25);
      expect(find.textContaining('Trekker I', findRichText: true), findsWidgets);
      expect(find.text('Review different treks and hikes.'), findsOneWidget);
      expect(find.text('Congrats · 2'), findsOneWidget);
      await tester.tap(find.text('Congrats · 2'));
      await tester.pump();
      expect(find.text('Congrats sent · 3'), findsOneWidget);
    });

    testWidgets('Thanks, went there! on a friend\'s review of a place you\'ve been', (tester) async {
      final (state, nav) = await openHome(tester);
      nav.pushNamed(Routes.place, arguments: 'neermahal');
      await _settle(tester);
      // The friends' reviews sit below the fold.
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await _settle(tester);
      await tester.tap(find.text('Thanks, went there!').first);
      await tester.pump();
      expect(find.textContaining('Thanked '), findsOneWidget);
      expect(state.badge('trusted_voice').progress, 2, reason: 'Asha and Priya went because of you');
      expect(state.friendVisitsFor('neermahal').where((v) => state.hasThanked(v.id)), hasLength(1));
      final rahul = state.friendVisitsFor('neermahal').firstWhere((v) => v.authorId == 'rahul');
      expect(state.canThank(rahul), isFalse, reason: 'you went with Rahul, not because of him');
    });

    testWidgets('the share card renders as a square, a Story and a stamp', (tester) async {
      await openHome(tester);
      showBadgeShareSheet(tester.element(find.byType(Navigator)), 'cities');
      await _settle(tester);
      for (final option in ['Story', 'Stamp', 'Square']) {
        await tester.tap(find.text(option));
        await tester.pump();
      }
      expect(find.text('Share image'), findsOneWidget);
      expect(find.text('Bodhi is now '), findsNothing, reason: 'the line is one rich text');
      expect(find.textContaining('Cities I'), findsWidgets);
    });

    testWidgets('the profile shows your next badge and the collection', (tester) async {
      final (state, _) = await openHome(tester);
      state.selectTab(AppTab.profile);
      await _settle(tester);
      await tester.scrollUntilVisible(find.text('Places I'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text('7 of 10'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('See all badges'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text('12 of 27'), findsOneWidget);
    });
  });

  test('the festival calendar matches the migration', () {
    final sql = File('supabase/migrations/20261013120000_badges_feed_thanks_festivals.sql').readAsStringSync();
    final rows = RegExp(r"\('([a-z0-9_]+)',\s+'([^']+)',\s*'(\d{4}-\d\d-\d\d)', '(\d{4}-\d\d-\d\d)'")
        .allMatches(sql)
        .map((m) => '${m[1]} ${m[3]} ${m[4]}')
        .toList();
    expect(rows, [
      for (final f in Festivals.all)
        '${f.id} ${f.starts.toIso8601String().substring(0, 10)} ${f.ends.toIso8601String().substring(0, 10)}',
    ]);
    expect(Festivals.on(DateTime(2026, 10, 18)), 'Durga Puja');
    expect(Festivals.on(DateTime(2026, 10, 25)), isNull);
  });

  test('Been there, Trusted voice and Festival lights', () {
    final counts = BadgeEngine.count(
      personId: MockData.meId,
      mine: [
        Visit(
          id: 'a',
          placeId: 'neermahal',
          authorId: MockData.meId,
          date: DateTime(2026, 10, 18),
          rating: 5,
          tip: 't',
          verified: true,
        ),
        _visit('jampui', date: DateTime(2026, 10, 25)),
      ],
      place: (id) => MockData.places.firstWhere((p) => p.id == id),
      friendsWhoWent: 5,
    );
    expect(counts['been_there']!.placeIds, ['neermahal'], reason: 'only the verified visit');
    expect(counts['festival_lights']!.placeIds, ['neermahal'], reason: 'Durga Puja 2026');
    expect(counts['trusted_voice']!.progress, 5);
  });

  test('BadgeProgress copy', () {
    const def = BadgeDef(
      id: 'trekker',
      group: BadgeGroup.specialist,
      title: 'Trekker',
      howTo: '',
      icon: 'trek',
      tone: Color(0xFF2B8A3E),
      levels: [3, 10, 25],
      unit: 'trek',
      unitPlural: 'treks',
    );
    const b = BadgeProgress(def: def, progress: 9, level: 1);
    expect(b.titleWithLevel, 'Trekker I');
    expect(b.nextStep, '1 more trek to Trekker II');
    expect(b.progressLabel, '9 of 10');
    expect(b.fraction, closeTo(6 / 7, 0.001));
  });
}
