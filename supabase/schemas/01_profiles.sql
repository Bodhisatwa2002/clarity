-- Profiles: the public identity of a signed-in user.
--
-- Authentication itself is Supabase Auth (`auth.users`, phone OTP via Twilio).
-- The verified phone number stays in `auth.users.phone` and is never copied
-- here or exposed through the Data API.

create table public.profiles (
  id                    uuid primary key references auth.users (id) on delete cascade,
  username              extensions.citext not null unique
                          check (username::text ~ '^[a-z0-9._]{3,30}$'),
  display_name          text not null check (char_length(display_name) between 1 and 60),
  home_city             text check (char_length(home_city) <= 60),
  -- Initials-avatar tint, stable per person (design system: Avatar).
  avatar_bg             text not null default '#DDEAFB' check (avatar_bg ~ '^#[0-9A-Fa-f]{6}$'),
  avatar_fg             text not null default '#1D4E9E' check (avatar_fg ~ '^#[0-9A-Fa-f]{6}$'),
  avatar_path           text,
  -- Who can see this person's visits (PRD PRV-1). Identity is always visible
  -- to signed-in users so requests, search and contact matches work.
  visibility            public.profile_visibility not null default 'friends',
  -- "Let people who have my number find me" (PRD CON-8).
  discoverable_by_phone boolean not null default true,
  -- First time they shared their map link; earns the Map sharer badge
  -- (PRD BDG-1). Set through public.record_map_shared().
  map_shared_at         timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

comment on table public.profiles is 'Public identity of each user; one row per auth.users row.';

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.profiles enable row level security;

create policy "Signed-in users can read profiles"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Users create their own profile"
  on public.profiles for insert
  to authenticated
  with check (id = (select auth.uid()));

create policy "Users update their own profile"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select, insert, update on public.profiles to authenticated;
grant all on public.profiles to service_role;

-- ── Functions ───────────────────────────────────────────────────────────────

-- Create-profile screen: is this username free? (Case-insensitive.)
create function public.is_username_available(candidate text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select candidate ~ '^[a-z0-9._]{3,30}$'
     and not exists (
       select 1 from public.profiles p
       where p.username = candidate::extensions.citext
         and p.id <> (select auth.uid())
     );
$$;

revoke execute on function public.is_username_available(text) from public, anon;
grant execute on function public.is_username_available(text) to authenticated;
