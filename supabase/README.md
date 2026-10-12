# Clarity — Supabase

Postgres + Auth + Storage for Clarity. Design: [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) §5.

```
supabase/
  config.toml                 # local stack config (auth, test OTPs, schema_paths)
  schemas/                    # SOURCE OF TRUTH — declarative schema, one file per domain
    00_foundation.sql         #   extensions, enums, private schema, shared triggers
    01_profiles.sql           #   profiles (+ is_username_available)
    02_friendships.sql        #   friendships, are_friends / friend_ids / can_view_profile
    03_places.sql             #   places (PostGIS location) + nearby_places
    04_visits.sql             #   visits, visit_photos
    05_saved_places.sql
    06_lists.sql              #   lists, list_members, list_items, list_item_votes
    07_social.sql             #   asks, ask_replies, likes, visit_thanks ("Thanks, went there!")
    08_notifications.sql      #   notifications + the triggers that create them
    09_badges.sql             #   badges, earned badges, Congrats, festivals, award rules + triggers
    10_feed_and_stats.sql     #   get_feed (visits, asks, lists, badges), profile_summaries
    11_account.sql            #   match_contacts, delete_my_account
    12_storage.sql            #   visit-photos bucket + policies
  migrations/                 # what actually gets applied — ONE file per change set
    20261010120000_initial_schema.sql
    20261010163000_review_recommend_and_budget.sql
    20261012120000_badges.sql
    20261013120000_badges_feed_thanks_festivals.sql
  seed.sql                    # demo data (= the app's old mock data). Local + staging only
  tests/database/rls.test.sql # pgTAP: RLS, grants, functions
```

Auth is **Supabase Auth** (`auth.users`) — no custom user tables. Phone OTP via
Twilio; the verified number lives only in `auth.users.phone`.

## Rules

1. **`schemas/` is the source of truth.** Change the schema there, never by
   clicking in the dashboard.
2. **One migration per change set.** After editing `schemas/`, generate a single
   migration with `make db-diff NAME=<what_changed>` (runs
   `supabase db schema declarative sync`) and review it. Several related changes
   = one migration, not one per table. When existing rows must be converted
   (renamed or retyped columns), write that migration by hand so no data is
   lost, then run `make db-drift` — it must report **No drift**.
3. **Never edit a migration that has been applied** (locally shared, staging or
   prod). Make a new one.
4. Every table: RLS enabled, explicit policies, explicit `grant`s (new tables are
   not auto-exposed). Security-definer helpers go in `private`.
5. Schema files hold **no data**: bucket rows, lookup rows and data fixes go
   only in migrations (see `12_storage.sql`).
6. Add a pgTAP test in `tests/database/` for every new policy or function.
7. `seed.sql` is demo data — **never** push it to production.

## Local stack

Needs Docker. Starts only the four containers the app uses (db, auth, REST API,
gateway):

```bash
make db-start        # first run applies migrations + seed.sql
make db-test         # 57 pgTAP checks
make db-drift        # migrations == schema files?
make db-reset        # rebuild from migrations + seed
make test-integration  # app ↔ Supabase end-to-end, then reset
make db-stop
```

Local URLs: API `http://127.0.0.1:54321`, DB `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.
Run the app against it with a `config/local.json` holding the local API URL and
the publishable key from `supabase status`.

## Applying to the hosted project (from your machine)

`.env` must have `SUPABASE_PROJECT_REF` and `SUPABASE_DB_PASSWORD`.

```bash
supabase login                   # once per machine (opens the browser)
make db-link                     # once: links the CLI to SUPABASE_PROJECT_REF
supabase db push --dry-run       # see what would be applied
make db-push-seed                # staging, first time: migrations + demo data
make db-push                     # later changes: migrations only
```

## Hosted dashboard setup (once per project)

These live in the dashboard, not in migrations:

| Where | Setting |
| --- | --- |
| Project Settings → Data API | **Enable Data API: on** · **Automatically expose new tables: off** · **Automatic RLS: on** |
| Authentication → Providers → Phone | Enable, provider **Twilio**: Account SID, Auth Token, Message Service SID |
| Authentication → Providers → Phone → Test phone numbers | `919876543210=123456` (Bodhi, demo) · `919000000001=123456` (Rahul) |
| Authentication → Sign In / Providers | Allow new users to sign up: on |

## Demo accounts (seed)

| Who | Phone | OTP |
| --- | --- | --- |
| Bodhi Chakraborty (the demo account) | +91 98765 43210 | 123456 |
| Rahul Sen (to see the other side) | +91 90000 00001 | 123456 |
