import { todayISO, type ReminderRow } from "./reminder-model";

export type PushOccurrence = {
  type: "time_due" | "usage_due" | "distance_due";
  dueKey: string;
};

export function dueOccurrence(reminder: ReminderRow, timeZone: string, now = new Date()): PushOccurrence | null {
  if (reminder.archived_at || !reminder.notification_enabled) return null;
  if (reminder.schedule_type === "time") {
    const due = reminder.snoozed_until && reminder.next_due_at && reminder.snoozed_until > reminder.next_due_at
      ? reminder.snoozed_until : reminder.next_due_at;
    return due === todayISO(isValidTimeZone(timeZone) ? timeZone : "Asia/Makassar", now) ? { type: "time_due", dueKey: due } : null;
  }
  const cycle = reminder.notification_cycle_id ?? reminder.last_completed_at ?? reminder.created_at;
  if (reminder.schedule_type === "usage" && reminder.usage_target !== null && reminder.usage_count >= reminder.usage_target) {
    return { type: "usage_due", dueKey: cycle };
  }
  if (reminder.schedule_type === "distance" && reminder.last_odometer_km !== null && reminder.distance_interval_km !== null
    && reminder.current_odometer_km !== null && reminder.current_odometer_km >= reminder.last_odometer_km + reminder.distance_interval_km) {
    return { type: "distance_due", dueKey: cycle };
  }
  return null;
}

export function isValidTimeZone(value: string) {
  try { new Intl.DateTimeFormat("en-US", { timeZone: value }); return true; }
  catch { return false; }
}
