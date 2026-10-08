-- Allow signed-in users to permanently remove only their own reminders.
-- Related activity_history and push_deliveries rows follow their existing ON DELETE CASCADE constraints.
grant delete on public.reminders to authenticated;

create policy "reminders_delete_own" on public.reminders
  for delete to authenticated using ((select auth.uid()) = user_id);

notify pgrst, 'reload schema';
