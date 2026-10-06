-- Apply after the initial Rootin migration. Delivery claims are server-only.
alter table public.push_subscriptions
  add column time_zone text not null default 'Asia/Makassar'
  check (length(time_zone) between 1 and 64);

alter table public.reminders
  add column notification_cycle_id uuid not null default gen_random_uuid();

create table public.push_deliveries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reminder_id uuid not null,
  subscription_id uuid not null references public.push_subscriptions(id) on delete cascade,
  due_key text not null,
  notification_type text not null check (notification_type in ('time_due', 'usage_due', 'distance_due')),
  attempted_at timestamptz not null default now(),
  sent_at timestamptz,
  error_code text,
  foreign key (reminder_id, user_id) references public.reminders(id, user_id) on delete cascade,
  unique (reminder_id, due_key, notification_type, subscription_id)
);

create index push_deliveries_user_attempted_idx on public.push_deliveries (user_id, attempted_at desc);
alter table public.push_deliveries enable row level security;
revoke all on public.push_deliveries from anon, authenticated;
grant select, insert, update on public.push_deliveries to service_role;
grant select, update on public.push_subscriptions, public.reminders to service_role;

create function public.record_reminder_progress(p_reminder_id uuid, p_odometer_km numeric default null)
returns public.reminders
language plpgsql security invoker set search_path = ''
as $$
declare current_row public.reminders;
begin
  select * into current_row from public.reminders
    where id = p_reminder_id and user_id = (select auth.uid()) and archived_at is null;
  if not found then raise exception 'Reminder not found'; end if;
  if current_row.schedule_type = 'usage' then
    update public.reminders set usage_count = usage_count + 1 where id = p_reminder_id returning * into current_row;
    insert into public.activity_history (user_id, reminder_id, event_type, value_after)
      values (current_row.user_id, current_row.id, 'usage_incremented', jsonb_build_object('usage_count', current_row.usage_count));
  elsif current_row.schedule_type = 'distance' then
    if p_odometer_km is null or p_odometer_km < current_row.current_odometer_km then
      raise exception 'Odometer must not decrease';
    end if;
    update public.reminders set current_odometer_km = p_odometer_km where id = p_reminder_id returning * into current_row;
    insert into public.activity_history (user_id, reminder_id, event_type, value_after)
      values (current_row.user_id, current_row.id, 'odometer_updated', jsonb_build_object('current_odometer_km', current_row.current_odometer_km));
  else
    raise exception 'Progress is only available for usage or distance reminders';
  end if;
  return current_row;
end;
$$;

create function public.complete_reminder(p_reminder_id uuid, p_completed_on date)
returns public.reminders
language plpgsql security invoker set search_path = ''
as $$
declare current_row public.reminders;
declare target_month date;
declare final_day integer;
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
  update public.reminders set
    last_completed_at = p_completed_on,
    next_due_at = current_row.next_due_at,
    usage_count = case when schedule_type = 'usage' then 0 else usage_count end,
    last_odometer_km = case when schedule_type = 'distance' then current_odometer_km else last_odometer_km end,
    snoozed_until = null,
    notification_cycle_id = gen_random_uuid()
  where id = p_reminder_id returning * into current_row;
  insert into public.activity_history (user_id, reminder_id, event_type, value_after)
    values (current_row.user_id, current_row.id, 'completed', jsonb_build_object('completed_on', p_completed_on));
  return current_row;
end;
$$;

revoke all on function public.record_reminder_progress(uuid, numeric), public.complete_reminder(uuid, date) from public, anon;
grant execute on function public.record_reminder_progress(uuid, numeric), public.complete_reminder(uuid, date) to authenticated;

notify pgrst, 'reload schema';
