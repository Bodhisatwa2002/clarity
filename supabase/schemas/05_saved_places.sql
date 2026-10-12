-- Saved places: one tap "Save to Want to go" from a friend's pin or the feed
-- (PRD PLC-4). Private to the person who saved.

create table public.saved_places (
  profile_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  place_id   uuid not null references public.places (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (profile_id, place_id)
);

comment on table public.saved_places is 'Places a user saved to Want to go.';

alter table public.saved_places enable row level security;

create policy "Users see their saved places"
  on public.saved_places for select
  to authenticated
  using (profile_id = (select auth.uid()));

create policy "Users save places for themselves"
  on public.saved_places for insert
  to authenticated
  with check (profile_id = (select auth.uid()));

create policy "Users unsave their places"
  on public.saved_places for delete
  to authenticated
  using (profile_id = (select auth.uid()));

grant select, delete on public.saved_places to authenticated;
grant insert (place_id) on public.saved_places to authenticated;
grant all on public.saved_places to service_role;
