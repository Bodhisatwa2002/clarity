-- Account-level functions: contact matching and account deletion.

-- ── Contact sync (PRD CON-2, CON-3, CON-8) ─────────────────────────────────
-- Takes the caller's contacts' numbers (E.164, e.g. +919876543210) and returns
-- only the profiles that match a verified, discoverable user. The input array
-- is never written anywhere: no table, no log. Non-users stay unknown.

create function public.match_contacts(phones text[])
returns table (profile_id uuid)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id
  from public.profiles p
  join auth.users u on u.id = p.id
  where p.discoverable_by_phone
    and p.id <> (select auth.uid())
    and u.phone_confirmed_at is not null
    -- auth.users stores phones as digits only (919876543210).
    and u.phone in (
      select regexp_replace(n, '[^0-9]', '', 'g')
      from unnest(phones[1:2000]) as n
    );
$$;

revoke execute on function public.match_contacts(text[]) from public, anon;
grant execute on function public.match_contacts(text[]) to authenticated;

-- ── Delete my account (PRD PRV-4) ──────────────────────────────────────────
-- Removes the auth user; every table cascades from profiles. Photo files in
-- Storage are removed by a server-side cleanup job (not yet built).

create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'Not signed in';
  end if;
  delete from auth.users where id = (select auth.uid());
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
