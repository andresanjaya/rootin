import { describe, expect, it } from "vitest";
import { calendarMonthDays, calendarReminders, remindersOnDate, shiftCalendarMonth } from "./calendar-model";
import type { ReminderRow } from "./reminder-model";

const base: ReminderRow = {
  id: "a", user_id: "owner", title: "Ganti sikat gigi", category: null, notes: null,
  schedule_type: "time", interval_value: 1, interval_unit: "month", usage_target: null, usage_count: 0,
  last_odometer_km: null, distance_interval_km: null, current_odometer_km: null,
  last_completed_at: "2026-09-06", next_due_at: "2026-10-06", snoozed_until: null,
  notification_enabled: false, archived_at: null, created_at: "2026-09-06T00:00:00Z", updated_at: "2026-09-06T00:00:00Z",
};

describe("calendar reminders", () => {
  it("uses the existing effective due date after snooze and groups multiple reminders on one day", () => {
    const reminders = [
      { ...base, snoozed_until: "2026-10-12" },
      { ...base, id: "b", title: "Cek tanaman", next_due_at: "2026-10-12" },
    ];
    const { dated } = calendarReminders(reminders, "2026-10-11");
    expect(remindersOnDate(dated, "2026-10-06")).toHaveLength(0);
    expect(remindersOnDate(dated, "2026-10-12").map((item) => item.id).sort()).toEqual(["a", "b"]);
    expect(dated.every((item) => item.status === "soon")).toBe(true);
  });

  it("keeps overdue reminders from earlier months and never invents dates for usage or distance", () => {
    const usage: ReminderRow = { ...base, id: "usage", schedule_type: "usage", usage_target: 4, usage_count: 4, next_due_at: null };
    const distance: ReminderRow = { ...base, id: "distance", schedule_type: "distance", last_odometer_km: 1000, distance_interval_km: 500, current_odometer_km: 1400, next_due_at: null };
    const archived = { ...base, id: "archived", archived_at: "2026-10-02T00:00:00Z" };
    const { dated, undated, overdue } = calendarReminders([{ ...base, next_due_at: "2026-09-30" }, usage, distance, archived], "2026-10-11");
    expect(dated.map((item) => item.id)).toEqual(["a"]);
    expect(overdue.map((item) => item.id)).toEqual(["a"]);
    expect(undated.map((item) => item.id)).toEqual(["usage", "distance"]);
    expect(undated.every((item) => item.dueDate === null)).toBe(true);
  });

  it("starts the Indonesian calendar on Monday and handles month boundaries", () => {
    expect(calendarMonthDays("2026-10").slice(0, 4)).toEqual([null, null, null, "2026-10-01"]);
    expect(calendarMonthDays("2024-02").filter(Boolean)).toHaveLength(29);
    expect(shiftCalendarMonth("2026-12", 1)).toBe("2027-01");
    expect(shiftCalendarMonth("2026-01", -1)).toBe("2025-12");
  });
});
