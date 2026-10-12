-- Lists: named collections of places. Collaborative lists have several
-- members who add places and vote on them (PRD LST-1, LST-2).

create table public.lists (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  title         text not null check (char_length(title) between 1 and 80),
  -- "planning for Jan 2027".
  planning_note text not null default '' check (char_length(planning_note) <= 80),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table public.list_members (
  list_id    uuid not null references public.lists (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  role       public.list_role not null default 'editor',
  joined_at  timestamptz not null default now(),
  primary key (list_id, profile_id)
);

create table public.list_items (
  id         uuid primary key default gen_random_uuid(),
  list_id    uuid not null references public.lists (id) on delete cascade,
  place_id   uuid not null references public.places (id) on delete cascade,
  added_by   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (list_id, place_id)
);

create table public.list_item_votes (
  item_id    uuid not null references public.list_items (id) on delete cascade,
  profile_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (item_id, profile_id)
);

comment on table public.lists is 'Personal and collaborative lists of places.';

create index list_members_profile_idx on public.list_members (profile_id);
create index list_items_list_idx on public.list_items (list_id, created_at desc);

create trigger lists_set_updated_at
  before update on public.lists
  for each row execute function private.set_updated_at();

-- The owner is always a member.
create function private.add_list_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.list_members (list_id, profile_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict do nothing;
  return new;
end;
$$;

create trigger lists_add_owner
  after insert on public.lists
  for each row execute function private.add_list_owner();

-- True when the caller is a member of the list.
create function private.is_list_member(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.list_members m
    where m.list_id = target and m.profile_id = (select auth.uid())
  );
$$;

revoke execute on function private.add_list_owner() from public, anon, authenticated;
revoke execute on function private.is_list_member(uuid) from public, anon;
grant execute on function private.is_list_member(uuid) to authenticated;

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.lists enable row level security;
alter table public.list_members enable row level security;
alter table public.list_items enable row level security;
alter table public.list_item_votes enable row level security;

create policy "Members see their lists"
  on public.lists for select
  to authenticated
  using (owner_id = (select auth.uid()) or private.is_list_member(id));

create policy "Users create lists they own"
  on public.lists for insert
  to authenticated
  with check (owner_id = (select auth.uid()));

create policy "Owners edit their lists"
  on public.lists for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "Owners delete their lists"
  on public.lists for delete
  to authenticated
  using (owner_id = (select auth.uid()));

create policy "Members see who else is in the list"
  on public.list_members for select
  to authenticated
  using (private.is_list_member(list_id));

-- Owners invite friends; members can leave.
create policy "Owners add members"
  on public.list_members for insert
  to authenticated
  with check (
    exists (select 1 from public.lists l where l.id = list_id and l.owner_id = (select auth.uid()))
    and private.are_friends((select auth.uid()), profile_id)
  );

create policy "Owners remove members, members leave"
  on public.list_members for delete
  to authenticated
  using (
    profile_id = (select auth.uid())
    or exists (select 1 from public.lists l where l.id = list_id and l.owner_id = (select auth.uid()))
  );

create policy "Members see items"
  on public.list_items for select
  to authenticated
  using (private.is_list_member(list_id));

create policy "Members add items"
  on public.list_items for insert
  to authenticated
  with check (added_by = (select auth.uid()) and private.is_list_member(list_id));

create policy "Members remove items"
  on public.list_items for delete
  to authenticated
  using (private.is_list_member(list_id));

create policy "Members see votes"
  on public.list_item_votes for select
  to authenticated
  using (exists (select 1 from public.list_items i where i.id = item_id));

create policy "Members vote as themselves"
  on public.list_item_votes for insert
  to authenticated
  with check (
    profile_id = (select auth.uid())
    and exists (select 1 from public.list_items i where i.id = item_id)
  );

create policy "Members remove their vote"
  on public.list_item_votes for delete
  to authenticated
  using (profile_id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select, delete on public.lists to authenticated;
grant insert (title, planning_note) on public.lists to authenticated;
grant update (title, planning_note) on public.lists to authenticated;
grant select, insert, delete on public.list_members to authenticated;
grant select, delete on public.list_items to authenticated;
grant insert (list_id, place_id) on public.list_items to authenticated;
grant select, delete on public.list_item_votes to authenticated;
grant insert (item_id) on public.list_item_votes to authenticated;
grant all on public.lists, public.list_members, public.list_items, public.list_item_votes to service_role;
