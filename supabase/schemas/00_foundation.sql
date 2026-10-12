-- Foundation: extensions, enum types, the private helper schema and shared
-- trigger functions. Every later schema file builds on these.
--
-- Conventions used by every schema file in this folder:
--   * Tables live in `public` and are reached through the Data API.
--   * Row-level security is enabled on every table, with explicit policies.
--   * New tables are NOT auto-exposed, so each file grants exactly the
--     privileges the app needs to `authenticated` (and never more to `anon`).
--   * Security-definer helpers live in `private`, which the Data API does not
--     expose, so they can be used by policies but not called over HTTP.

-- Supabase platform extensions, declared so schema tooling never drops them.
create extension if not exists pgcrypto with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;

create extension if not exists postgis with schema extensions;
create extension if not exists citext with schema extensions;

-- ── Enum types ──────────────────────────────────────────────────────────────

create type public.place_category as enum (
  'food', 'cafe', 'stay', 'trek', 'viewpoint', 'temple', 'beach', 'shop', 'other'
);

create type public.profile_visibility as enum ('public', 'friends', 'private');

create type public.friendship_status as enum ('pending', 'accepted');

create type public.list_role as enum ('owner', 'editor');

create type public.like_subject as enum ('visit', 'ask', 'list');

create type public.notification_kind as enum (
  'joined', 'friend_request', 'liked', 'thanks', 'nudge', 'list_invite'
);

-- ── Private schema for helpers ──────────────────────────────────────────────

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

-- ── Shared triggers ─────────────────────────────────────────────────────────

-- Keeps `updated_at` current on every UPDATE.
create function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
