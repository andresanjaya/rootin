-- Private, optional photo for each item profile. Existing profiles remain unchanged.
begin;

alter table public.item_profiles add column photo_path text
  check (photo_path is null or length(photo_path) <= 128);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('rootin-profile-photos', 'rootin-profile-photos', false, 4194304,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- One stable object key per profile makes replacement an upsert, so it cannot
-- leave an older version at a second path. The profile must belong to the user.
create function public.owns_profile_photo_path(p_path text)
returns boolean language sql stable security invoker set search_path = '' as $$
  select exists (
    select 1 from public.item_profiles p
    where p.user_id = (select auth.uid())
      and p_path = p.user_id::text || '/' || p.id::text || '/photo'
  );
$$;

revoke all on function public.owns_profile_photo_path(text) from public, anon;
grant execute on function public.owns_profile_photo_path(text) to authenticated;

create policy "profile_photos_select_own" on storage.objects
  for select to authenticated using (
    bucket_id = 'rootin-profile-photos' and public.owns_profile_photo_path(name)
  );
create policy "profile_photos_insert_own" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'rootin-profile-photos' and public.owns_profile_photo_path(name)
  );
create policy "profile_photos_update_own" on storage.objects
  for update to authenticated using (
    bucket_id = 'rootin-profile-photos' and public.owns_profile_photo_path(name)
  ) with check (
    bucket_id = 'rootin-profile-photos' and public.owns_profile_photo_path(name)
  );
create policy "profile_photos_delete_own" on storage.objects
  for delete to authenticated using (
    bucket_id = 'rootin-profile-photos' and public.owns_profile_photo_path(name)
  );

-- Direct column updates stay disallowed by the MVP 2 grants. This RPC checks
-- both the profile owner and the existence of the uploaded private object.
create function public.set_item_profile_photo(p_profile_id uuid, p_photo_path text)
returns public.item_profiles language plpgsql security definer set search_path = '' as $$
declare updated_row public.item_profiles;
declare expected_path text;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;
  expected_path := (select auth.uid())::text || '/' || p_profile_id::text || '/photo';
  if p_photo_path is not null then
    if p_photo_path <> expected_path or not exists (
      select 1 from storage.objects where bucket_id = 'rootin-profile-photos' and name = p_photo_path
    ) then raise exception 'Invalid profile photo'; end if;
  end if;
  update public.item_profiles set photo_path = p_photo_path
    where id = p_profile_id and user_id = (select auth.uid())
    returning * into updated_row;
  if not found then raise exception 'Profile not found'; end if;
  return updated_row;
end;
$$;

revoke all on function public.set_item_profile_photo(uuid, text) from public, anon;
grant execute on function public.set_item_profile_photo(uuid, text) to authenticated;

notify pgrst, 'reload schema';
commit;
