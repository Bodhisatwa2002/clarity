-- Places: real-world locations, shared by everyone. A place never holds an
-- opinion — ratings and reviews live in `visits`.

create table public.places (
  id              uuid primary key default gen_random_uuid(),
  -- Google Places (New) id; null for pins dropped by hand.
  google_place_id text unique,
  name            text not null check (char_length(name) between 1 and 120),
  category        public.place_category not null,
  lat             double precision not null check (lat between -90 and 90),
  lng             double precision not null check (lng between -180 and 180),
  -- Derived from lat/lng for PostGIS queries ("within 2 km", clustering).
  location        extensions.geography(point, 4326)
                    generated always as (
                      extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326)::extensions.geography
                    ) stored,
  -- Short locality for meta lines ("Melaghar") and the longer address.
  area            text not null default '' check (char_length(area) <= 80),
  address         text not null default '' check (char_length(address) <= 200),
  city            text check (char_length(city) <= 80),
  -- Indian state or union territory ("Tripura"), for the States and Seven
  -- Sisters badges. Null until known (Google Places fills it later).
  state           text check (char_length(state) <= 60),
  country_code    char(2) not null default 'IN',
  created_by      uuid default auth.uid() references public.profiles (id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table public.places is 'Shared, opinion-free places. Deduplicated by google_place_id.';

create index places_location_idx on public.places using gist (location);
create index places_name_idx on public.places (lower(name) text_pattern_ops);

create trigger places_set_updated_at
  before update on public.places
  for each row execute function private.set_updated_at();

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.places enable row level security;

create policy "Signed-in users can read places"
  on public.places for select
  to authenticated
  using (true);

create policy "Signed-in users add places as themselves"
  on public.places for insert
  to authenticated
  with check (created_by = (select auth.uid()));

-- Only dropped pins (no Google id) can be edited, and only by their creator.
create policy "Creators edit their dropped pins"
  on public.places for update
  to authenticated
  using (created_by = (select auth.uid()) and google_place_id is null)
  with check (created_by = (select auth.uid()) and google_place_id is null);

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select on public.places to authenticated;
-- `id` is allowed so the app can create a pin optimistically with its own UUID.
grant insert (id, google_place_id, name, category, lat, lng, area, address, city, state, country_code)
  on public.places to authenticated;
grant update (name, category, lat, lng, area, address, city, state) on public.places to authenticated;
grant all on public.places to service_role;

-- ── Functions ───────────────────────────────────────────────────────────────

-- "I'm here": places within `radius_m` of a point, nearest first.
-- Parameters are prefixed so they can't be confused with the lat/lng columns.
create function public.nearby_places(at_lat double precision, at_lng double precision, radius_m integer default 2000)
returns table (place_id uuid, distance_m double precision)
language sql
stable
set search_path = ''
as $$
  select p.id,
         extensions.st_distance(
           p.location,
           extensions.st_setsrid(extensions.st_makepoint(at_lng, at_lat), 4326)::extensions.geography
         )
  from public.places p
  where extensions.st_dwithin(
          p.location,
          extensions.st_setsrid(extensions.st_makepoint(at_lng, at_lat), 4326)::extensions.geography,
          radius_m
        )
  order by 2
  limit 20;
$$;

revoke execute on function public.nearby_places(double precision, double precision, integer) from public, anon;
grant execute on function public.nearby_places(double precision, double precision, integer) to authenticated;
