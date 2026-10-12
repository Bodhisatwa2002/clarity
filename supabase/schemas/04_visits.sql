-- Visits: one person's review of a place they actually went to — rating,
-- the required tip, review text, photos, tags, budget. Many visits per place
-- (yours, friends', revisits). Kept separate from `places` on purpose.
-- "Want to go" is not a visit: it lives in `saved_places`.

-- Tags: the built-in quick tags plus anything the reviewer types.
-- Up to 10 per visit, each 1–24 characters.
create function private.valid_tags(tags text[])
returns boolean
language sql
immutable
set search_path = ''
as $$
  select cardinality(tags) <= 10
     and coalesce((select bool_and(char_length(btrim(t)) between 1 and 24) from unnest(tags) as t), true);
$$;

revoke execute on function private.valid_tags(text[]) from public, anon;
grant execute on function private.valid_tags(text[]) to authenticated, service_role;

create table public.visits (
  id          uuid primary key default gen_random_uuid(),
  place_id    uuid not null references public.places (id) on delete cascade,
  author_id   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  visited_on  date not null default current_date,
  -- "Would you recommend it?" — false shows as Not recommended.
  recommended boolean not null default true,
  rating      numeric(2, 1) not null check (rating between 1 and 5),
  -- "One thing to know" — required (PRD REV-3).
  tip         text not null check (char_length(tip) between 1 and 90),
  body        text not null default '' check (char_length(body) <= 280),
  -- Free-form "with" labels: friend first names, "family", "solo".
  companions  text[] not null default '{}',
  tags        text[] not null default '{}' check (private.valid_tags(tags)),
  -- What it cost per person, in whole rupees. The ₹–₹₹₹₹ level is derived
  -- from this in the app.
  budget_per_person integer check (budget_per_person between 0 and 1000000),
  -- Hidden pins (home, workplace) are visible only to the author (PRD PRV-2).
  is_hidden   boolean not null default false,
  verified    boolean not null default false,
  verified_by text check (verified_by in ('gps', 'exif')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  check (verified = (verified_by is not null))
);

comment on table public.visits is 'A person''s review of a place they visited: recommend, rating, tip, budget.';

create index visits_author_idx on public.visits (author_id, visited_on desc);
create index visits_place_idx on public.visits (place_id);
create index visits_created_idx on public.visits (created_at desc);

create trigger visits_set_updated_at
  before update on public.visits
  for each row execute function private.set_updated_at();

create table public.visit_photos (
  id           uuid primary key default gen_random_uuid(),
  visit_id     uuid not null references public.visits (id) on delete cascade,
  -- Object path in the `visit-photos` bucket: {author_id}/{visit_id}/{n}.jpg
  storage_path text not null,
  position     smallint not null check (position between 0 and 4),
  created_at   timestamptz not null default now(),
  unique (visit_id, position)
);

comment on table public.visit_photos is 'Up to five photos per visit (PRD REV-5).';

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.visits enable row level security;
alter table public.visit_photos enable row level security;

create policy "Visible visits"
  on public.visits for select
  to authenticated
  using (
    author_id = (select auth.uid())
    or (not is_hidden and private.can_view_profile(author_id))
  );

create policy "Authors add their visits"
  on public.visits for insert
  to authenticated
  with check (author_id = (select auth.uid()));

create policy "Authors edit their visits"
  on public.visits for update
  to authenticated
  using (author_id = (select auth.uid()))
  with check (author_id = (select auth.uid()));

create policy "Authors delete their visits"
  on public.visits for delete
  to authenticated
  using (author_id = (select auth.uid()));

-- Photos follow their visit.
create policy "Photos of visible visits"
  on public.visit_photos for select
  to authenticated
  using (exists (select 1 from public.visits v where v.id = visit_id));

create policy "Authors manage their photos"
  on public.visit_photos for all
  to authenticated
  using (exists (select 1 from public.visits v where v.id = visit_id and v.author_id = (select auth.uid())))
  with check (exists (select 1 from public.visits v where v.id = visit_id and v.author_id = (select auth.uid())));

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select, delete on public.visits to authenticated;
-- `verified` / `verified_by` are set server-side only, never by the client.
-- `id` is allowed so the app can show a new review before the server replies.
grant insert (id, place_id, visited_on, recommended, rating, tip, body, companions, tags, budget_per_person, is_hidden)
  on public.visits to authenticated;
grant update (visited_on, recommended, rating, tip, body, companions, tags, budget_per_person, is_hidden)
  on public.visits to authenticated;
grant select, insert, delete on public.visit_photos to authenticated;
grant all on public.visits, public.visit_photos to service_role;
