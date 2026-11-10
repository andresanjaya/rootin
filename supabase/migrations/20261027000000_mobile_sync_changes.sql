-- Append-only per-user stream. Transaction-level user lock serializes commits so
-- sequences cannot become visible out of order to a checkpointing client.
create table public.mobile_sync_changes (
  sequence bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  record jsonb not null
);
create index mobile_sync_changes_owner_sequence on public.mobile_sync_changes(user_id,sequence);
alter table public.mobile_sync_changes enable row level security;
revoke all on public.mobile_sync_changes from public, anon, authenticated;

create function public.mobile_sync_capture() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(new.user_id::text, 1718));
  insert into public.mobile_sync_changes(user_id,entity_type,record)
  values(new.user_id, tg_argv[0], to_jsonb(new));
  return new;
end $$;
revoke all on function public.mobile_sync_capture() from public, anon, authenticated;

-- Backfill in migration transaction, before triggers become visible to clients.
insert into public.mobile_sync_changes(user_id,entity_type,record)
select user_id,entity_type,record from (
  select user_id, 1 rank, 'item' entity_type, to_jsonb(t) record from public.items t
  union all select user_id, 2, 'reminder', to_jsonb(t) from public.reminders t
  union all select user_id, 3, 'reminder_log', to_jsonb(t) from public.reminder_logs t
  union all select user_id, 4, 'progress_event', to_jsonb(t) from public.progress_events t
  union all select user_id, 5, 'preference', to_jsonb(t) from public.user_preferences t
) snapshot order by user_id,rank;

create trigger mobile_sync_item after insert or update on public.items
for each row execute function public.mobile_sync_capture('item');
create trigger mobile_sync_reminder after insert or update on public.reminders
for each row execute function public.mobile_sync_capture('reminder');
create trigger mobile_sync_log after insert or update on public.reminder_logs
for each row execute function public.mobile_sync_capture('reminder_log');
create trigger mobile_sync_progress after insert or update on public.progress_events
for each row execute function public.mobile_sync_capture('progress_event');
create trigger mobile_sync_preference after insert or update on public.user_preferences
for each row execute function public.mobile_sync_capture('preference');

alter function public.sync_push_mutations(jsonb) rename to mobile_sync_push_unlocked;
revoke all on function public.mobile_sync_push_unlocked(jsonb) from public, anon, authenticated;
create function public.sync_push_mutations(p_mutations jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode='28000'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(auth.uid()::text,1718));
  return public.mobile_sync_push_unlocked(p_mutations);
end $$;
revoke all on function public.sync_push_mutations(jsonb) from public,anon;
grant execute on function public.sync_push_mutations(jsonb) to authenticated;

create or replace function public.sync_pull_changes(p_cursor jsonb default null,p_limit integer default 500) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare actor uuid := auth.uid(); rows jsonb; next_sequence bigint;
begin
  if actor is null then raise exception 'Authentication required' using errcode='28000'; end if;
  if p_limit is null or p_limit < 1 or p_limit > 500 then raise exception 'Invalid limit' using errcode='22023'; end if;
  if p_cursor is not null and (jsonb_typeof(p_cursor) <> 'object' or
    (p_cursor - 'sequence') <> '{}'::jsonb or
    (p_cursor->>'sequence') !~ '^[0-9]+$') then
    raise exception 'Invalid cursor' using errcode='22023'; end if;
  with page as (
    select sequence,entity_type,record from public.mobile_sync_changes
    where user_id=actor and sequence > coalesce((p_cursor->>'sequence')::bigint,0)
    order by sequence limit p_limit
  )
  select coalesce(jsonb_agg(jsonb_build_object('entity_type',entity_type,'record',record) order by sequence),'[]'::jsonb),
    max(sequence) into rows,next_sequence from page;
  return jsonb_build_object('changes',rows,'next_cursor',
    jsonb_build_object('sequence',coalesce(next_sequence,(p_cursor->>'sequence')::bigint,0)));
end $$;
revoke all on function public.sync_pull_changes(jsonb,integer) from public,anon;
grant execute on function public.sync_pull_changes(jsonb,integer) to authenticated;
