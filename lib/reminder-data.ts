import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";
import type { ReminderRow } from "./reminder-model";

export async function getReminders(supabase: SupabaseClient, userId: string, includeArchived = false) {
  let query = supabase.from("reminders").select("*").eq("user_id", userId);
  if (!includeArchived) query = query.is("archived_at", null);
  const { data, error } = await query.order("created_at", { ascending: false });
  return { reminders: (data ?? []) as ReminderRow[], error };
}

export type HistoryRow = {
  id: string;
  user_id: string;
  reminder_id: string;
  event_type: "completed" | "snoozed" | "usage_incremented" | "odometer_updated" | "schedule_changed";
  occurred_at: string;
  note: string | null;
};

export async function getHistory(supabase: SupabaseClient, userId: string) {
  const { data, error } = await supabase.from("activity_history").select("id,user_id,reminder_id,event_type,occurred_at,note").eq("user_id", userId).order("occurred_at", { ascending: false }).limit(100);
  return { history: (data ?? []) as HistoryRow[], error };
}
