-- Mobile-only schema. Clients may read their own rows; mutations pass through
-- the SECURITY DEFINER RPC so ownership, revision and operation replay are atomic.
create table public.items (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  category text not null check (category in ('vehicle','appliance','furniture','facility','other')),
  brand text, model_number text, serial_or_plate_number text, purchase_date date,
  has_odometer boolean not null default false,
  current_odometer bigint not null default 0 check (current_odometer >= 0),
  photo_remote_path text, notes text, is_archived boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, version integer not null default 1 check (version > 0),
  unique (id,user_id),
  check (photo_remote_path is null or photo_remote_path like user_id::text || '/' || id::text || '/%')
);
create table public.reminders (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  item_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 150),
  engine_type text not null check (engine_type in ('time','usage','mileage')),
  interval_unit text check (interval_unit in ('days','weeks','months','years')),
  interval_value integer check (interval_value > 0),
  baseline_mode text not null default 'actual_completion' check (baseline_mode in ('actual_completion','strict_schedule')),
  anchor_day smallint check (anchor_day between 1 and 31), target_date date, target_time time,
  usage_counter integer not null default 0 check (usage_counter >= 0),
  usage_threshold integer check (usage_threshold > 0), usage_unit text,
  last_service_odometer bigint check (last_service_odometer >= 0), interval_km integer check (interval_km > 0),
  snooze_until timestamptz, is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, version integer not null default 1 check (version > 0),
  unique (id,user_id), foreign key (item_id,user_id) references public.items(id,user_id),
  check ((engine_type = 'time' and interval_unit is not null and interval_value is not null and target_date is not null)
     or (engine_type = 'usage' and usage_threshold is not null)
     or (engine_type = 'mileage' and interval_km is not null and last_service_odometer is not null))
);
create table public.reminder_logs (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  item_id uuid not null, reminder_id uuid not null,
  completed_at timestamptz not null, completion_date date not null,
  odometer_at_completion bigint check (odometer_at_completion >= 0),
  cost numeric(12,2) check (cost >= 0), performed_by text, notes text,
  created_at timestamptz not null default now(), version integer not null default 1,
  foreign key (item_id,user_id) references public.items(id,user_id),
  foreign key (reminder_id,user_id) references public.reminders(id,user_id)
);
create table public.progress_events (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  item_id uuid not null, reminder_id uuid,
  amount bigint not null check (amount > 0),
  kind text not null check (kind in ('usage','odometer')),
  recorded_at timestamptz not null default now(),
  foreign key (item_id,user_id) references public.items(id,user_id),
  foreign key (reminder_id,user_id) references public.reminders(id,user_id),
  check ((kind = 'usage' and reminder_id is not null) or (kind = 'odometer' and reminder_id is null))
);
create table public.user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  locale text not null default 'id' check (locale in ('id','en')),
  distance_unit text not null default 'km' check (distance_unit in ('km','mi')),
  time_zone text not null default 'UTC',
  updated_at timestamptz not null default now(), version integer not null default 1 check (version > 0)
);
create table public.processed_operations (
  operation_id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  request jsonb not null, result jsonb not null,
  processed_at timestamptz not null default now()
);
create index on public.items(user_id,updated_at,id);
create index on public.reminders(user_id,updated_at,id);
create index on public.reminder_logs(user_id,created_at,id);
create index on public.progress_events(user_id,recorded_at,id);
create index on public.processed_operations(user_id);

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('item-photos','item-photos',false,2097152,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy mobile_photo_read on storage.objects for select to authenticated using (
  bucket_id='item-photos' and (storage.foldername(name))[1]=auth.uid()::text
  and exists(select 1 from public.items where id=(storage.foldername(name))[2]::uuid
    and user_id=auth.uid() and deleted_at is null));
create policy mobile_photo_insert on storage.objects for insert to authenticated with check (
  bucket_id='item-photos' and (storage.foldername(name))[1]=auth.uid()::text
  and exists(select 1 from public.items where id=(storage.foldername(name))[2]::uuid
    and user_id=auth.uid() and deleted_at is null));
create policy mobile_photo_delete on storage.objects for delete to authenticated using (
  bucket_id='item-photos' and (storage.foldername(name))[1]=auth.uid()::text
  and exists(select 1 from public.items where id=(storage.foldername(name))[2]::uuid
    and user_id=auth.uid()));

alter table public.items enable row level security;
alter table public.reminders enable row level security;
alter table public.reminder_logs enable row level security;
alter table public.progress_events enable row level security;
alter table public.user_preferences enable row level security;
alter table public.processed_operations enable row level security;
create policy owner_read on public.items for select to authenticated using (user_id = (select auth.uid()));
create policy owner_read on public.reminders for select to authenticated using (user_id = (select auth.uid()));
create policy owner_read on public.reminder_logs for select to authenticated using (user_id = (select auth.uid()));
create policy owner_read on public.progress_events for select to authenticated using (user_id = (select auth.uid()));
create policy owner_read on public.user_preferences for select to authenticated using (user_id = (select auth.uid()));
create policy owner_read on public.processed_operations for select to authenticated using (user_id = (select auth.uid()));
revoke all on public.items,public.reminders,public.reminder_logs,public.progress_events,public.user_preferences,public.processed_operations from anon,authenticated;
grant select on public.items,public.reminders,public.reminder_logs,public.progress_events,public.user_preferences to authenticated;

create function public.sync_push_mutations(p_mutations jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  actor uuid := auth.uid(); m jsonb; op uuid; rec uuid; kind text; action text;
  payload jsonb; expected integer; current_version integer; owner uuid; parent uuid;
  previous_completion date; completion_date date; cycle_date date;
  result jsonb; previous public.processed_operations%rowtype; outcomes jsonb := '[]'::jsonb;
begin
  if actor is null then raise exception 'Authentication required' using errcode = '28000'; end if;
  if jsonb_typeof(p_mutations) is distinct from 'array' or jsonb_array_length(p_mutations) > 100 then
    raise exception 'Expected array of at most 100 mutations' using errcode = '22023';
  end if;
  for m in select value from jsonb_array_elements(p_mutations) loop
    op := (m->>'operation_id')::uuid;
    rec := (m->>'record_id')::uuid;
    kind := m->>'entity_type'; action := m->>'operation_type';
    payload := m->'payload'; expected := (m->>'version')::integer;
    if op is null or rec is null or expected is null or expected < 1 or jsonb_typeof(payload) <> 'object' then
      raise exception 'Missing operation_id, record_id, version or payload' using errcode = '22023';
    end if;
    -- Concurrent requests with the same operation ID serialize before checking the ledger.
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(op::text,0));
    select * into previous from public.processed_operations where operation_id = op;
    if found then
      if previous.user_id <> actor then raise exception 'Operation belongs to another user' using errcode = '42501'; end if;
      if previous.request <> m then raise exception 'Operation ID reused with different request' using errcode = '22023'; end if;
      outcomes := outcomes || previous.result;
      continue;
    end if;
    current_version := null; owner := null;
    -- Parent-first lock order across reminder edits, progress, completion and item deletion.
    if kind = 'reminder' and action <> 'insert' then
      select item_id into parent from public.reminders where id=rec;
      if parent is not null then perform 1 from public.items where id=parent for update; end if;
    end if;
    if kind = 'item' then
      select user_id,version into owner,current_version from public.items where id = rec for update;
    elsif kind = 'reminder' then
      select user_id,version into owner,current_version from public.reminders where id = rec for update;
      if action in ('update','link') and current_version is not null then
        perform 1 from public.items where id=(select item_id from public.reminders where id=rec)
          and user_id=actor and deleted_at is null and not is_archived;
        if not found then raise exception 'Active owned item required' using errcode='42501'; end if;
      end if;
    elsif kind = 'preference' then
      if rec <> actor then raise exception 'Preferences must use user ID' using errcode = '42501'; end if;
      select user_id,version into owner,current_version from public.user_preferences where user_id = rec for update;
    elsif kind not in ('progress','completion') then
      raise exception 'Unsupported entity type' using errcode = '22023';
    end if;
    if owner is not null and owner <> actor then raise exception 'Record belongs to another user' using errcode = '42501'; end if;
    if kind in ('item','reminder','preference') and
       ((action = 'insert' and current_version is not null) or
        (action <> 'insert' and (current_version is null or current_version <> expected))) then
      result := jsonb_build_object('operation_id',op,'status','conflict_rejected','server_version',current_version);
    elsif kind = 'item' then
      if action = 'insert' then
        if expected <> 1 then raise exception 'Insert version must be 1' using errcode = '22023'; end if;
        insert into public.items(id,user_id,name,category,brand,model_number,serial_or_plate_number,purchase_date,has_odometer,current_odometer,photo_remote_path,notes)
        values(rec,actor,payload->>'name',payload->>'category',payload->>'brand',payload->>'model_number',payload->>'serial_or_plate_number',
          (payload->>'purchase_date')::date,coalesce((payload->>'has_odometer')::boolean,false),coalesce((payload->>'current_odometer')::bigint,0),payload->>'photo_remote_path',payload->>'notes');
      elsif action in ('update','archive','delete') then
        if (select deleted_at is not null from public.items where id=rec) then raise exception 'Item deleted' using errcode='22023'; end if;
        if action in ('archive','delete') then
          update public.reminders set is_active=false,
            deleted_at=case when action='delete' then now() else deleted_at end,
            updated_at=now(),version=version+1 where item_id=rec and deleted_at is null;
        end if;
        update public.items set name=case when action='update' then coalesce(payload->>'name',name) else name end,
          category=case when action='update' then coalesce(payload->>'category',category) else category end,
          brand=case when action='update' and payload ? 'brand' then payload->>'brand' else brand end,
          model_number=case when action='update' and payload ? 'model_number' then payload->>'model_number' else model_number end,
          serial_or_plate_number=case when action='update' and payload ? 'serial_or_plate_number' then payload->>'serial_or_plate_number' else serial_or_plate_number end,
          purchase_date=case when action='update' and payload ? 'purchase_date' then (payload->>'purchase_date')::date else purchase_date end,
          has_odometer=case when action='update' then coalesce((payload->>'has_odometer')::boolean,has_odometer) else has_odometer end,
          current_odometer=case when action='update' then coalesce((payload->>'current_odometer')::bigint,current_odometer) else current_odometer end,
          photo_remote_path=case when action='update' and payload ? 'photo_remote_path' then payload->>'photo_remote_path' else photo_remote_path end,
          notes=case when action='update' and payload ? 'notes' then payload->>'notes' else notes end,
          is_archived=case when action='archive' then true else is_archived end,
          deleted_at=case when action='delete' then now() else deleted_at end,
          updated_at=now(),version=version+1 where id=rec;
        if action='update' and payload ? 'current_odometer' and
          (select current_odometer from public.items where id=rec) <
          coalesce((select max(e.amount) from public.progress_events e where e.item_id=rec and e.kind='odometer'),0) then
          raise exception 'Odometer cannot decrease' using errcode='22023';
        end if;
      else raise exception 'Unsupported item action' using errcode='22023'; end if;
      result := jsonb_build_object('operation_id',op,'status','accepted','version',coalesce(current_version,0)+1);
    elsif kind = 'reminder' then
      parent := (payload->>'item_id')::uuid;
      if action = 'update' and payload ? 'engine_type' then raise exception 'Engine type cannot be changed' using errcode='22023'; end if;
      if action = 'insert' then
        if expected <> 1 then raise exception 'Insert version must be 1' using errcode='22023'; end if;
        perform 1 from public.items where id=parent and user_id=actor and deleted_at is null and not is_archived for update;
        if not found then raise exception 'Active owned item required' using errcode='42501'; end if;
        insert into public.reminders(id,user_id,item_id,name,engine_type,interval_unit,interval_value,baseline_mode,anchor_day,target_date,target_time,usage_counter,usage_threshold,usage_unit,last_service_odometer,interval_km)
        values(rec,actor,parent,payload->>'name',payload->>'engine_type',payload->>'interval_unit',(payload->>'interval_value')::integer,
          coalesce(payload->>'baseline_mode','actual_completion'),(payload->>'anchor_day')::smallint,(payload->>'target_date')::date,(payload->>'target_time')::time,
          coalesce((payload->>'usage_counter')::integer,0),(payload->>'usage_threshold')::integer,payload->>'usage_unit',(payload->>'last_service_odometer')::bigint,(payload->>'interval_km')::integer);
      elsif action in ('update','archive','delete','link') then
        if (select deleted_at is not null from public.reminders where id=rec) then raise exception 'Reminder deleted' using errcode='22023'; end if;
        if action = 'update' and payload ? 'item_id' then raise exception 'Use link to change item' using errcode='22023'; end if;
        if action = 'link' then
          perform 1 from public.items where id=parent and user_id=actor and deleted_at is null and not is_archived for update;
          if not found then raise exception 'Active owned item required' using errcode='42501'; end if;
        end if;
        update public.reminders set item_id=case when action='link' then parent else item_id end,
          name=case when action='update' then coalesce(payload->>'name',name) else name end,
          interval_unit=case when action='update' and payload ? 'interval_unit' then payload->>'interval_unit' else interval_unit end,
          baseline_mode=case when action='update' and payload ? 'baseline_mode' then payload->>'baseline_mode' else baseline_mode end,
          anchor_day=case when action='update' and payload ? 'anchor_day' then (payload->>'anchor_day')::smallint else anchor_day end,
          target_date=case when action='update' and payload ? 'target_date' then (payload->>'target_date')::date else target_date end,
          target_time=case when action='update' and payload ? 'target_time' then (payload->>'target_time')::time else target_time end,
          interval_value=case when action='update' then coalesce((payload->>'interval_value')::integer,interval_value) else interval_value end,
          usage_threshold=case when action='update' then coalesce((payload->>'usage_threshold')::integer,usage_threshold) else usage_threshold end,
          usage_unit=case when action='update' and payload ? 'usage_unit' then payload->>'usage_unit' else usage_unit end,
          last_service_odometer=case when action='update' then coalesce((payload->>'last_service_odometer')::bigint,last_service_odometer) else last_service_odometer end,
          interval_km=case when action='update' then coalesce((payload->>'interval_km')::integer,interval_km) else interval_km end,
          snooze_until=case when action='update' and payload ? 'snooze_until' then (payload->>'snooze_until')::timestamptz else snooze_until end,
          is_active=case when action='archive' then false when action='update' then coalesce((payload->>'is_active')::boolean,is_active) else is_active end,
          deleted_at=case when action='delete' then now() else deleted_at end,
          updated_at=now(),version=version+1 where id=rec;
      else raise exception 'Unsupported reminder action' using errcode='22023'; end if;
      result := jsonb_build_object('operation_id',op,'status','accepted','version',coalesce(current_version,0)+1);
    elsif kind = 'preference' then
      if action = 'insert' then
        if expected <> 1 then raise exception 'Insert version must be 1' using errcode='22023'; end if;
        insert into public.user_preferences(user_id,locale,distance_unit,time_zone)
        values(actor,coalesce(payload->>'locale','id'),coalesce(payload->>'distance_unit','km'),coalesce(payload->>'time_zone','UTC'));
      elsif action = 'update' then
        update public.user_preferences set locale=coalesce(payload->>'locale',locale),distance_unit=coalesce(payload->>'distance_unit',distance_unit),
          time_zone=coalesce(payload->>'time_zone',time_zone),version=version+1,updated_at=now() where user_id=actor;
      else raise exception 'Unsupported preference action' using errcode='22023'; end if;
      result := jsonb_build_object('operation_id',op,'status','accepted','version',coalesce(current_version,0)+1);
    elsif kind = 'progress' and action = 'insert' then
      if expected <> 1 then raise exception 'Event version must be 1' using errcode='22023'; end if;
      parent := (payload->>'item_id')::uuid;
      perform 1 from public.items where id=parent and user_id=actor and deleted_at is null and not is_archived for update;
      if not found then raise exception 'Active owned item required' using errcode='42501'; end if;
      if payload->>'kind' = 'usage' then
        if (payload->>'amount')::bigint > 2147483647 then raise exception 'Usage increment too large' using errcode='22023'; end if;
        update public.reminders set usage_counter=usage_counter+(payload->>'amount')::integer,version=version+1,updated_at=now()
          where id=(payload->>'reminder_id')::uuid and item_id=parent and user_id=actor and engine_type='usage' and deleted_at is null and is_active;
        if not found then raise exception 'Active owned usage reminder required' using errcode='42501'; end if;
      elsif payload->>'kind' = 'odometer' then
        update public.items set current_odometer=(payload->>'amount')::bigint,version=version+1,updated_at=now()
          where id=parent and (payload->>'amount')::bigint >= current_odometer;
        if not found then raise exception 'Odometer cannot decrease' using errcode='22023'; end if;
      else raise exception 'Invalid progress kind' using errcode='22023'; end if;
      insert into public.progress_events(id,user_id,item_id,reminder_id,kind,amount)
      values(rec,actor,parent,(payload->>'reminder_id')::uuid,payload->>'kind',(payload->>'amount')::bigint);
      result := jsonb_build_object('operation_id',op,'status','accepted');
    elsif kind = 'completion' and action = 'insert' then
      parent := (payload->>'reminder_id')::uuid;
      if (payload->>'completed_at')::timestamptz is null or (payload->>'completion_date')::date is null then
        raise exception 'Completion date and instant required' using errcode='22023'; end if;
      perform 1 from public.items where id=(payload->>'item_id')::uuid and user_id=actor and deleted_at is null for update;
      if not found then raise exception 'Owned item required' using errcode='42501'; end if;
      select version into current_version from public.reminders where id=parent and item_id=(payload->>'item_id')::uuid and user_id=actor and deleted_at is null and is_active for update;
      if not found then raise exception 'Active owned reminder required' using errcode='42501'; end if;
      if current_version <> expected then
        result := jsonb_build_object('operation_id',op,'status','conflict_rejected','server_version',current_version);
      else
        completion_date := (payload->>'completion_date')::date;
        select max(l.completion_date) into previous_completion from public.reminder_logs l where l.reminder_id=parent;
        select case when baseline_mode='strict_schedule' then target_date else completion_date end
          into cycle_date from public.reminders where id=parent;
        insert into public.reminder_logs(id,user_id,item_id,reminder_id,completed_at,completion_date,odometer_at_completion,cost,performed_by,notes)
        values(rec,actor,(payload->>'item_id')::uuid,parent,(payload->>'completed_at')::timestamptz,(payload->>'completion_date')::date,
          (payload->>'odometer_at_completion')::bigint,(payload->>'cost')::numeric,payload->>'performed_by',payload->>'notes');
        update public.reminders set usage_counter=case when engine_type='usage' and (previous_completion is null or completion_date >= previous_completion)
            then coalesce((select sum(e.amount)::integer from public.progress_events e
              where e.reminder_id=parent and e.kind='usage' and e.recorded_at > (payload->>'completed_at')::timestamptz),0)
            else usage_counter end,
          last_service_odometer=case when engine_type='mileage' then greatest(last_service_odometer,coalesce((payload->>'odometer_at_completion')::bigint,last_service_odometer)) else last_service_odometer end,
          target_date=case when engine_type='time' and (previous_completion is null or completion_date >= previous_completion) then
            case interval_unit when 'days' then cycle_date + interval_value
              when 'weeks' then cycle_date + interval_value*7
              else ((date_trunc('month',cycle_date)::date +
                (interval_value * case when interval_unit='years' then 12 else 1 end || ' months')::interval)::date +
                (least(coalesce(anchor_day,extract(day from cycle_date)::integer),
                  extract(day from (date_trunc('month',cycle_date)::date +
                    ((interval_value * case when interval_unit='years' then 12 else 1 end + 1) || ' months')::interval - interval '1 day'))::integer)-1)) end
            else target_date end,
          anchor_day=case when engine_type='time' and interval_unit in ('months','years') and anchor_day is null
            then extract(day from cycle_date)::integer else anchor_day end,
          snooze_until=null,version=version+1,updated_at=now() where id=parent;
        result := jsonb_build_object('operation_id',op,'status','accepted','version',current_version+1);
      end if;
    else raise exception 'Unsupported action' using errcode='22023'; end if;
    insert into public.processed_operations(operation_id,user_id,request,result) values(op,actor,m,result);
    outcomes := outcomes || result;
  end loop;
  return jsonb_build_object('server_timestamp',now(),'mutations_result',outcomes);
end $$;
revoke all on function public.sync_push_mutations(jsonb) from public,anon;
grant execute on function public.sync_push_mutations(jsonb) to authenticated;

-- Keyset cursor: (changed_at, entity rank, id) is stable even for identical timestamps.
create function public.sync_pull_changes(p_cursor jsonb default null,p_limit integer default 500) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare actor uuid := auth.uid(); rows jsonb; last_cursor jsonb;
begin
  if actor is null then raise exception 'Authentication required' using errcode='28000'; end if;
  if p_limit is null or p_limit < 1 or p_limit > 500 then raise exception 'Invalid limit' using errcode='22023'; end if;
  if p_cursor is not null and (p_cursor->>'changed_at' is null or p_cursor->>'rank' is null or p_cursor->>'id' is null) then
    raise exception 'Invalid cursor' using errcode='22023'; end if;
  with changes as (
    select updated_at changed_at,1 rank,id,'item' entity,to_jsonb(t) data from public.items t where user_id=actor
    union all select updated_at,2,id,'reminder',to_jsonb(t) from public.reminders t where user_id=actor
    union all select created_at,3,id,'reminder_log',to_jsonb(t) from public.reminder_logs t where user_id=actor
    union all select recorded_at,4,id,'progress_event',to_jsonb(t) from public.progress_events t where user_id=actor
    union all select updated_at,5,user_id,'preference',to_jsonb(t) from public.user_preferences t where user_id=actor
  ), page as (
    select * from changes where p_cursor is null or (changed_at,rank,id) >
      ((p_cursor->>'changed_at')::timestamptz,(p_cursor->>'rank')::integer,(p_cursor->>'id')::uuid)
    order by changed_at,rank,id limit p_limit
  )
  select coalesce(jsonb_agg(jsonb_build_object('entity_type',entity,'record',data) order by changed_at,rank,id),'[]'::jsonb),
    (select jsonb_build_object('changed_at',changed_at,'rank',rank,'id',id) from page order by changed_at desc,rank desc,id desc limit 1)
  into rows,last_cursor from page;
  return jsonb_build_object('changes',rows,'next_cursor',coalesce(last_cursor,p_cursor));
end $$;
revoke all on function public.sync_pull_changes(jsonb,integer) from public,anon;
grant execute on function public.sync_pull_changes(jsonb,integer) to authenticated;
