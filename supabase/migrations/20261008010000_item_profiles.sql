-- Rootin MVP 2. Apply after the initial, push, and reminder-delete migrations.
-- Existing reminders remain unlinked; no existing reminder or history row is rewritten.

begin;

create table public.item_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(btrim(name)) between 1 and 120),
  category text not null check (category in ('vehicle', 'clothing', 'personal_care', 'other')),
  notes text check (notes is null or length(notes) <= 2000),
  odometer_km numeric(12,1) check (odometer_km is null or odometer_km >= 0),
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  constraint vehicle_odometer check (
    (category = 'vehicle' and odometer_km is not null) or
    (category <> 'vehicle' and odometer_km is null)
  )
);

create table public.profile_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  profile_id uuid not null,
  event_type text not null check (event_type in ('usage_logged', 'odometer_updated', 'odometer_corrected')),
  occurred_on date not null,
  odometer_before_km numeric(12,1),
  odometer_after_km numeric(12,1),
  created_at timestamptz not null default now(),
  foreign key (profile_id, user_id) references public.item_profiles(id, user_id) on delete cascade
);

alter table public.reminders add column profile_id uuid;
alter table public.reminders add constraint reminders_profile_owner_fk
  foreign key (profile_id, user_id) references public.item_profiles(id, user_id);

-- A confirmed odometer correction may place the reading below a reminder's
-- individual service baseline. The baseline stays intact.
alter table public.reminders drop constraint valid_schedule;
alter table public.reminders add constraint valid_schedule check (
  coalesce((schedule_type = 'time' and interval_value > 0 and interval_unit is not null and last_completed_at is not null and next_due_at is not null), false)
  or coalesce((schedule_type = 'usage' and usage_target > 0 and next_due_at is null), false)
  or coalesce((schedule_type = 'distance' and last_odometer_km >= 0 and distance_interval_km > 0 and current_odometer_km >= 0 and next_due_at is null), false)
);

create index item_profiles_user_active_idx on public.item_profiles (user_id, archived_at, created_at desc);
create index reminders_profile_idx on public.reminders (profile_id, archived_at);
create index profile_events_profile_date_idx on public.profile_events (profile_id, occurred_on desc, created_at desc);

create trigger item_profiles_set_updated_at
before update on public.item_profiles
for each row execute function public.set_reminder_updated_at();

alter table public.item_profiles enable row level security;
alter table public.profile_events enable row level security;
revoke all on public.item_profiles, public.profile_events from anon, authenticated;
grant select, insert on public.item_profiles to authenticated;
grant update (archived_at) on public.item_profiles to authenticated;
grant select on public.profile_events to authenticated;

create policy "item_profiles_select_own" on public.item_profiles
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "item_profiles_insert_own" on public.item_profiles
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "item_profiles_archive_own" on public.item_profiles
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "profile_events_select_own" on public.profile_events
  for select to authenticated using ((select auth.uid()) = user_id);

-- Keep the current reading of a linked vehicle reminder equal to its profile.
create function public.sync_reminder_profile_reading()
returns trigger language plpgsql set search_path = '' as $$
declare linked_profile public.item_profiles;
declare attaching boolean := false;
begin
  if new.profile_id is null then return new; end if;
  if tg_op = 'INSERT' then
    attaching := true;
  else
    attaching := new.profile_id is distinct from old.profile_id;
  end if;
  select * into linked_profile from public.item_profiles
    where id = new.profile_id and user_id = new.user_id;
  if not found then raise exception 'Profile not found'; end if;
  if attaching and linked_profile.archived_at is not null then
    raise exception 'Archived profile cannot receive reminders';
  end if;
  if linked_profile.category = 'vehicle' and new.schedule_type = 'distance' then
    new.current_odometer_km := linked_profile.odometer_km;
  end if;
  return new;
end;
$$;

create trigger reminders_sync_profile_reading
before insert or update of profile_id, schedule_type on public.reminders
for each row execute function public.sync_reminder_profile_reading();

create function public.set_reminder_profile(p_reminder_id uuid, p_profile_id uuid)
returns public.reminders language plpgsql security definer set search_path = '' as $$
declare linked_profile public.item_profiles;
declare updated_row public.reminders;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;
  if p_profile_id is not null then
    select * into linked_profile from public.item_profiles
      where id = p_profile_id and user_id = (select auth.uid()) and archived_at is null;
    if not found then raise exception 'Profile not found or archived'; end if;
  end if;
  update public.reminders set profile_id = p_profile_id
    where id = p_reminder_id and user_id = (select auth.uid()) and archived_at is null
    returning * into updated_row;
  if not found then raise exception 'Reminder not found'; end if;
  return updated_row;
end;
$$;

create function public.update_item_profile(
  p_profile_id uuid, p_name text, p_category text, p_notes text, p_odometer_km numeric
) returns public.item_profiles language plpgsql security definer set search_path = '' as $$
declare previous public.item_profiles;
declare updated_row public.item_profiles;
declare last_vehicle_reading numeric;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;
  select * into previous from public.item_profiles
    where id = p_profile_id and user_id = (select auth.uid()) for update;
  if not found then raise exception 'Profile not found'; end if;
  if p_category not in ('vehicle', 'clothing', 'personal_care', 'other') then raise exception 'Invalid category'; end if;
  if p_category = 'vehicle' and (p_odometer_km is null or p_odometer_km < 0) then
    raise exception 'Vehicle odometer is required';
  end if;
  if p_category = 'vehicle' and previous.category = 'vehicle'
     and p_odometer_km is distinct from previous.odometer_km then
    raise exception 'Use the odometer action to change a reading';
  end if;
  if p_category = 'vehicle' and previous.category <> 'vehicle' then
    select odometer_after_km into last_vehicle_reading from public.profile_events
      where profile_id = p_profile_id and event_type in ('odometer_updated', 'odometer_corrected')
      order by created_at desc limit 1;
    if last_vehicle_reading is not null and p_odometer_km < last_vehicle_reading then
      raise exception 'Restore the previous reading, then confirm a correction';
    end if;
  end if;
  update public.item_profiles set
    name = p_name, category = p_category, notes = nullif(btrim(p_notes), ''),
    odometer_km = case when p_category = 'vehicle' then p_odometer_km else null end
  where id = p_profile_id returning * into updated_row;
  if p_category = 'vehicle' and previous.category <> 'vehicle' then
    update public.reminders set current_odometer_km = p_odometer_km
      where profile_id = p_profile_id and schedule_type = 'distance';
    insert into public.profile_events (user_id, profile_id, event_type, occurred_on, odometer_after_km)
      values (updated_row.user_id, updated_row.id, 'odometer_updated', (now() at time zone 'Asia/Makassar')::date, p_odometer_km);
  end if;
  return updated_row;
end;
$$;

create function public.update_profile_odometer(
  p_profile_id uuid, p_odometer_km numeric, p_confirm_correction boolean, p_recorded_on date
) returns public.item_profiles language plpgsql security definer set search_path = '' as $$
declare previous public.item_profiles;
declare updated_row public.item_profiles;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;
  if p_odometer_km is null or p_odometer_km < 0 or p_recorded_on is null then
    raise exception 'Valid odometer and date are required';
  end if;
  select * into previous from public.item_profiles
    where id = p_profile_id and user_id = (select auth.uid()) and category = 'vehicle' for update;
  if not found then raise exception 'Vehicle profile not found'; end if;
  if p_odometer_km = previous.odometer_km then return previous; end if;
  if p_odometer_km < previous.odometer_km and not coalesce(p_confirm_correction, false) then
    raise exception 'Confirm odometer correction';
  end if;
  update public.item_profiles set odometer_km = p_odometer_km
    where id = p_profile_id returning * into updated_row;
  with changed as (
    update public.reminders set current_odometer_km = p_odometer_km
      where profile_id = p_profile_id and schedule_type = 'distance'
      returning id, user_id
  )
  insert into public.activity_history (user_id, reminder_id, event_type, value_after)
    select user_id, id, 'odometer_updated',
      jsonb_build_object('current_odometer_km', p_odometer_km, 'source', 'profile') from changed;
  insert into public.profile_events
    (user_id, profile_id, event_type, occurred_on, odometer_before_km, odometer_after_km)
    values (updated_row.user_id, updated_row.id,
      case when p_odometer_km < previous.odometer_km then 'odometer_corrected' else 'odometer_updated' end,
      p_recorded_on, previous.odometer_km, p_odometer_km);
  return updated_row;
end;
$$;

create function public.log_profile_wear(p_profile_id uuid, p_worn_on date)
returns public.profile_events language plpgsql security definer set search_path = '' as $$
declare linked_profile public.item_profiles;
declare new_event public.profile_events;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required'; end if;
  if p_worn_on is null then raise exception 'Wear date is required'; end if;
  select * into linked_profile from public.item_profiles
    where id = p_profile_id and user_id = (select auth.uid()) and category = 'clothing' for update;
  if not found then raise exception 'Clothing profile not found'; end if;
  insert into public.profile_events (user_id, profile_id, event_type, occurred_on)
    values (linked_profile.user_id, p_profile_id, 'usage_logged', p_worn_on)
    returning * into new_event;
  with changed as (
    update public.reminders set usage_count = usage_count + 1
      where profile_id = p_profile_id and schedule_type = 'usage' and archived_at is null
        and (last_completed_at is null or last_completed_at <= p_worn_on)
      returning id, user_id, usage_count
  )
  insert into public.activity_history (user_id, reminder_id, event_type, value_after)
    select user_id, id, 'usage_incremented',
      jsonb_build_object('usage_count', usage_count, 'worn_on', p_worn_on, 'source', 'profile') from changed;
  return new_event;
end;
$$;

-- Keep MVP 1 manual progress, while a linked vehicle uses the shared reading.
create or replace function public.record_reminder_progress(p_reminder_id uuid, p_odometer_km numeric default null)
returns public.reminders language plpgsql security invoker set search_path = '' as $$
declare current_row public.reminders;
declare linked_category text;
begin
  select * into current_row from public.reminders
    where id = p_reminder_id and user_id = (select auth.uid()) and archived_at is null;
  if not found then raise exception 'Reminder not found'; end if;
  if current_row.schedule_type = 'usage' then
    update public.reminders set usage_count = usage_count + 1 where id = p_reminder_id returning * into current_row;
    insert into public.activity_history (user_id, reminder_id, event_type, value_after)
      values (current_row.user_id, current_row.id, 'usage_incremented',
        jsonb_build_object('usage_count', current_row.usage_count, 'source', 'manual'));
  elsif current_row.schedule_type = 'distance' then
    if current_row.profile_id is not null then
      select category into linked_category from public.item_profiles where id = current_row.profile_id;
    end if;
    if linked_category = 'vehicle' then
      perform public.update_profile_odometer(current_row.profile_id, p_odometer_km, false, (now() at time zone 'Asia/Makassar')::date);
      select * into current_row from public.reminders where id = p_reminder_id;
    else
      if p_odometer_km is null or p_odometer_km < current_row.current_odometer_km then
        raise exception 'Odometer must not decrease';
      end if;
      update public.reminders set current_odometer_km = p_odometer_km
        where id = p_reminder_id returning * into current_row;
      insert into public.activity_history (user_id, reminder_id, event_type, value_after)
        values (current_row.user_id, current_row.id, 'odometer_updated',
          jsonb_build_object('current_odometer_km', current_row.current_odometer_km));
    end if;
  else
    raise exception 'Progress is only available for usage or distance reminders';
  end if;
  return current_row;
end;
$$;

-- For clothing, a backdated completion retains later wear and manual progress.
create or replace function public.complete_reminder(p_reminder_id uuid, p_completed_on date)
returns public.reminders language plpgsql security invoker set search_path = '' as $$
declare current_row public.reminders;
declare target_month date;
declare final_day integer;
declare linked_category text;
declare remaining_usage integer := 0;
begin
  if p_completed_on is null then raise exception 'Completion date is required'; end if;
  select * into current_row from public.reminders
    where id = p_reminder_id and user_id = (select auth.uid()) and archived_at is null;
  if not found then raise exception 'Reminder not found'; end if;
  if current_row.schedule_type = 'time' then
    if current_row.interval_unit = 'day' then
      current_row.next_due_at := p_completed_on + current_row.interval_value;
    elsif current_row.interval_unit = 'week' then
      current_row.next_due_at := p_completed_on + current_row.interval_value * 7;
    else
      target_month := (date_trunc('month', p_completed_on)::date +
        make_interval(months => current_row.interval_value * case when current_row.interval_unit = 'year' then 12 else 1 end))::date;
      final_day := extract(day from (target_month + interval '1 month' - interval '1 day'))::integer;
      current_row.next_due_at := target_month + least(extract(day from p_completed_on)::integer, final_day) - 1;
    end if;
  end if;
  if current_row.schedule_type = 'usage' and current_row.profile_id is not null then
    select category into linked_category from public.item_profiles where id = current_row.profile_id;
    if linked_category = 'clothing' then
      select count(*) into remaining_usage from public.profile_events
        where profile_id = current_row.profile_id and event_type = 'usage_logged' and occurred_on > p_completed_on;
      remaining_usage := remaining_usage + (
        select count(*) from public.activity_history
          where reminder_id = current_row.id and event_type = 'usage_incremented'
            and value_after->>'source' is distinct from 'profile'
            and (occurred_at at time zone 'Asia/Makassar')::date > p_completed_on
      );
    end if;
  end if;
  update public.reminders set
    last_completed_at = p_completed_on,
    next_due_at = current_row.next_due_at,
    usage_count = case when schedule_type = 'usage' then remaining_usage else usage_count end,
    last_odometer_km = case when schedule_type = 'distance' then current_odometer_km else last_odometer_km end,
    snoozed_until = null,
    notification_cycle_id = gen_random_uuid()
  where id = p_reminder_id returning * into current_row;
  insert into public.activity_history (user_id, reminder_id, event_type, value_after)
    values (current_row.user_id, current_row.id, 'completed', jsonb_build_object('completed_on', p_completed_on));
  return current_row;
end;
$$;

revoke all on function public.sync_reminder_profile_reading(),
  public.set_reminder_profile(uuid, uuid),
  public.update_item_profile(uuid, text, text, text, numeric),
  public.update_profile_odometer(uuid, numeric, boolean, date),
  public.log_profile_wear(uuid, date) from public, anon;
grant execute on function public.set_reminder_profile(uuid, uuid),
  public.update_item_profile(uuid, text, text, text, numeric),
  public.update_profile_odometer(uuid, numeric, boolean, date),
  public.log_profile_wear(uuid, date) to authenticated;

notify pgrst, 'reload schema';

commit;
