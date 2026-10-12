-- Friendships: mutual connections. A row is a request until the addressee
-- accepts it. One row per pair, whichever direction it was sent in.

create table public.friendships (
  requester_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  addressee_id uuid not null references public.profiles (id) on delete cascade,
  status       public.friendship_status not null default 'pending',
  created_at   timestamptz not null default now(),
  responded_at timestamptz,
  primary key (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

comment on table public.friendships is 'Friend requests (pending) and friendships (accepted).';

-- Only one row per pair, regardless of who asked.
create unique index friendships_pair_key
  on public.friendships (least(requester_id, addressee_id), greatest(requester_id, addressee_id));

create index friendships_addressee_idx on public.friendships (addressee_id, status);

-- Stamp the time a request was accepted.
create function private.stamp_friendship_response()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = 'accepted' and old.status = 'pending' then
    new.responded_at := now();
  end if;
  return new;
end;
$$;

create trigger friendships_stamp_response
  before update on public.friendships
  for each row execute function private.stamp_friendship_response();

-- ── Helpers used by policies everywhere ─────────────────────────────────────

-- True when a and b are accepted friends.
create function private.are_friends(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.friendships f
    where f.status = 'accepted'
      and ((f.requester_id = a and f.addressee_id = b)
        or (f.requester_id = b and f.addressee_id = a))
  );
$$;

-- The caller's accepted friends.
create function private.friend_ids()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case when f.requester_id = (select auth.uid()) then f.addressee_id else f.requester_id end
  from public.friendships f
  where f.status = 'accepted'
    and (select auth.uid()) in (f.requester_id, f.addressee_id);
$$;

-- Can the caller see `owner`'s visits, lists and stats? (PRD PRV-1)
--   public  → every signed-in user
--   friends → accepted friends
--   private → only the owner
create function private.can_view_profile(owner uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select owner = (select auth.uid())
      or exists (
        select 1 from public.profiles p
        where p.id = owner
          and (p.visibility = 'public'
            or (p.visibility = 'friends' and private.are_friends((select auth.uid()), owner)))
      );
$$;

revoke execute on all functions in schema private from public, anon;
grant execute on function private.are_friends(uuid, uuid) to authenticated;
grant execute on function private.friend_ids() to authenticated;
grant execute on function private.can_view_profile(uuid) to authenticated;

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.friendships enable row level security;

create policy "Either side can see the friendship"
  on public.friendships for select
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

create policy "Users send requests as themselves"
  on public.friendships for insert
  to authenticated
  with check (requester_id = (select auth.uid()) and status = 'pending');

create policy "The addressee accepts a request"
  on public.friendships for update
  to authenticated
  using (addressee_id = (select auth.uid()) and status = 'pending')
  with check (addressee_id = (select auth.uid()) and status = 'accepted');

-- Decline, cancel and unfriend are all deletes.
create policy "Either side can remove the friendship"
  on public.friendships for delete
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select, insert, delete on public.friendships to authenticated;
grant update (status) on public.friendships to authenticated;
grant all on public.friendships to service_role;
