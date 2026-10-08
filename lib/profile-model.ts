import { sortReminders, toReminderView, type ReminderRow, type ReminderView } from "./reminder-model";

export type ProfileCategory = "vehicle" | "clothing" | "personal_care" | "other";

export type ProfileRow = {
  id: string;
  user_id: string;
  name: string;
  category: ProfileCategory;
  notes: string | null;
  odometer_km: number | null;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
};

export type ProfileEvent = {
  id: string;
  profile_id: string;
  event_type: "usage_logged" | "odometer_updated" | "odometer_corrected";
  occurred_on: string;
  odometer_before_km: number | null;
  odometer_after_km: number | null;
  created_at: string;
};

export const profileCategoryLabels: Record<ProfileCategory, string> = {
  vehicle: "Kendaraan",
  clothing: "Pakaian",
  personal_care: "Perawatan diri",
  other: "Lainnya",
};

export function partitionProfiles(profiles: ProfileRow[]) {
  return {
    active: profiles.filter((profile) => !profile.archived_at),
    archived: profiles.filter((profile) => Boolean(profile.archived_at)),
  };
}

export function activeProfileReminders(profileId: string, reminders: ReminderRow[]) {
  return reminders.filter((reminder) => reminder.profile_id === profileId && !reminder.archived_at);
}

export function profileReminderViews(profileId: string, reminders: ReminderRow[], today: string): ReminderView[] {
  return sortReminders(activeProfileReminders(profileId, reminders).map((reminder) => toReminderView(reminder, today)));
}

export function profileNearestStatus(views: ReminderView[]) {
  if (!views.length) return "Belum ada reminder aktif";
  const urgent = views.find((view) => view.status === "overdue" || view.status === "due" || view.status === "soon");
  return urgent ? `${urgent.title}: ${urgent.statusText}` : `${views[0].title}: ${views[0].statusText}`;
}

export function distanceRemainingKm(reminder: ReminderRow) {
  if (reminder.schedule_type !== "distance" || reminder.last_odometer_km === null || reminder.distance_interval_km === null || reminder.current_odometer_km === null) return null;
  return reminder.last_odometer_km + reminder.distance_interval_km - reminder.current_odometer_km;
}

export function distanceIsNearDue(reminder: ReminderRow) {
  const remaining = distanceRemainingKm(reminder);
  return remaining !== null && remaining > 0 && reminder.distance_interval_km !== null
    && remaining <= reminder.distance_interval_km / 10;
}
