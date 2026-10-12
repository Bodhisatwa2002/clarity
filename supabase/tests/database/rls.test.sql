-- Row-level security and function tests, run against the seeded database.
--
--   supabase test db                                  (via the CLI)
--   psql "$LOCAL_DB_URL" -f supabase/tests/database/rls.test.sql
--
-- Everything runs in one transaction and is rolled back, so the seed data is
-- left untouched. People: see supabase/seed.sql.

begin;
create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;

select plan(57);

-- Act as a signed-in user (what PostgREST does with the JWT).
create function pg_temp.login(who uuid) returns void language sql as $$
  select set_config('role', 'authenticated', true),
         set_config('request.jwt.claim.sub', who::text, true),
         set_config('request.jwt.claims', json_build_object('sub', who, 'role', 'authenticated')::text, true);
$$;

create function pg_temp.logout() returns void language sql as $$
  select set_config('role', 'postgres', true), set_config('request.jwt.claim.sub', '', true),
         set_config('request.jwt.claims', '', true);
$$;

\set bodhi    '''a0000000-0000-4000-8000-000000000001'''
\set rahul    '''a0000000-0000-4000-8000-000000000002'''
\set priya    '''a0000000-0000-4000-8000-000000000003'''
\set arjun    '''a0000000-0000-4000-8000-000000000007'''
\set tanmoy   '''a0000000-0000-4000-8000-000000000008'''
\set sneha    '''a0000000-0000-4000-8000-000000000009'''
\set rahuldey '''a0000000-0000-4000-8000-00000000000b'''

-- ── Schema basics ───────────────────────────────────────────────────────────

select ok((select bool_and(c.relrowsecurity) from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relkind = 'r'),
          'every public table has RLS enabled');

-- ── As Bodhi (5 friends: Rahul, Priya, Asha, Meera, Kabir) ─────────────────

select pg_temp.login(:bodhi);

select is((select count(*)::int from visits), 20, 'Bodhi sees his 7 visits + 13 of his friends');
select is((select count(*)::int from notifications), 6, 'Bodhi sees only his notifications');
select is((select count(*)::int from lists), 2, 'Bodhi sees the two lists he is in');
select is((select kind || ':' || subject from get_feed() limit 1), 'visit:Dzükou Valley', 'feed starts with Rahul''s latest visit');
select is((select footnote from get_feed() where kind = 'ask'), '4 friends replied with pins', 'ask footnote counts replies');
select is((select taste_match from profile_summaries(array[:bodhi, :rahul]::uuid[]) where profile_id = :rahul), 91, 'taste match with Rahul');
select is((select mutual_friends from profile_summaries(array[:sneha]::uuid[])), 3, 'Sneha has 3 mutual friends');
select is((select places_count from profile_summaries(array[:rahul]::uuid[])), 4, 'Rahul''s place count');
select is((select p.name from nearby_places(23.8361, 91.2832, 500) n join places p on p.id = n.place_id limit 1),
          'Lakeside Reading Café', 'nearest place to Lake Road');
select is((select count(*)::int from match_contacts(array['+91 90000 00001', '+919999999999'])), 1,
          'contact match returns only real, discoverable users');
select ok(not is_username_available('rahul') and is_username_available('newbie'), 'username availability');

select lives_ok($$ insert into visits (place_id, rating, tip) values ('b0000000-0000-4000-8000-00000000000c', 4.5, 'Carry rain gear.') $$,
                'Bodhi logs a visit');
select lives_ok($$ insert into visits (place_id, rating, tip, tags, budget_per_person)
                   values ('b0000000-0000-4000-8000-000000000009', 4, 'Quiet at noon.', array['Worth it', 'Peacocks on the lawn'], 0) $$,
                'custom tags and a free visit are accepted');
select throws_ok($$ insert into visits (place_id, rating, tip, tags)
                    values ('b0000000-0000-4000-8000-000000000009', 4, 'x', array_fill('tag'::text, array[11])) $$,
                 '23514', null, 'more than 10 tags is refused');
select throws_ok($$ insert into visits (place_id, rating, tip, tags)
                    values ('b0000000-0000-4000-8000-000000000009', 4, 'x', array['a tag that is far too long to fit']) $$,
                 '23514', null, 'a tag over 24 characters is refused');
select throws_ok($$ insert into visits (place_id, rating, tip) values ('b0000000-0000-4000-8000-000000000009', 0, 'x') $$,
                 '23514', null, 'every review needs a rating');
select lives_ok($$ insert into saved_places (place_id) values ('b0000000-0000-4000-8000-00000000000c') $$, 'Bodhi saves a place');
select lives_ok($$ update friendships set status = 'accepted'
                   where requester_id = 'a0000000-0000-4000-8000-000000000008' $$, 'Bodhi accepts Tanmoy''s request');
select lives_ok($$ insert into friendships (addressee_id) values ('a0000000-0000-4000-8000-00000000000b') $$,
                'Bodhi sends Rahul Dey a request');

-- Must be refused
select throws_ok($$ insert into visits (place_id, author_id, rating, tip)
                    values ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 5, 'x') $$,
                 '42501', null, 'cannot write a visit as someone else');
select throws_ok($$ update visits set verified = true, verified_by = 'gps' where id = 'c0000000-0000-4000-8000-000000000001' $$,
                 '42501', null, 'cannot mark own visit verified');
select throws_ok($$ insert into notifications (recipient_id, kind) values ('a0000000-0000-4000-8000-000000000002', 'nudge') $$,
                 '42501', null, 'cannot create notifications');
select throws_ok($$ insert into storage.objects (bucket_id, name) values ('visit-photos', 'a0000000-0000-4000-8000-000000000002/x/0.jpg') $$,
                 '42501', null, 'cannot upload into someone else''s photo folder');
select throws_ok($$ insert into friendships (addressee_id) values ('a0000000-0000-4000-8000-000000000003') $$,
                 '23505', null, 'cannot duplicate a friendship in the other direction');

select is_empty($$ update visits set tip = 'hacked' where id = 'c0000000-0000-4000-8000-000000000011' returning 1 $$,
                'cannot edit a friend''s visit');
select is_empty($$ update profiles set display_name = 'hacked' where id = 'a0000000-0000-4000-8000-000000000002' returning 1 $$,
                'cannot edit a friend''s profile');
select is_empty($$ delete from visits where id = 'c0000000-0000-4000-8000-000000000011' returning 1 $$,
                'cannot delete a friend''s visit');
select is_empty($$ update friendships set status = 'accepted'
                   where requester_id = 'a0000000-0000-4000-8000-000000000001'
                     and addressee_id = 'a0000000-0000-4000-8000-000000000007' returning 1 $$,
                'cannot accept your own outgoing request');

select pg_temp.logout();
select is((select count(*)::int from notifications where recipient_id = :rahuldey), 1,
          'a friend request notifies the addressee');

-- ── Badges (PRD §9.15) ──────────────────────────────────────────────────────

select pg_temp.login(:bodhi);
select is((select count(*)::int from badges), 27, 'the catalogue has 27 badges');
select is((select count(*)::int from my_badges()), 27, 'my_badges returns every badge');
select is((select progress from my_badges() where badge_id = 'trusted_voice'), 2, 'two friends said Thanks, went there');
select is((select progress from my_badges() where badge_id = 'been_there'), 1, 'one GPS-verified visit counts toward Been there');
select is((select kind || ':' || subject from get_feed() where kind = 'badge' limit 1), 'badge:States I',
          'the feed shows Rahul''s new badge');
select is((select level::int from user_badges where profile_id = :bodhi and badge_id = 'straight_talker'), 1,
          'an honest Not recommended earned Straight talker');
select throws_ok($$ insert into user_badges (profile_id, badge_id, level) values ('a0000000-0000-4000-8000-000000000001', 'trekker', 3) $$,
                 '42501', null, 'the app cannot award itself a badge');
select lives_ok($$ insert into visits (id, place_id, rating, tip) values
                     ('c9000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000008', 4, 'Go early.'),
                     ('c9000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000009', 4, 'Shady paths.') $$,
                'Bodhi reviews two more viewpoints');
select is((select level::int || '/' || seen_level from user_badges where profile_id = :bodhi and badge_id = 'viewpoint_chaser'),
          '1/0', 'the third viewpoint earns Viewpoint chaser I, waiting to be celebrated');
select lives_ok($$ select mark_badges_seen(array['viewpoint_chaser']) $$, 'the celebration is marked as seen');
select lives_ok($$ delete from visits where id in ('c9000000-0000-4000-8000-000000000001', 'c9000000-0000-4000-8000-000000000002') $$,
                'Bodhi deletes both reviews');
select is((select level::int || '/' || seen_level from user_badges where profile_id = :bodhi and badge_id = 'viewpoint_chaser'),
          '1/1', 'progress never goes backwards: the badge stays');

select pg_temp.logout();
select is((select count(*)::int from notifications where kind = 'thanks' and recipient_id = :bodhi and actor_id = :rahul), 0,
          'no thanks from Rahul yet');

select pg_temp.login(:rahul);
select isnt((select count(*)::int from user_badges where profile_id = :bodhi), 0, 'a friend sees Bodhi''s badges');
select lives_ok($$ insert into badge_congrats (owner_id, badge_id) values ('a0000000-0000-4000-8000-000000000001', 'straight_talker') $$,
                'a friend says Congrats');
select lives_ok($$ insert into visit_thanks (visit_id) values ('c0000000-0000-4000-8000-000000000004') $$,
                'a friend says Thanks, went there');
select throws_ok($$ insert into visit_thanks (visit_id) values ('c0000000-0000-4000-8000-000000000011') $$,
                 '42501', null, 'you cannot thank your own review');

-- ── As Arjun (no accepted friends) ──────────────────────────────────────────

select pg_temp.login(:arjun);
select is((select count(*)::int from user_badges where profile_id = :bodhi), 0, 'a stranger cannot see Bodhi''s badges');
select throws_ok($$ insert into badge_congrats (owner_id, badge_id) values ('a0000000-0000-4000-8000-000000000001', 'straight_talker') $$,
                 '42501', null, 'a stranger cannot send Congrats');
select throws_ok($$ insert into visit_thanks (visit_id) values ('c0000000-0000-4000-8000-000000000001') $$,
                 '42501', null, 'a stranger cannot thank a review');
select is((select count(*)::int from visits), 0, 'Arjun sees no visits (all profiles are friends-only)');
select is((select count(*)::int from lists), 0, 'Arjun sees no lists');
select is((select places_count from profile_summaries(array[:rahul]::uuid[])), null, 'Arjun cannot see Rahul''s stats');

-- ── Anonymous ───────────────────────────────────────────────────────────────

select pg_temp.logout();
set local role anon;
select throws_ok('select count(*) from visits', '42501', null, 'anon cannot read visits');
select throws_ok('select * from get_feed()', '42501', null, 'anon cannot call get_feed');
select throws_ok('select * from my_badges()', '42501', null, 'anon cannot call my_badges');
select pg_temp.logout();
select is((select count(*)::int from notifications where kind = 'thanks' and recipient_id = :bodhi and actor_id = :rahul), 1,
          'Thanks, went there notifies the author');

select * from finish();
rollback;
