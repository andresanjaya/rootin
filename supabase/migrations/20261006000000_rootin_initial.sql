-- Rootin MVP data. Apply with the Supabase CLI or SQL Editor as a project owner.
-- No anonymous role receives access to personal rows.

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (length(btrim(title)) between 1 and 120),
  category text check (category is null or length(category) <= 60),
  notes text check (notes is null or length(notes) <= 2000),
  schedule_type text not null check (schedule_type in ('time', 'usage', 'distance')),
  interval_value integer,
  interval_unit text check (interval_unit in ('day', 'week', 'month', 'year')),
  usage_target integer,
  usage_count integer not null default 0 check (usage_count >= 0),
  last_odometer_km numeric(12,1),
  distance_interval_km numeric(12,1),
  current_odometer_km numeric(12,1),
  last_completed_at date,
  next_due_at date,
  snoozed_until date,
  notification_enabled boolean not null default false,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  constraint valid_schedule check (
    coalesce((schedule_type = 'time' and interval_value > 0 and interval_unit is not null and last_completed_at is not null and next_due_at is not null), false)
    or coalesce((schedule_type = 'usage' and usage_target > 0 and next_due_at is null), false)
    or coalesce((schedule_type = 'distance' and last_odometer_km >= 0 and distance_interval_km > 0 and current_odometer_km >= last_odometer_km and next_due_at is null), false)
  )
);

create table public.activity_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reminder_id uuid not null,
  event_type text not null check (event_type in ('completed', 'snoozed', 'usage_incremented', 'odometer_updated', 'schedule_changed')),
  occurred_at timestamptz not null default now(),
  value_before jsonb,
  value_after jsonb,
  note text check (note is null or length(note) <= 2000),
  foreign key (reminder_id, user_id) references public.reminders(id, user_id) on delete cascade
);

create table public.push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  endpoint text not null unique,
  p256dh text not null,
  auth text not null,
  created_at timestamptz not null default now(),
  last_success_at timestamptz,
  disabled_at timestamptz
);

create index reminders_user_active_due_idx on public.reminders (user_id, archived_at, next_due_at);
create index activity_history_user_occurred_idx on public.activity_history (user_id, occurred_at desc);
create index activity_history_reminder_idx on public.activity_history (reminder_id);
create index push_subscriptions_user_idx on public.push_subscriptions (user_id);

create function public.set_reminder_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger reminders_set_updated_at
before update on public.reminders
for each row execute function public.set_reminder_updated_at();

alter table public.reminders enable row level security;
alter table public.activity_history enable row level security;
alter table public.push_subscriptions enable row level security;

revoke all on public.reminders, public.activity_history, public.push_subscriptions from anon, authenticated;
grant select, insert, update on public.reminders to authenticated;
grant select, insert on public.activity_history to authenticated;
grant select, insert, update, delete on public.push_subscriptions to authenticated;

create policy "reminders_select_own" on public.reminders
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "reminders_insert_own" on public.reminders
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "reminders_update_own" on public.reminders
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "history_select_own" on public.activity_history
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "history_insert_own" on public.activity_history
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "subscriptions_select_own" on public.push_subscriptions
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "subscriptions_insert_own" on public.push_subscriptions
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "subscriptions_update_own" on public.push_subscriptions
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "subscriptions_delete_own" on public.push_subscriptions
  for delete to authenticated using ((select auth.uid()) = user_id);

notify pgrst, 'reload schema';
