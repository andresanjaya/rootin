import { describe, expect, it } from "vitest";
import { dueOccurrence, isValidTimeZone } from "./push-schedule";
import type { ReminderRow } from "./reminder-model";

const base: ReminderRow = {
  id: "r1", user_id: "u1", title: "Ganti sikat gigi", category: null, notes: null,
  schedule_type: "time", interval_value: 1, interval_unit: "month", usage_target: null, usage_count: 0,
  last_odometer_km: null, distance_interval_km: null, current_odometer_km: null,
  last_completed_at: "2026-09-06", next_due_at: "2026-10-06", snoozed_until: null,
  notification_enabled: true, notification_cycle_id: "cycle-1", archived_at: null,
  created_at: "2026-09-06T00:00:00Z", updated_at: "2026-09-06T00:00:00Z",
};

describe("push occurrence", () => {
  const now = new Date("2026-10-06T00:15:00Z");

  it("notifies only on the due date in the device time zone", () => {
    expect(dueOccurrence(base, "Asia/Makassar", now)).toEqual({ type: "time_due", dueKey: "2026-10-06" });
    expect(dueOccurrence(base, "America/Los_Angeles", now)).toBeNull();
    expect(dueOccurrence(base, "Asia/Makassar", new Date("2026-10-07T00:15:00Z"))).toBeNull();
  });

  it("uses the snoozed date and never sends an overdue burst", () => {
    const snoozed = { ...base, snoozed_until: "2026-10-10" };
    expect(dueOccurrence(snoozed, "Asia/Makassar", now)).toBeNull();
    expect(dueOccurrence(snoozed, "Asia/Makassar", new Date("2026-10-10T00:15:00Z"))).toEqual({ type: "time_due", dueKey: "2026-10-10" });
    expect(dueOccurrence(snoozed, "Asia/Makassar", new Date("2026-10-11T00:15:00Z"))).toBeNull();
  });

  it("uses a cycle id for progress targets and respects disabled reminders", () => {
    const usage = { ...base, schedule_type: "usage" as const, usage_target: 6, usage_count: 6, next_due_at: null };
    expect(dueOccurrence(usage, "Asia/Makassar", now)).toEqual({ type: "usage_due", dueKey: "cycle-1" });
    expect(dueOccurrence({ ...usage, notification_enabled: false }, "Asia/Makassar", now)).toBeNull();
    expect(dueOccurrence({ ...usage, archived_at: "2026-10-05T00:00:00Z" }, "Asia/Makassar", now)).toBeNull();
    expect(dueOccurrence({ ...usage, usage_count: 5 }, "Asia/Makassar", now)).toBeNull();
  });

  it("validates a stored time zone before cron uses it", () => {
    expect(isValidTimeZone("Asia/Makassar")).toBe(true);
    expect(isValidTimeZone("invalid/time-zone")).toBe(false);
    expect(dueOccurrence(base, "invalid/time-zone", now)).toEqual({ type: "time_due", dueKey: "2026-10-06" });
  });
});
