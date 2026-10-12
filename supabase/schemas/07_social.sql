-- Social: "Ask for recs" posts, the pins friends reply with, and likes on
-- visits, asks and lists.

create table public.asks (
  id         uuid primary key default gen_random_uuid(),
  author_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  -- Where they're going: "Shillong".
  destination text not null check (char_length(destination) between 1 and 80),
  body       text not null check (char_length(body) between 1 and 280),
  created_at timestamptz not null default now()
);

create table public.ask_replies (
  id         uuid primary key default gen_random_uuid(),
  ask_id     uuid not null references public.asks (id) on delete cascade,
  author_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  place_id   uuid not null references public.places (id) on delete cascade,
  note       text not null default '' check (char_length(note) <= 140),
  created_at timestamptz not null default now(),
  unique (ask_id, author_id, place_id)
);

create table public.likes (
  profile_id   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  subject_type public.like_subject not null,
  subject_id   uuid not null,
  created_at   timestamptz not null default now(),
  primary key (profile_id, subject_type, subject_id)
);

comment on table public.asks is 'Ask for recs: "Going to Shillong next week, suggestions?"';
comment on table public.likes is 'Likes on visits, asks and lists, shown as counts in the feed.';

create index asks_author_idx on public.asks (author_id, created_at desc);
create index ask_replies_ask_idx on public.ask_replies (ask_id);
create index likes_subject_idx on public.likes (subject_type, subject_id);

-- ── Row-level security ──────────────────────────────────────────────────────

alter table public.asks enable row level security;
alter table public.ask_replies enable row level security;
alter table public.likes enable row level security;

create policy "Asks are visible like the author's profile"
  on public.asks for select
  to authenticated
  using (private.can_view_profile(author_id));

create policy "Authors post asks"
  on public.asks for insert
  to authenticated
  with check (author_id = (select auth.uid()));

create policy "Authors delete asks"
  on public.asks for delete
  to authenticated
  using (author_id = (select auth.uid()));

create policy "Replies are visible with their ask"
  on public.ask_replies for select
  to authenticated
  using (exists (select 1 from public.asks a where a.id = ask_id));

create policy "Users reply to asks they can see"
  on public.ask_replies for insert
  to authenticated
  with check (author_id = (select auth.uid()) and exists (select 1 from public.asks a where a.id = ask_id));

create policy "Authors delete their replies"
  on public.ask_replies for delete
  to authenticated
  using (author_id = (select auth.uid()));

-- Like counts are public to signed-in users; the subject's own RLS decides
-- whether anyone can see the thing being liked.
create policy "Signed-in users see likes"
  on public.likes for select
  to authenticated
  using (true);

create policy "Users like as themselves"
  on public.likes for insert
  to authenticated
  with check (profile_id = (select auth.uid()));

create policy "Users remove their likes"
  on public.likes for delete
  to authenticated
  using (profile_id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────────

grant select, delete on public.asks, public.ask_replies, public.likes to authenticated;
grant insert (destination, body) on public.asks to authenticated;
grant insert (ask_id, place_id, note) on public.ask_replies to authenticated;
grant insert (subject_type, subject_id) on public.likes to authenticated;
grant all on public.asks, public.ask_replies, public.likes to service_role;

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
