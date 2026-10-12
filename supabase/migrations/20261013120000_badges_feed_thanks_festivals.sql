-- Badges, part 2 (PRD BDG-11 … BDG-13). One change set:
--   * "Thanks, went there!" (visit_thanks) + its notification — Trusted voice
--   * festival calendar (festivals) — Festival lights
--   * Been there (verified visits), Trusted voice, Festival lights badges
--   * badges in the friends feed: user_badges.in_feed, get_feed's new
--     'badge' items and badge_id column
-- Source of truth: supabase/schemas/07_social.sql, 08_notifications.sql,
-- 09_badges.sql and 10_feed_and_stats.sql.

-- ── Thanks, went there! (PRD BDG-13, Trusted voice) ─────────────────────────
-- You went somewhere because of a friend's review and said so. Counts toward
-- the author's Trusted voice badge and notifies them.

create table public.visit_thanks (
  visit_id   uuid not null references public.visits (id) on delete cascade,
  profile_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (visit_id, profile_id)
);

comment on table public.visit_thanks is '"Thanks, went there!" on a friend''s review.';

create index visit_thanks_profile_idx on public.visit_thanks (profile_id);

alter table public.visit_thanks enable row level security;

-- Visible with the review (the visits policy decides) and to the sender.
create policy "Thanks are visible with the review"
  on public.visit_thanks for select
  to authenticated
  using (profile_id = (select auth.uid()) or exists (select 1 from public.visits v where v.id = visit_id));

create policy "Friends thank as themselves"
  on public.visit_thanks for insert
  to authenticated
  with check (
    profile_id = (select auth.uid())
    and exists (
      select 1 from public.visits v
      where v.id = visit_id
        and v.author_id <> (select auth.uid())
        and private.are_friends((select auth.uid()), v.author_id)
    )
  );

create policy "Senders take back their thanks"
  on public.visit_thanks for delete
  to authenticated
  using (profile_id = (select auth.uid()));

grant select, delete on public.visit_thanks to authenticated;
grant insert (visit_id) on public.visit_thanks to authenticated;
grant all on public.visit_thanks to service_role;

-- "Thanks, went there!" tells the review's author.
create function private.notify_thanks()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, kind, actor_id, payload)
  select v.author_id, 'thanks', new.profile_id, jsonb_build_object('place', p.name, 'place_id', p.id)
  from public.visits v
  join public.places p on p.id = v.place_id
  where v.id = new.visit_id;
  return new;
end;
$$;

create trigger visit_thanks_notify
  after insert on public.visit_thanks
  for each row execute function private.notify_thanks();

revoke execute on function private.notify_thanks() from public, anon, authenticated;

-- ── Festivals ───────────────────────────────────────────────────────────────

-- Festival calendar for Festival lights (BDG-13). Rows are data, so they
-- live only in migrations; dates come from the published 2025–2027
-- calendars, with a day either side where regions differ.
create table public.festivals (
  id       text primary key check (id ~ '^[a-z0-9_]{2,40}$'),
  name     text not null check (char_length(name) between 1 and 60),
  starts_on date not null,
  ends_on   date not null,
  -- Where it's celebrated most ("Nagaland"); null = across India.
  region   text check (char_length(region) <= 80),
  check (ends_on >= starts_on)
);

comment on table public.festivals is 'Festival dates for the Festival lights badge.';

alter table public.festivals enable row level security;

create policy "Signed-in users read the festival calendar"
  on public.festivals for select
  to authenticated
  using (true);

grant select on public.festivals to authenticated;
grant all on public.festivals to service_role;

-- ── Badge rules ─────────────────────────────────────────────────────────────

alter table public.user_badges add column in_feed boolean not null default true;

create or replace function private.badge_progress(uid uuid)
returns table (badge_id text, progress integer)
language sql
stable
security definer
set search_path = ''
as $$
  with mine as (
    select v.place_id, v.visited_on, v.tip, v.recommended, v.rating, p.category,
           coalesce(p.city, nullif(p.area, '')) as city, p.state
    from public.visits v
    join public.places p on p.id = v.place_id
    where v.author_id = uid
  ),
  friends as (
    select case when f.requester_id = uid then f.addressee_id else f.requester_id end as id
    from public.friendships f
    where f.status = 'accepted' and uid in (f.requester_id, f.addressee_id)
  ),
  categories as (
    select category, count(distinct place_id)::integer as n from mine group by category
  )
  select 'first_pin', (select count(distinct place_id) from mine)::integer
  union all select 'one_thing', (select count(*) from mine where btrim(tip) <> '')::integer
  union all select 'first_friend', (select count(*) from friends)::integer
  union all select 'list_maker', (select count(*) from public.lists l where l.owner_id = uid)::integer
  union all select 'map_sharer', (select (pr.map_shared_at is not null)::integer from public.profiles pr where pr.id = uid)
  union all select 'places', (select count(distinct place_id) from mine)::integer
  union all select 'cities', (select count(distinct city) from mine)::integer
  union all select 'states', (select count(distinct state) from mine)::integer
  -- GPS- or photo-verified visits ("I'm here").
  union all select 'been_there', (
    select count(distinct v.place_id) from public.visits v where v.author_id = uid and v.verified
  )::integer
  union all select 'seven_sisters', (
    select count(distinct state) from mine
    where state in ('Arunachal Pradesh', 'Assam', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Sikkim', 'Tripura')
  )::integer
  union all select 'cafe_hopper', coalesce((select n from categories where category = 'cafe'), 0)
  union all select 'food_trail', coalesce((select n from categories where category = 'food'), 0)
  union all select 'trekker', coalesce((select n from categories where category = 'trek'), 0)
  union all select 'temple_trail', coalesce((select n from categories where category = 'temple'), 0)
  union all select 'viewpoint_chaser', coalesce((select n from categories where category = 'viewpoint'), 0)
  union all select 'beach_bum', coalesce((select n from categories where category = 'beach'), 0)
  union all select 'homestay_hopper', coalesce((select n from categories where category = 'stay'), 0)
  union all select 'straight_talker', (select count(*) from mine where not recommended)::integer
  -- Friends who saved a place you reviewed.
  union all select 'tip_master', (
    select count(*) from public.saved_places s
    where s.profile_id in (select id from friends)
      and s.place_id in (select place_id from mine)
  )::integer
  -- Best taste match with any friend over 2+ shared places, as in
  -- profile_summaries: 100 minus 20 points per star of average gap.
  -- Friends who said "Thanks, went there!" on your reviews.
  union all select 'trusted_voice', (
    select count(distinct t.profile_id)
    from public.visit_thanks t
    join public.visits v on v.id = t.visit_id
    where v.author_id = uid
  )::integer
  union all select 'taste_twin', coalesce((
    select max(t.m) from (
      select round(greatest(0, 100 - avg(abs(a.rating - b.rating)) * 20))::integer as m
      from mine a
      join public.visits b on b.place_id = a.place_id
      where b.author_id in (select id from friends) and not b.is_hidden
      group by b.author_id
      having count(distinct a.place_id) >= 2
    ) t
  ), 0)
  -- Most other people in any list you're in.
  union all select 'squad_explorer', coalesce((
    select max(t.c) from (
      select count(*)::integer - 1 as c
      from public.list_members m
      where m.list_id in (select list_id from public.list_members where profile_id = uid)
      group by m.list_id
    ) t
  ), 0)
  union all select 'regular', coalesce((select max(t.c) from (select count(*)::integer as c from mine group by place_id) t), 0)
  union all select 'monsoon_wanderer', (select count(*) from mine where extract(month from visited_on) between 6 and 9)::integer
  union all select 'winter_hills', (
    select count(*) from mine
    where extract(month from visited_on) in (12, 1, 2) and category in ('trek', 'viewpoint')
  )::integer
  -- Places visited during a festival.
  union all select 'festival_lights', (
    select count(distinct m.place_id) from mine m
    where exists (select 1 from public.festivals f where m.visited_on between f.starts_on and f.ends_on)
  )::integer
  -- Places you reviewed before any friend did, and a friend went after.
  union all select 'hidden_gem', (
    select count(*) from (select place_id, min(visited_on) as first_on from mine group by place_id) m
    where exists (
            select 1 from public.visits f
            where f.place_id = m.place_id and f.author_id in (select id from friends))
      and not exists (
            select 1 from public.visits f
            where f.place_id = m.place_id and f.author_id in (select id from friends)
              and f.visited_on <= m.first_on)
  )::integer;
$$;

-- Recounts `uid`'s badges and stores any new badge or higher level.
create or replace function private.refresh_badges(uid uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if uid is null or not exists (select 1 from public.profiles where id = uid) then
    return;
  end if;

  insert into public.user_badges as ub (profile_id, badge_id, level, progress)
  select uid, b.id, lv.level, p.progress
  from private.badge_progress(uid) p
  join public.badges b on b.id = p.badge_id
  cross join lateral (
    select count(*)::smallint as level from unnest(b.levels) as t(threshold) where t.threshold <= p.progress
  ) lv
  where lv.level > 0
  on conflict (profile_id, badge_id) do update
    set progress   = excluded.progress,
        level      = greatest(ub.level, excluded.level),
        leveled_at = case when excluded.level > ub.level then now() else ub.leveled_at end,
        in_feed    = case when excluded.level > ub.level then true else ub.in_feed end;

  -- Keep the stored count fresh for badges whose progress went down too
  -- (the level stays).
  update public.user_badges ub
  set progress = p.progress
  from private.badge_progress(uid) p
  where ub.profile_id = uid and ub.badge_id = p.badge_id and ub.progress <> p.progress;
end;
$$;

-- Thanks on your review count toward Trusted voice.
create function private.refresh_badges_for_thanks()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_badges(v.author_id)
  from public.visits v
  where v.id = coalesce(new.visit_id, old.visit_id);
  return null;
end;
$$;

create trigger visit_thanks_refresh_badges
  after insert or delete on public.visit_thanks
  for each row execute function private.refresh_badges_for_thanks();

revoke execute on function private.refresh_badges_for_thanks() from public, anon, authenticated;

-- ── Feed: badge items (the return type changes, so drop and recreate) ──────

drop function public.get_feed(timestamptz, integer);

create function public.get_feed(before timestamptz default now(), max_items integer default 30)
returns table (
  id          uuid,
  kind        text,
  author_id   uuid,
  verb        text,
  subject     text,
  place_id    uuid,
  category    public.place_category,
  rating      numeric,
  quote       text,
  footnote    text,
  like_count  integer,
  liked_by_me boolean,
  created_at  timestamptz,
  badge_id    text
)
language sql
stable
set search_path = ''
as $$
  with friends as (
    select private.friend_ids() as id
  ),
  items as (
    -- Visits
    select v.id,
           'visit'::text as kind,
           v.author_id,
           'visited'::text as verb,
           p.name as subject,
           p.id as place_id,
           p.category,
           v.rating,
           coalesce(nullif(v.body, ''), v.tip) as quote,
           null::text as footnote,
           'visit'::public.like_subject as like_type,
           v.id as like_id,
           v.created_at,
           null::text as badge_id
    from public.visits v
    join public.places p on p.id = v.place_id
    where v.author_id in (select id from friends)

    union all

    -- Asks
    select a.id,
           'ask',
           a.author_id,
           'is going to',
           a.destination,
           null,
           null,
           null,
           a.body,
           (select case when count(distinct r.author_id) = 0 then null
                        when count(distinct r.author_id) = 1 then '1 friend replied with pins'
                        else count(distinct r.author_id) || ' friends replied with pins' end
            from public.ask_replies r where r.ask_id = a.id),
           'ask',
           a.id,
           a.created_at,
           null
    from public.asks a
    where a.author_id in (select id from friends)

    union all

    -- List additions, one item per list, person and day
    select (array_agg(li.id order by li.created_at))[1],
           'list',
           li.added_by,
           case when count(*) = 1 then 'added a place to' else 'added ' || count(*) || ' places to' end,
           l.title,
           null,
           null,
           null,
           l.title,
           (select count(*) from public.list_items x where x.list_id = l.id) || ' places · '
             || (select count(*) from public.list_members m where m.list_id = l.id) || ' friends',
           'list',
           l.id,
           max(li.created_at),
           null
    from public.list_items li
    join public.lists l on l.id = li.list_id
    where li.added_by in (select id from friends)
    group by l.id, l.title, li.added_by, date_trunc('day', li.created_at)

    union all

    -- Badges, one item per badge level
    select md5(ub.profile_id::text || ub.badge_id || ub.level)::uuid,
           'badge',
           ub.profile_id,
           'earned',
           b.title || case when cardinality(b.levels) > 1 then ' ' || (array['I', 'II', 'III'])[ub.level] else '' end,
           null,
           null,
           null,
           b.how_to,
           null,
           null,
           null,
           ub.leveled_at,
           ub.badge_id
    from public.user_badges ub
    join public.badges b on b.id = ub.badge_id
    where ub.profile_id in (select id from friends)
      and ub.in_feed
      and b.group_id <> 'getting_started'
  )
  select i.id, i.kind, i.author_id, i.verb, i.subject, i.place_id, i.category, i.rating, i.quote,
         i.footnote,
         case when i.kind = 'badge' then
           (select count(*)::integer from public.badge_congrats c
            where c.owner_id = i.author_id and c.badge_id = i.badge_id)
         else
           (select count(*)::integer from public.likes k
            where k.subject_type = i.like_type and k.subject_id = i.like_id)
         end,
         case when i.kind = 'badge' then
           exists (select 1 from public.badge_congrats c
                   where c.owner_id = i.author_id and c.badge_id = i.badge_id
                     and c.from_id = (select auth.uid()))
         else
           exists (select 1 from public.likes k
                   where k.subject_type = i.like_type and k.subject_id = i.like_id
                     and k.profile_id = (select auth.uid()))
         end,
         i.created_at,
         i.badge_id
  from items i
  where i.created_at < before
  order by i.created_at desc
  limit least(greatest(max_items, 1), 100);
$$;

revoke execute on function public.get_feed(timestamptz, integer) from public, anon;
grant execute on function public.get_feed(timestamptz, integer) to authenticated;

-- ── Data ────────────────────────────────────────────────────────────────────
-- Keep in step with lib/core/badges/badge_catalog.dart and festivals.dart.

insert into public.badges (id, group_id, title, how_to, icon, tone, levels, is_secret, sort_order) values
  ('been_there',      'explorer',     'Been there',      'Verify your visit with "I''m here" at different places.',            'pin_check', '#11694E', '{1,10,50}', false, 150),
  ('trusted_voice',   'honest_voice', 'Trusted voice',   '5 friends say "Thanks, went there!" on your reviews.',             'trusted',   '#11694E', '{5}',       false, 330),
  ('festival_lights', 'seasons',      'Festival lights', 'Review a place you went to during a festival.',                    'diya',      '#E8590C', '{1}',       false, 530);

insert into public.festivals (id, name, starts_on, ends_on, region) values
  ('holi_2025',          'Holi',             '2025-03-13', '2025-03-15', null),
  ('bihu_2025',          'Rongali Bihu',     '2025-04-14', '2025-04-16', 'Assam'),
  ('durga_puja_2025',    'Durga Puja',       '2025-09-28', '2025-10-02', 'West Bengal, Tripura, Assam'),
  ('diwali_2025',        'Diwali',           '2025-10-19', '2025-10-22', null),
  ('hornbill_2025',      'Hornbill Festival','2025-12-01', '2025-12-10', 'Nagaland'),
  ('christmas_2025',     'Christmas',        '2025-12-24', '2025-12-26', null),
  ('holi_2026',          'Holi',             '2026-03-03', '2026-03-04', null),
  ('bihu_2026',          'Rongali Bihu',     '2026-04-14', '2026-04-16', 'Assam'),
  ('durga_puja_2026',    'Durga Puja',       '2026-10-16', '2026-10-21', 'West Bengal, Tripura, Assam'),
  ('diwali_2026',        'Diwali',           '2026-11-07', '2026-11-10', null),
  ('hornbill_2026',      'Hornbill Festival','2026-12-01', '2026-12-10', 'Nagaland'),
  ('christmas_2026',     'Christmas',        '2026-12-24', '2026-12-26', null),
  ('holi_2027',          'Holi',             '2027-03-21', '2027-03-22', null),
  ('bihu_2027',          'Rongali Bihu',     '2027-04-14', '2027-04-16', 'Assam'),
  ('durga_puja_2027',    'Durga Puja',       '2027-10-05', '2027-10-10', 'West Bengal, Tripura, Assam'),
  ('diwali_2027',        'Diwali',           '2027-10-28', '2027-10-30', null),
  ('hornbill_2027',      'Hornbill Festival','2027-12-01', '2027-12-10', 'Nagaland'),
  ('christmas_2027',     'Christmas',        '2027-12-24', '2027-12-26', null);

-- ── Backfill ────────────────────────────────────────────────────────────────
-- Award the new badges to everyone, without celebrations or feed items for
-- what they already had.

select private.refresh_badges(id) from public.profiles;
update public.user_badges set seen_level = level, in_feed = false;
