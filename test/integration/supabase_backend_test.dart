// End-to-end check of SupabaseBackend against a seeded Supabase (normally
// the local stack). Skipped unless SUPABASE_TEST_URL and SUPABASE_TEST_KEY are
// set, so `flutter test` and CI stay offline.
//
//   supabase start -x realtime,storage-api,imgproxy,mailpit,postgres-meta,studio,edge-runtime,logflare,vector,supavisor
//   supabase db reset --local      # fresh seed
//   SUPABASE_TEST_URL=http://127.0.0.1:54321 SUPABASE_TEST_KEY=<publishable key from `supabase status`> \
//     flutter test test/integration/supabase_backend_test.dart
//
// It writes to the database (a visit, a save, an accepted request); run
// `supabase db reset --local` afterwards to get the seed back.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:clarity/core/data/supabase_backend.dart';
import 'package:clarity/core/models/visit.dart';
import 'package:clarity/core/state/app_state.dart';

void main() {
  final url = Platform.environment['SUPABASE_TEST_URL'];
  final key = Platform.environment['SUPABASE_TEST_KEY'];
  final skip = url == null || key == null ? 'Set SUPABASE_TEST_URL and SUPABASE_TEST_KEY to run' : null;

  const bodhi = 'a0000000-0000-4000-8000-000000000001';
  const rahul = 'a0000000-0000-4000-8000-000000000002';
  const tanmoy = 'a0000000-0000-4000-8000-000000000008';
  const dzukou = 'b0000000-0000-4000-8000-00000000000c';

  late AppState state;

  setUpAll(() async {
    if (skip != null) return;
    // flutter_test blocks real HTTP by default; this test needs it.
    HttpOverrides.global = null;
    final client = SupabaseClient(
      url!,
      key!,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit, autoRefreshToken: false),
    );
    state = AppState(backend: SupabaseBackend(client));
  });

  test('signs in with the demo test number', () async {
    state.setPhone(countryCode: '+91', digits: '9876543210');
    expect(await state.sendCode(), isNull);
    expect(await state.verifyCode('123456'), isNull);
    expect(state.isSignedIn, isTrue);
    expect(state.hasProfile, isTrue);
    expect(state.isNewAccount, isFalse);
  }, skip: skip);

  test('loads the seeded account', () {
    expect(state.me.id, bodhi);
    expect(state.name, 'Bodhi Chakraborty');
    expect(state.myVisits, hasLength(7));
    expect(state.friends.map((p) => p.firstName), containsAll(['Rahul', 'Priya', 'Asha', 'Meera', 'Kabir']));
    expect(state.requests.map((p) => p.firstName), containsAll(['Tanmoy', 'Sneha', 'Dev']));
    expect(state.sentRequests.single.firstName, 'Arjun');
    expect(state.person(rahul).tasteMatch, 91);
    expect(state.notifications, hasLength(6));
    expect(state.unreadCount, 3);
    expect(state.lists.map((l) => l.title), containsAll(['Goa trip 2027', 'Agartala food crawl']));
    expect(state.list(null)!.items, hasLength(6));
    expect(state.friendVisitsFor('b0000000-0000-4000-8000-000000000001'), hasLength(5));
    expect(state.nearbyHere.first.place.name, 'Lakeside Reading Café');
    expect(state.placesCount, 7);
    expect(state.myVisits.every((v) => state.place(v.placeId).mapPosition != null), isTrue);
    final chaat = state.myVisitFor('b0000000-0000-4000-8000-000000000007')!;
    expect(chaat.recommended, isFalse);
    expect(chaat.budgetPerPerson, 120);
    expect(chaat.budgetLevel, '₹');
    // Badges come from the database (my_badges) and match the app's own count.
    expect(
      state.badges.where((b) => b.earned).map((b) => b.id),
      containsAll(['first_pin', 'map_sharer', 'hidden_gem']),
    );
    expect(state.badgesEarned, 12);
    expect(state.pendingUnlocks, isEmpty, reason: 'seeded badges are marked as seen');
    expect(state.badgesOf(rahul), isNotEmpty, reason: 'friends see each other\'s badges');
  }, skip: skip);

  test('loads the friends feed', () async {
    state.loadFeed();
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(state.feedStatus, FeedStatus.ready);
    expect(state.feed.first.subject, 'Dzükou Valley');
    expect(state.feed.first.likes, 8);
  }, skip: skip);

  test('writes reach the database', () async {
    final id = state.newVisitId(dzukou);
    state.saveVisit(
      Visit(
        id: id,
        placeId: dzukou,
        authorId: state.me.id,
        date: DateTime(2026, 10, 1),
        rating: 4.5,
        tip: 'Carry rain gear.',
        recommended: false,
        tags: const ['Worth it', 'Leeches in monsoon'],
        budgetPerPerson: 900,
      ),
    );
    state.toggleSaved(dzukou);
    state.acceptRequest(tanmoy);
    state.markAllNotificationsRead();
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(state.syncError, isNull);

    await state.reload();
    expect(state.myVisitFor(dzukou)?.id, id);
    expect(state.myVisitFor(dzukou)?.recommended, isFalse);
    expect(state.myVisitFor(dzukou)?.tags, contains('Leeches in monsoon'));
    expect(state.myVisitFor(dzukou)?.budgetLabel, '₹₹₹ · ₹900 per person');
    expect(state.isSaved(dzukou), isTrue);
    expect(state.isFriend(tanmoy), isTrue);
    expect(state.unreadCount, 0);
  }, skip: skip);

  test('creates a list with a place and adds another', () async {
    final created = await state.createList('Integration trip', placeId: dzukou);
    expect(created.error, isNull);
    state.toggleInList(created.listId!, 'b0000000-0000-4000-8000-000000000001');
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(state.syncError, isNull);

    await state.reload();
    final list = state.list(created.listId)!;
    expect(list.title, 'Integration trip');
    expect(list.memberIds, [bodhi]);
    expect(list.items.map((i) => i.placeId), containsAll([dzukou, 'b0000000-0000-4000-8000-000000000001']));

    state.toggleInList(list.id, dzukou);
    await Future<void>.delayed(const Duration(seconds: 2));
    await state.reload();
    expect(state.isInList(list.id, dzukou), isFalse);
  }, skip: skip);

  test('signs out', () async {
    await state.signOut();
    expect(state.isSignedIn, isFalse);
    expect(state.myVisits, isEmpty);
  }, skip: skip);
}
