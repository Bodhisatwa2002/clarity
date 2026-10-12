-- Notifications: in-app activity for one recipient (PRD NTF-1, NTF-2).
-- The app writes the sentence from `kind` + `payload`, so wording can change
-- without a migration.
--
-- payload keys by kind:
--   joined         {}
--   friend_request {}
--   liked          {"place": "Neermahal", "others": 3}
--   thanks         {"place": "Hilltop Momo Stall"}
--   nudge          {"place": "Lakeside Reading Café", "minutes": 40, "place_id": "…"}
--   list_invite    {"list": "Goa trip 2027", "list_id": "…"}

create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  kind         public.notification_kind not null,
  -- Who caused it; null for system nudges.
  actor_id     uuid references public.profiles (id) on delete cascade,
  payload      jsonb not null default '{}'::jsonb,
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);

create index notifications_recipient_idx on public.notifications (recipient_id, created_at desc);

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.notifications enable row level security;

create policy "Recipients read their notifications"
  on public.notifications for select
  to authenticated
  using (recipient_id = (select auth.uid()));

create policy "Recipients mark their notifications read"
  on public.notifications for update
  to authenticated
  using (recipient_id = (select auth.uid()))
  with check (recipient_id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────────

-- Inserts come from triggers below and server-side jobs, never the client.
grant select on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant all on public.notifications to service_role;

-- ── Triggers that create notifications ──────────────────────────────────────

create function private.notify_friend_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, kind, actor_id)
  values (new.addressee_id, 'friend_request', new.requester_id);
  return new;
end;
$$;

create trigger friendships_notify_request
  after insert on public.friendships
  for each row when (new.status = 'pending')
  execute function private.notify_friend_request();

create function private.notify_list_invite()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  list_row public.lists%rowtype;
begin
  select * into list_row from public.lists where id = new.list_id;
  if new.role = 'editor' and list_row.owner_id <> new.profile_id then
    insert into public.notifications (recipient_id, kind, actor_id, payload)
    values (new.profile_id, 'list_invite', list_row.owner_id,
            jsonb_build_object('list', list_row.title, 'list_id', list_row.id));
  end if;
  return new;
end;
$$;

create trigger list_members_notify_invite
  after insert on public.list_members
  for each row execute function private.notify_list_invite();

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

revoke execute on function private.notify_friend_request() from public, anon, authenticated;
revoke execute on function private.notify_list_invite() from public, anon, authenticated;
revoke execute on function private.notify_thanks() from public, anon, authenticated;
