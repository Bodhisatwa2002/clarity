-- Badges and milestones (PRD §9.15, BDG-1 … BDG-13).
--
-- `badges` is the catalogue (its rows are data, so they live only in the
-- migration that creates it). `user_badges` holds what each person has
-- earned. Awarding happens here, in the database, from the person's own
-- visits, lists and friendships — the app can't write either table. Levels
-- only ever go up (BDG-3): deleting a review never takes a badge away.
--
-- Keep the rules in step with lib/core/badges/badge_engine.dart, which
-- predicts unlocks so the app can celebrate before the server replies.

create type public.badge_group as enum (
  'getting_started', 'explorer', 'specialist', 'honest_voice', 'together', 'seasons', 'secret'
);

create table public.badges (
  id         text primary key check (id ~ '^[a-z_]{2,40}$'),
  group_id   public.badge_group not null,
  title      text not null check (char_length(title) between 1 and 40),
  -- One plain sentence: what to do to earn it.
  how_to     text not null check (char_length(how_to) between 1 and 160),
  -- Icon key the app maps to a line icon, and the disc colour.
  icon       text not null check (icon ~ '^[a-z_]{2,20}$'),
  tone       text not null check (tone ~ '^#[0-9A-F]{6}$'),
  -- Progress needed for level I, II, III (one entry = a single-level badge).
  levels     integer[] not null
               check (cardinality(levels) between 1 and 3 and 0 < all (levels)),
  is_secret  boolean not null default false,
  sort_order smallint not null default 0
);

comment on table public.badges is 'Badge catalogue: title, how to earn it, icon, colour and level thresholds.';

create table public.user_badges (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  badge_id   text not null references public.badges (id) on delete cascade,
  -- Highest level reached (1–3). Never decreases.
  level      smallint not null check (level between 1 and 3),
  -- Progress the last time it was counted ("8" cafés).
  progress   integer not null default 0 check (progress >= 0),
  earned_at  timestamptz not null default now(),
  leveled_at timestamptz not null default now(),
  -- The level the person has been shown the celebration for (BDG-5).
  seen_level smallint not null default 0 check (seen_level between 0 and 3),
  -- Show this badge (or its latest level) in friends' feeds. False for
  -- badges that were backfilled or seeded rather than earned just now.
  in_feed    boolean not null default true,
  primary key (profile_id, badge_id)
);

comment on table public.user_badges is 'Badges each person has earned, with the highest level reached.';

create index user_badges_badge_idx on public.user_badges (badge_id, level);

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

-- "Congrats" on a friend's badge (BDG-11). One per person per badge.
create table public.badge_congrats (
  owner_id   uuid not null,
  badge_id   text not null,
  from_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (owner_id, badge_id, from_id),
  foreign key (owner_id, badge_id) references public.user_badges (profile_id, badge_id) on delete cascade,
  check (owner_id <> from_id)
);

comment on table public.badge_congrats is 'A friend''s one-tap Congrats on a badge someone earned.';

-- ── Progress rules ──────────────────────────────────────────────────────────
-- One row per badge: how far `uid` has got. Counts distinct places, never
-- review volume (BDG-1). Hidden pins count for their owner.

create function private.badge_progress(uid uuid)
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
create function private.refresh_badges(uid uuid)
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

-- ── Triggers: recount whoever an insert, update or delete affects ────────────

create function private.refresh_badges_for_visit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_badges(coalesce(new.author_id, old.author_id));
  return null;
end;
$$;

create trigger visits_refresh_badges
  after insert or update or delete on public.visits
  for each row execute function private.refresh_badges_for_visit();

create function private.refresh_badges_for_list()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_badges(new.owner_id);
  return null;
end;
$$;

create trigger lists_refresh_badges
  after insert on public.lists
  for each row execute function private.refresh_badges_for_list();

-- Joining a list can complete Squad explorer for everyone in it.
create function private.refresh_badges_for_list_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  member uuid;
begin
  for member in select m.profile_id from public.list_members m where m.list_id = new.list_id loop
    perform private.refresh_badges(member);
  end loop;
  return null;
end;
$$;

create trigger list_members_refresh_badges
  after insert on public.list_members
  for each row execute function private.refresh_badges_for_list_member();

create function private.refresh_badges_for_friendship()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'accepted' then
    perform private.refresh_badges(new.requester_id);
    perform private.refresh_badges(new.addressee_id);
  end if;
  return null;
end;
$$;

create trigger friendships_refresh_badges
  after insert or update of status on public.friendships
  for each row execute function private.refresh_badges_for_friendship();

-- A friend saving a place counts toward Tip master for its reviewers.
create function private.refresh_badges_for_save()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  author uuid;
begin
  for author in
    select distinct v.author_id from public.visits v
    where v.place_id = new.place_id and private.are_friends(v.author_id, new.profile_id)
  loop
    perform private.refresh_badges(author);
  end loop;
  return null;
end;
$$;

create trigger saved_places_refresh_badges
  after insert on public.saved_places
  for each row execute function private.refresh_badges_for_save();

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

-- ── API ─────────────────────────────────────────────────────────────────────

-- Every badge with the caller's progress, level and what they've been shown.
-- Recounts first, so it is always current.
create function public.my_badges()
returns table (
  badge_id   text,
  progress   integer,
  level      smallint,
  earned_at  timestamptz,
  leveled_at timestamptz,
  seen_level smallint
)
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_badges((select auth.uid()));
  return query
    select b.id, coalesce(p.progress, 0), coalesce(ub.level, 0::smallint), ub.earned_at, ub.leveled_at,
           coalesce(ub.seen_level, 0::smallint)
    from public.badges b
    left join private.badge_progress((select auth.uid())) p on p.badge_id = b.id
    left join public.user_badges ub on ub.badge_id = b.id and ub.profile_id = (select auth.uid())
    order by b.sort_order;
end;
$$;

-- The celebration for these badges has been shown (BDG-5).
create function public.mark_badges_seen(badge_ids text[])
returns void
language sql
security definer
set search_path = ''
as $$
  update public.user_badges
  set seen_level = level
  where profile_id = (select auth.uid()) and badge_id = any (badge_ids);
$$;

-- "Map sharer": the caller copied or sent their map link.
create function public.record_map_shared()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set map_shared_at = coalesce(map_shared_at, now()) where id = (select auth.uid());
  perform private.refresh_badges((select auth.uid()));
end;
$$;

revoke execute on function private.badge_progress(uuid) from public, anon, authenticated;
revoke execute on function private.refresh_badges(uuid) from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_visit() from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_list() from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_list_member() from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_friendship() from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_save() from public, anon, authenticated;
revoke execute on function private.refresh_badges_for_thanks() from public, anon, authenticated;
revoke execute on function public.my_badges() from public, anon;
revoke execute on function public.mark_badges_seen(text[]) from public, anon;
revoke execute on function public.record_map_shared() from public, anon;
grant execute on function public.my_badges() to authenticated;
grant execute on function public.mark_badges_seen(text[]) to authenticated;
grant execute on function public.record_map_shared() to authenticated;

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.badges enable row level security;
alter table public.user_badges enable row level security;
alter table public.badge_congrats enable row level security;
alter table public.festivals enable row level security;

create policy "Signed-in users read the festival calendar"
  on public.festivals for select
  to authenticated
  using (true);

create policy "Signed-in users read the catalogue"
  on public.badges for select
  to authenticated
  using (true);

-- Your own, and the badges of anyone whose profile you can see.
create policy "Badges are visible with the profile"
  on public.user_badges for select
  to authenticated
  using (private.can_view_profile(profile_id));

create policy "Owner, sender and the owner's friends see congrats"
  on public.badge_congrats for select
  to authenticated
  using (
    (select auth.uid()) in (owner_id, from_id)
    or private.are_friends((select auth.uid()), owner_id)
  );

create policy "Friends send congrats as themselves"
  on public.badge_congrats for insert
  to authenticated
  with check (from_id = (select auth.uid()) and private.are_friends((select auth.uid()), owner_id));

create policy "Senders take back their congrats"
  on public.badge_congrats for delete
  to authenticated
  using (from_id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────────
-- No insert/update on badges or user_badges: only the functions above write.

grant select on public.badges to authenticated;
grant select on public.user_badges to authenticated;
grant select on public.festivals to authenticated;
grant select, delete on public.badge_congrats to authenticated;
grant insert (owner_id, badge_id) on public.badge_congrats to authenticated;
grant all on public.badges, public.user_badges, public.badge_congrats, public.festivals to service_role;
