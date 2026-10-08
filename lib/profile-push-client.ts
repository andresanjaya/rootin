import { createClient } from "@/lib/supabase/client";

export async function dispatchDueProfileReminders(profileId: string, scheduleType: "usage" | "distance") {
  const { data, error } = await createClient().from("reminders")
    .select("id,usage_count,usage_target,current_odometer_km,last_odometer_km,distance_interval_km")
    .eq("profile_id", profileId).eq("schedule_type", scheduleType)
    .eq("notification_enabled", true).is("archived_at", null);
  if (error) return false;
  const due = (data ?? []).filter((reminder) => scheduleType === "usage"
    ? reminder.usage_target !== null && reminder.usage_count >= reminder.usage_target
    : reminder.current_odometer_km !== null && reminder.last_odometer_km !== null && reminder.distance_interval_km !== null
      && reminder.current_odometer_km >= reminder.last_odometer_km + reminder.distance_interval_km);
  const results = await Promise.allSettled(due.map((reminder) => fetch("/api/push/dispatch", {
    method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ reminderId: reminder.id }),
  })));
  return results.every((result) => result.status === "fulfilled" && result.value.ok);
}
