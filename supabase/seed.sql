-- Demo data for local and staging: the same people, places, reviews, feed,
-- lists and notifications the app showed on mock data.
--
-- NEVER run against production.
--
-- Sign in as the demo account with test phone +91 98765 43210, code 123456.
-- Sign in as Rahul (to see the other side) with +91 90000 00001, code 123456.
-- (Local: supabase/config.toml [auth.sms.test_otp]. Hosted: add both under
--  Authentication → Providers → Phone → Test phone numbers.)
--
-- IDs are fixed so the data is the same everywhere:
--   people  a0000000-0000-4000-8000-0000000000NN
--   places  b0000000-0000-4000-8000-0000000000NN
--   visits  c0000000-0000-4000-8000-0000000000NN
--   lists   d0000000-0000-4000-8000-0000000000NN
--   asks    e0000000-0000-4000-8000-0000000000NN

begin;

-- ── Auth users (Supabase Auth, phone provider) ──────────────────────────────

insert into auth.users (
  instance_id, id, aud, role, phone, phone_confirmed_at, encrypted_password,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select '00000000-0000-0000-0000-000000000000', u.id::uuid, 'authenticated', 'authenticated',
       u.phone, now(), '',
       '{"provider": "phone", "providers": ["phone"]}'::jsonb, '{}'::jsonb,
       now() - interval '120 days', now(),
       '', '', '', ''
from (values
  ('a0000000-0000-4000-8000-000000000001', '919876543210'),  -- Bodhi (demo account)
  ('a0000000-0000-4000-8000-000000000002', '919000000001'),  -- Rahul
  ('a0000000-0000-4000-8000-000000000003', '919000000002'),  -- Priya
  ('a0000000-0000-4000-8000-000000000004', '919000000003'),  -- Asha
  ('a0000000-0000-4000-8000-000000000005', '919000000004'),  -- Meera
  ('a0000000-0000-4000-8000-000000000006', '919000000005'),  -- Kabir
  ('a0000000-0000-4000-8000-000000000007', '919000000006'),  -- Arjun
  ('a0000000-0000-4000-8000-000000000008', '919000000007'),  -- Tanmoy
  ('a0000000-0000-4000-8000-000000000009', '919000000008'),  -- Sneha
  ('a0000000-0000-4000-8000-00000000000a', '919000000009'),  -- Dev
  ('a0000000-0000-4000-8000-00000000000b', '919000000010')   -- Rahul Dey
) as u (id, phone);

insert into auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select u.id::text, u.id,
       jsonb_build_object('sub', u.id::text, 'phone', u.phone, 'phone_verified', true),
       'phone', now(), now(), now()
from auth.users u
where u.id::text like 'a0000000-0000-4000-8000-%';

-- ── Profiles ────────────────────────────────────────────────────────────────

insert into public.profiles (id, username, display_name, home_city, avatar_bg, avatar_fg) values
  ('a0000000-0000-4000-8000-000000000001', 'bodhi',    'Bodhi Chakraborty', 'Agartala', '#F2F7FF', '#1D4E9E'),
  ('a0000000-0000-4000-8000-000000000002', 'rahul',    'Rahul Sen',         'Agartala', '#DDEAFB', '#1D4E9E'),
  ('a0000000-0000-4000-8000-000000000003', 'priya',    'Priya Kar',         'Agartala', '#DDF6EC', '#11694E'),
  ('a0000000-0000-4000-8000-000000000004', 'asha',     'Asha Debbarma',     'Agartala', '#FFE3CC', '#9A3412'),
  ('a0000000-0000-4000-8000-000000000005', 'meera',    'Meera Saha',        'Udaipur',  '#FDE2EC', '#A61E4D'),
  ('a0000000-0000-4000-8000-000000000006', 'kabir',    'Kabir Roy',         'Goa',      '#EEF0F4', '#3F4857'),
  ('a0000000-0000-4000-8000-000000000007', 'arjun.n',  'Arjun Nath',        'Agartala', '#EDE5FF', '#5B3CC4'),
  ('a0000000-0000-4000-8000-000000000008', 'tanmoy',   'Tanmoy Paul',       'Agartala', '#E3F0FF', '#1D4E9E'),
  ('a0000000-0000-4000-8000-000000000009', 'sneha',    'Sneha Ghosh',       'Agartala', '#FFF1C9', '#8A5A00'),
  ('a0000000-0000-4000-8000-00000000000a', 'dev.m',    'Dev Majumder',      'Agartala', '#E6F7EE', '#11694E'),
  ('a0000000-0000-4000-8000-00000000000b', 'rahuldey', 'Rahul Dey',         'Agartala', '#EEF0F4', '#3F4857');

-- ── Places ──────────────────────────────────────────────────────────────────

insert into public.places (id, name, category, lat, lng, area, address, city, state, created_by) values
  ('b0000000-0000-4000-8000-000000000001', 'Neermahal',              'viewpoint', 23.5022, 91.3172, 'Melaghar',      'Melaghar, Tripura',         'Melaghar', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000002', 'Tripura Sundari Temple', 'temple',    23.5099, 91.4950, 'Udaipur',       'Udaipur, Gomati',           'Udaipur', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000003', 'Jampui Hills',           'trek',      23.9917, 92.2667, 'North Tripura', 'North Tripura',             'Jampui Hills', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000004', 'Hilltop Momo Stall',     'food',      23.8380, 91.2790, 'Agartala',      'Battala, Agartala',         'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000005', 'Lakeside Reading Café',  'cafe',      23.8360, 91.2830, 'Agartala',      'Lake Road, Agartala',       'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000006', 'Rudra Homestay',         'stay',      23.4985, 91.3120, 'Melaghar',      'Melaghar, Tripura',         'Melaghar', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000007', 'Night Market Chaat',     'food',      23.8315, 91.2860, 'Agartala',      'Night Market, Agartala',    'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000008', 'Ujjayanta Palace',       'viewpoint', 23.8340, 91.2820, 'Agartala',      'Palace Compound, Agartala', 'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000002'),
  ('b0000000-0000-4000-8000-000000000009', 'Rabindra Kanan',         'viewpoint', 23.8460, 91.2900, 'Agartala',      'Agartala',                  'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000002'),
  ('b0000000-0000-4000-8000-00000000000a', 'Heritage Park',          'trek',      23.8530, 91.2950, 'Agartala',      'Kunjaban, Agartala',        'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000003'),
  ('b0000000-0000-4000-8000-00000000000b', 'Lake Road Book Store',   'shop',      23.8364, 91.2835, 'Agartala',      'Lake Road, Agartala',       'Agartala', 'Tripura',   'a0000000-0000-4000-8000-000000000003'),
  ('b0000000-0000-4000-8000-00000000000c', 'Dzükou Valley',          'trek',      25.5588, 94.0600, 'Nagaland',      'Kohima, Nagaland',          'Kohima', 'Nagaland',  'a0000000-0000-4000-8000-000000000002'),
  ('b0000000-0000-4000-8000-00000000000d', 'Ward Lake',              'viewpoint', 25.5760, 91.8880, 'Shillong',      'Shillong, Meghalaya',       'Shillong', 'Meghalaya', 'a0000000-0000-4000-8000-000000000004'),
  ('b0000000-0000-4000-8000-00000000000e', 'Butterfly Beach',        'beach',     15.0177, 74.0025, 'Canacona',      'Canacona, South Goa',       'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000003'),
  ('b0000000-0000-4000-8000-00000000000f', 'Fort Aguada',            'viewpoint', 15.4920, 73.7733, 'Candolim',      'Candolim, North Goa',       'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000002'),
  ('b0000000-0000-4000-8000-000000000010', 'Fontainhas walk',        'other',     15.4970, 73.8330, 'Panaji',        'Fontainhas, Panaji',        'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000001'),
  ('b0000000-0000-4000-8000-000000000011', 'Dudhsagar Falls',        'trek',      15.3144, 74.3143, 'Sonaulim',      'Sonaulim, Goa',             'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000004'),
  ('b0000000-0000-4000-8000-000000000012', 'Beach shack, Palolem',   'food',      15.0100, 74.0230, 'Palolem',       'Palolem Beach, Goa',        'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000003'),
  ('b0000000-0000-4000-8000-000000000013', 'Hostel in Anjuna',       'stay',      15.5740, 73.7410, 'Anjuna',        'Anjuna, North Goa',         'Goa', 'Goa',       'a0000000-0000-4000-8000-000000000002');

-- ── Friendships ─────────────────────────────────────────────────────────────

insert into public.friendships (requester_id, addressee_id, status, created_at, responded_at) values
  -- Bodhi's friends
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'accepted', now() - interval '300 days', now() - interval '299 days'),
  ('a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'accepted', now() - interval '280 days', now() - interval '280 days'),
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'accepted', now() - interval '250 days', now() - interval '249 days'),
  ('a0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', 'accepted', now() - interval '200 days', now() - interval '199 days'),
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000006', 'accepted', now() - interval '180 days', now() - interval '180 days'),
  -- Friends of friends (mutual-friend counts, list members)
  ('a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000003', 'accepted', now() - interval '400 days', now() - interval '400 days'),
  ('a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000004', 'accepted', now() - interval '390 days', now() - interval '390 days'),
  ('a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000004', 'accepted', now() - interval '380 days', now() - interval '380 days'),
  ('a0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000002', 'accepted', now() - interval '100 days', now() - interval '100 days'),
  ('a0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000003', 'accepted', now() - interval '100 days', now() - interval '100 days'),
  ('a0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000004', 'accepted', now() - interval '100 days', now() - interval '100 days'),
  ('a0000000-0000-4000-8000-00000000000b', 'a0000000-0000-4000-8000-000000000002', 'accepted', now() - interval '90 days',  now() - interval '90 days'),
  ('a0000000-0000-4000-8000-00000000000b', 'a0000000-0000-4000-8000-000000000003', 'accepted', now() - interval '90 days',  now() - interval '90 days'),
  -- Requests to Bodhi
  ('a0000000-0000-4000-8000-000000000008', 'a0000000-0000-4000-8000-000000000001', 'pending', now() - interval '2 days', null),
  ('a0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000001', 'pending', now() - interval '1 hour', null),
  ('a0000000-0000-4000-8000-00000000000a', 'a0000000-0000-4000-8000-000000000001', 'pending', now() - interval '3 days', null),
  -- Bodhi's sent request
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000007', 'pending', now() - interval '1 day', null);

-- ── Visits ──────────────────────────────────────────────────────────────────

insert into public.visits (id, place_id, author_id, visited_on, recommended, rating, tip, body, companions, tags, budget_per_person, verified, verified_by, created_at) values
  -- Bodhi
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', '2026-09-06', true, 4.2,
   'Order the fried pork momos, skip the soup.', 'Tiny stall, big flavour. The fried pork momos are the reason to come.',
   '{Asha}', '{"Worth it"}', 150, false, null, '2026-09-06 19:00+05:30'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', '2026-08-09', true, 4.5,
   'Take the boat from the jetty; sunset is the best hour.',
   'A palace right in the middle of the lake. The boat ride over is half the fun. Inside is a bit bare, but the views from the terrace are worth it.',
   '{Rahul}', '{"Worth it","Best at sunset","Good for groups"}', 400, true, 'gps', '2026-08-09 18:30+05:30'),
  ('c0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000001', '2026-08-08', true, 4.4,
   'Ask for the lake-facing room upstairs.', '', '{Rahul}', '{}', 1200, false, null, '2026-08-08 21:00+05:30'),
  ('c0000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', '2026-07-12', true, 3.5,
   'Quiet before noon, good for work, weak Wi‑Fi.', '', '{solo}', '{Solo-friendly}', 350, false, null, '2026-07-12 13:00+05:30'),
  ('c0000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000001', '2026-06-20', false, 3.0,
   'Busy after 8pm; parking is tough.', '', '{Priya}', '{"Skip it"}', 120, false, null, '2026-06-20 22:00+05:30'),
  ('c0000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', '2026-03-02', true, 4.0,
   'Go early on weekdays to skip the queue.', '', '{family}', '{"Go early"}', null, false, null, '2026-03-02 12:00+05:30'),
  ('c0000000-0000-4000-8000-000000000007', 'b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', '2025-11-10', true, 4.8,
   'November for the orange festival; carry a jacket.', '', '{solo}', '{"Worth it"}', null, false, null, '2025-11-10 17:00+05:30'),
  -- Friends
  ('c0000000-0000-4000-8000-000000000011', 'b0000000-0000-4000-8000-00000000000c', 'a0000000-0000-4000-8000-000000000002', current_date, true, 5.0,
   'Start before 6am, the last stretch is steep.', 'Hardest climb of my life and worth every step. Start before 6am.',
   '{}', '{"Worth it"}', null, true, 'gps', now() - interval '2 hours'),
  ('c0000000-0000-4000-8000-000000000012', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', '2026-08-09', true, 5.0,
   'Boat ride plus sunset is unbeatable.', 'Boat ride plus sunset is unbeatable. Go on a weekday.', '{you}', '{}', null, false, null, '2026-08-09 19:00+05:30'),
  ('c0000000-0000-4000-8000-000000000013', 'b0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000002', '2026-08-08', true, 4.0,
   'Simple rooms, great breakfast.', 'Simple rooms, great breakfast.', '{you}', '{}', null, false, null, '2026-08-08 21:30+05:30'),
  ('c0000000-0000-4000-8000-000000000014', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', '2026-02-14', true, 4.5,
   'Carry snacks, nothing to eat on the island.', 'Carry snacks, nothing to eat on the island.', '{}', '{}', null, false, null, '2026-02-14 16:00+05:30'),
  ('c0000000-0000-4000-8000-000000000015', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', '2025-12-20', true, 4.0,
   'Go early, the jetty queue gets long.', 'Pretty from the shore too. Go early, the jetty queue gets long.', '{}', '{}', null, false, null, '2025-12-20 11:00+05:30'),
  ('c0000000-0000-4000-8000-000000000016', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000005', '2025-10-03', true, 4.5,
   'Light and sound show is worth staying for.', 'Stay for the light and sound show if you can.', '{}', '{}', null, false, null, '2025-10-03 20:00+05:30'),
  ('c0000000-0000-4000-8000-000000000017', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000006', '2025-04-18', true, 5.0,
   'Hire a private boat if you are four or more.', 'Hire a private boat if you are four or more. Totally worth it.', '{}', '{}', null, false, null, '2025-04-18 17:00+05:30'),
  ('c0000000-0000-4000-8000-000000000018', 'b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000003', current_date - 1, true, 4.0,
   'The fried ones really are better.', 'Thanks Bodhi, went because of your pin. The fried ones really are better.', '{}', '{}', 150, false, null, now() - interval '1 day'),
  ('c0000000-0000-4000-8000-000000000019', 'b0000000-0000-4000-8000-00000000000d', 'a0000000-0000-4000-8000-000000000004', '2026-09-28', true, 4.0,
   'Paddle boats close at 5pm.', 'Lovely for an evening walk. Paddle boats close at 5pm.', '{}', '{}', null, false, null, '2026-09-28 18:00+05:30'),
  ('c0000000-0000-4000-8000-00000000001a', 'b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000004', '2026-08-30', true, 4.0,
   'Try the cold coffee.', '', '{}', '{}', 300, false, null, '2026-08-30 15:00+05:30'),
  ('c0000000-0000-4000-8000-00000000001b', 'b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000005', '2026-05-02', true, 4.0,
   'Window seats go first.', '', '{}', '{}', null, false, null, '2026-05-02 10:30+05:30'),
  ('c0000000-0000-4000-8000-00000000001c', 'b0000000-0000-4000-8000-00000000000f', 'a0000000-0000-4000-8000-000000000002', '2025-12-28', true, 4.5,
   'Go at opening time, before the tour buses.', '', '{}', '{}', null, false, null, '2025-12-28 09:00+05:30'),
  ('c0000000-0000-4000-8000-00000000001d', 'b0000000-0000-4000-8000-000000000011', 'a0000000-0000-4000-8000-000000000004', '2025-08-17', true, 5.0,
   'Monsoon is the best time; book the jeep early.', '', '{}', '{}', null, false, null, '2025-08-17 14:00+05:30');

-- Placeholder photo rows so photo counts match the mock (files not uploaded).
insert into public.visit_photos (visit_id, storage_path, position) values
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000001/0.jpg', 0),
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000001/1.jpg', 1),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000002/0.jpg', 0),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000002/1.jpg', 1),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000002/2.jpg', 2),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000002/3.jpg', 3),
  ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001/c0000000-0000-4000-8000-000000000003/0.jpg', 0);

-- ── Lists ───────────────────────────────────────────────────────────────────
-- The owner becomes a member automatically (trigger).

insert into public.lists (id, owner_id, title, planning_note, created_at) values
  ('d0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'Goa trip 2027', 'planning for Jan 2027', now() - interval '20 days'),
  ('d0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'Agartala food crawl', '', now() - interval '60 days');

insert into public.list_members (list_id, profile_id, role, joined_at) values
  ('d0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'editor', now() - interval '6 days'),
  ('d0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'editor', now() - interval '19 days'),
  ('d0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'editor', now() - interval '19 days');

insert into public.list_items (id, list_id, place_id, added_by, created_at) values
  ('f0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-00000000000e', 'a0000000-0000-4000-8000-000000000003', now() - interval '2 days'),
  ('f0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-00000000000f', 'a0000000-0000-4000-8000-000000000002', now() - interval '15 days'),
  ('f0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000010', 'a0000000-0000-4000-8000-000000000001', now() - interval '5 days'),
  ('f0000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000011', 'a0000000-0000-4000-8000-000000000004', now() - interval '14 days'),
  ('f0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000012', 'a0000000-0000-4000-8000-000000000003', now() - interval '2 days' + interval '5 minutes'),
  ('f0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000013', 'a0000000-0000-4000-8000-000000000002', now() - interval '13 days'),
  ('f0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', now() - interval '60 days'),
  ('f0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000001', now() - interval '59 days'),
  ('f0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', now() - interval '58 days');

insert into public.list_item_votes (item_id, profile_id) values
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003'),
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001'),
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004'),
  ('f0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002'),
  ('f0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001'),
  ('f0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000003'),
  ('f0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001'),
  ('f0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000004'),
  ('f0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000004'),
  ('f0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000002'),
  ('f0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000003'),
  ('f0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000002');

-- ── Asks and replies ────────────────────────────────────────────────────────

insert into public.asks (id, author_id, destination, body, created_at) values
  ('e0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'Shillong',
   'Going next week for 3 days. Cafés and one easy hike?', now() - interval '5 hours');

insert into public.ask_replies (ask_id, author_id, place_id, note, created_at) values
  ('e0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-00000000000d', 'Evening walk here', now() - interval '4 hours'),
  ('e0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-00000000000d', 'Paddle boats!', now() - interval '4 hours'),
  ('e0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-00000000000d', '', now() - interval '3 hours'),
  ('e0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-00000000000d', '', now() - interval '2 hours');

-- ── Likes ───────────────────────────────────────────────────────────────────

insert into public.likes (profile_id, subject_type, subject_id)
select liker::uuid, 'visit', 'c0000000-0000-4000-8000-000000000011'
from unnest(array[
  'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003',
  'a0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000005',
  'a0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000007',
  'a0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-00000000000a'
]) as liker;  -- Rahul's Dzükou visit: 8

insert into public.likes (profile_id, subject_type, subject_id)
select liker::uuid, 'visit', 'c0000000-0000-4000-8000-000000000018'
from unnest(array[
  'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000004',
  'a0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000006',
  'a0000000-0000-4000-8000-000000000009'
]) as liker;  -- Priya's momo visit: 5

insert into public.likes (profile_id, subject_type, subject_id)
select liker::uuid, 'visit', 'c0000000-0000-4000-8000-000000000002'
from unnest(array[
  'a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000002',
  'a0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000005'
]) as liker;  -- Bodhi's Neermahal visit: Priya and 3 others

insert into public.likes (profile_id, subject_type, subject_id) values
  ('a0000000-0000-4000-8000-000000000002', 'ask',  'e0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000003', 'ask',  'e0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000002', 'list', 'd0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000004', 'list', 'd0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000005', 'list', 'd0000000-0000-4000-8000-000000000001');

-- ── Thanks, went there! ──────────────────────────────────────────────────────
-- Asha went to Hilltop Momo Stall and Priya to Neermahal because of Bodhi.

insert into public.visit_thanks (visit_id, profile_id, created_at) values
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', now() - interval '4 days'),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000003', now() - interval '20 days');

-- ── Notifications for Bodhi ─────────────────────────────────────────────────
-- Replace the ones the friendship / list triggers just generated with the
-- designed set, so times and wording match the mock.

delete from public.notifications;

insert into public.notifications (recipient_id, kind, actor_id, payload, read_at, created_at) values
  ('a0000000-0000-4000-8000-000000000001', 'joined',         'a0000000-0000-4000-8000-000000000002', '{}', null, now() - interval '10 minutes'),
  ('a0000000-0000-4000-8000-000000000001', 'friend_request', 'a0000000-0000-4000-8000-000000000009', '{}', null, now() - interval '1 hour'),
  ('a0000000-0000-4000-8000-000000000001', 'liked',          'a0000000-0000-4000-8000-000000000003',
   '{"place": "Neermahal", "place_id": "b0000000-0000-4000-8000-000000000001", "others": 3}', null, now() - interval '3 hours'),
  ('a0000000-0000-4000-8000-000000000001', 'thanks',         'a0000000-0000-4000-8000-000000000004',
   '{"place": "Hilltop Momo Stall", "place_id": "b0000000-0000-4000-8000-000000000004"}', now(), now() - interval '4 days'),
  ('a0000000-0000-4000-8000-000000000001', 'nudge',          null,
   '{"place": "Lakeside Reading Café", "place_id": "b0000000-0000-4000-8000-000000000005", "minutes": 40}', now(), now() - interval '5 days'),
  ('a0000000-0000-4000-8000-000000000001', 'list_invite',    'a0000000-0000-4000-8000-000000000003',
   '{"list": "Goa trip 2027", "list_id": "d0000000-0000-4000-8000-000000000001"}', now(), now() - interval '6 days');

commit;

-- ── Badges ──────────────────────────────────────────────────────────────────
-- Earned automatically by the triggers as the rows above went in. Bodhi has
-- shared their map; nobody should see a celebration for seeded badges.

update public.profiles set map_shared_at = now() - interval '200 days'
where id = 'a0000000-0000-4000-8000-000000000001';
select private.refresh_badges('a0000000-0000-4000-8000-000000000001');
update public.user_badges set seen_level = level, in_feed = false;

-- One fresh badge for the feed and Rahul's profile: his Dzükou trek was his
-- third state (just before the visit itself in the feed).
update public.user_badges
set in_feed = true, earned_at = now() - interval '2 hours 5 minutes', leveled_at = now() - interval '2 hours 5 minutes'
where profile_id = 'a0000000-0000-4000-8000-000000000002' and badge_id = 'states';
