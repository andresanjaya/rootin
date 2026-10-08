import { describe, expect, it } from "vitest";
import { activeProfileReminders, distanceIsNearDue, distanceRemainingKm, partitionProfiles, profileNearestStatus, profileReminderViews, type ProfileRow } from "./profile-model";
import { toReminderView, type ReminderRow } from "./reminder-model";

const base: ReminderRow = {
  id: "oil", user_id: "owner", profile_id: "motor", title: "Ganti oli", category: null, notes: null,
  schedule_type: "distance", interval_value: null, interval_unit: null, usage_target: null, usage_count: 0,
  last_odometer_km: 10000, distance_interval_km: 1500, current_odometer_km: 11800,
  last_completed_at: null, next_due_at: null, snoozed_until: null,
  notification_enabled: false, archived_at: null, created_at: "2026-10-01T00:00:00Z", updated_at: "2026-10-01T00:00:00Z",
};

describe("profile reminders", () => {
  it("uses one vehicle reading while keeping each service baseline separate", () => {
    const brakes = { ...base, id: "brakes", title: "Cek kampas rem", last_odometer_km: 11000, distance_interval_km: 1000 };
    expect(distanceRemainingKm(base)).toBe(-300);
    expect(distanceRemainingKm(brakes)).toBe(200);
    expect(distanceIsNearDue(base)).toBe(false);
    expect(distanceIsNearDue({ ...brakes, current_odometer_km: 11950 })).toBe(true);
    const views = profileReminderViews("motor", [base, brakes], "2026-10-08");
    expect(views).toHaveLength(2);
    expect(views.every((view) => view.status === "due" || view.status === "manual")).toBe(true);
  });

  it("keeps separate usage progress and excludes unlinked reminders from a profile", () => {
    const wash = { ...base, id: "wash", profile_id: "jacket", title: "Cuci jaket", schedule_type: "usage" as const, usage_target: 5, usage_count: 3, current_odometer_km: null };
    const inspect = { ...wash, id: "inspect", title: "Periksa jaket", usage_target: 2, usage_count: 1 };
    const legacy = { ...wash, id: "legacy", profile_id: null, title: "Tanpa profil" };
    expect(activeProfileReminders("jacket", [wash, inspect, legacy])).toHaveLength(2);
    expect(profileReminderViews("jacket", [wash, inspect, legacy], "2026-10-08").map((view) => view.statusText)).toEqual(["3 dari 5 pemakaian", "1 dari 2 pemakaian"]);
    expect(toReminderView(legacy, "2026-10-08").statusText).toBe("3 dari 5 pemakaian");
  });

  it("keeps linked reminders visible when the profile is archived", () => {
    const profile: ProfileRow = { id: "motor", user_id: "owner", name: "Motor", category: "vehicle", notes: null, odometer_km: 11800, archived_at: "2026-10-08T00:00:00Z", created_at: "2026-10-01T00:00:00Z", updated_at: "2026-10-08T00:00:00Z" };
    expect(partitionProfiles([profile])).toEqual({ active: [], archived: [profile] });
    const views = profileReminderViews("motor", [base], "2026-10-08");
    expect(views).toHaveLength(1);
    expect(profileNearestStatus(views)).toContain("Ganti oli");
    expect(profileNearestStatus([])).toBe("Belum ada reminder aktif");
  });
});
