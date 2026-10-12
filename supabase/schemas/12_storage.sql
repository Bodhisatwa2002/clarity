-- Storage: the private bucket for review photos.
-- Object paths: {author_id}/{visit_id}/{position}.jpg — the first folder is
-- the owner, which is what the policies check.
--
-- The bucket row itself is data, which schema files must not contain. It is
-- created in migrations/20261010120000_initial_schema.sql:
--   visit-photos · private · 5 MB · jpeg, png, heic, webp

create policy "Visit photos are visible like the author's profile"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'visit-photos'
    and private.can_view_profile(((storage.foldername(name))[1])::uuid)
  );

create policy "Authors upload photos to their own folder"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'visit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Authors delete their own photos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'visit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
