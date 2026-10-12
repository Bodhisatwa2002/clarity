-- Read-side functions: the friends feed and per-person stats. Business rules
-- live here so the iPhone app, Android and the web share page get the same
-- answers.

-- ── Friends feed (PRD FEED-1) ───────────────────────────────────────────────
-- Chronological, no ranking. Four kinds of item:
--   visit — a friend logged a place
--   ask   — a friend asked for recommendations
--   list  — a friend added places to a list you're both in (grouped per day)
--   badge — a friend earned a badge or a new level (not the starter ones);
--           its like_count / liked_by_me are Congrats (PRD BDG-11)
-- Runs as the caller, so every row still passes the tables' RLS.

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

-- ── Per-person stats ────────────────────────────────────────────────────────
-- Counts and taste match for the people the app is showing. Stats are only
-- returned for profiles the caller is allowed to see (PRD PRV-1); mutual
-- friend counts are always returned so requests can say "3 mutual friends".

create function public.profile_summaries(ids uuid[])
returns table (
  profile_id     uuid,
  places_count   integer,
  cities_count   integer,
  last_place     text,
  taste_match    integer,
  mutual_friends integer
)
language sql
stable
security definer
set search_path = ''
as $$
  with targets as (
    select distinct t.id, private.can_view_profile(t.id) as visible
    from unnest(ids[1:200]) as t(id)
  ),
  my_friends as (
    select private.friend_ids() as id
  )
  select t.id,
         case when t.visible then (
           select count(distinct v.place_id)::integer from public.visits v
           where v.author_id = t.id
             and (not v.is_hidden or t.id = (select auth.uid()))
         ) end,
         case when t.visible then (
           select count(distinct coalesce(p.city, p.area))::integer
           from public.visits v join public.places p on p.id = v.place_id
           where v.author_id = t.id
             and (not v.is_hidden or t.id = (select auth.uid()))
         ) end,
         case when t.visible then (
           select p.name from public.visits v join public.places p on p.id = v.place_id
           where v.author_id = t.id
             and (not v.is_hidden or t.id = (select auth.uid()))
           order by v.visited_on desc, v.created_at desc
           limit 1
         ) end,
         -- 100 when you always agree; minus 20 points per star of average gap.
         case when t.visible and t.id <> (select auth.uid()) then (
           select round(greatest(0, 100 - avg(abs(mine.rating - theirs.rating)) * 20))::integer
           from public.visits mine
           join public.visits theirs on theirs.place_id = mine.place_id
           where mine.author_id = (select auth.uid()) 
             and theirs.author_id = t.id and not theirs.is_hidden
         ) end,
         (
           select count(*)::integer from public.friendships f
           where f.status = 'accepted'
             and t.id in (f.requester_id, f.addressee_id)
             and (case when f.requester_id = t.id then f.addressee_id else f.requester_id end)
                 in (select id from my_friends)
         )
  from targets t;
$$;

revoke execute on function public.profile_summaries(uuid[]) from public, anon;
grant execute on function public.profile_summaries(uuid[]) to authenticated;
