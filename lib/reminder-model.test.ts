import { describe, expect, it } from "vitest";
import { addInterval, todayISO, toReminderView, type ReminderRow } from "./reminder-model";

describe("addInterval", () => {
  it("adds days and weeks from the completion date", () => {
    expect(addInterval("2026-10-06", 10, "day")).toBe("2026-10-16");
    expect(addInterval("2026-10-06", 2, "week")).toBe("2026-10-20");
  });

  it("clamps the 31st to the last day of a shorter month", () => {
    expect(addInterval("2026-01-31", 1, "month")).toBe("2026-02-28");
    expect(addInterval("2024-01-31", 1, "month")).toBe("2024-02-29");
  });

  it("clamps leap day for a non-leap year", () => {
    expect(addInterval("2024-02-29", 1, "year")).toBe("2025-02-28");
    expect(addInterval("2024-02-29", 4, "year")).toBe("2028-02-29");
  });

  it("rejects invalid dates and intervals", () => {
    expect(() => addInterval("2026-02-30", 1, "month")).toThrow();
    expect(() => addInterval("2026-01-01", 0, "day")).toThrow();
  });
});

describe("due status", () => {
  const base: ReminderRow = {
    id: "r1", user_id: "u1", title: "Ganti sikat gigi", category: null, notes: null,
    schedule_type: "time", interval_value: 1, interval_unit: "month", usage_target: null, usage_count: 0,
    last_odometer_km: null, distance_interval_km: null, current_odometer_km: null,
    last_completed_at: "2026-09-06", next_due_at: "2026-10-06", snoozed_until: null,
    notification_enabled: false, archived_at: null, created_at: "2026-09-06T00:00:00Z", updated_at: "2026-09-06T00:00:00Z",
  };

  it("uses the initial user's time zone for the current date", () => {
    expect(todayISO("Asia/Makassar", new Date("2026-10-05T16:30:00Z"))).toBe("2026-10-06");
  });

  it("labels overdue and snoozed reminders without changing the base due date", () => {
    expect(toReminderView(base, "2026-10-08").status).toBe("overdue");
    expect(toReminderView({ ...base, snoozed_until: "2026-10-10" }, "2026-10-08").status).toBe("soon");
    expect(toReminderView({ ...base, snoozed_until: "2026-10-10" }, "2026-10-10").status).toBe("due");
    expect(base.next_due_at).toBe("2026-10-06");
  });

  it("does not invent a date for usage reminders", () => {
    const view = toReminderView({ ...base, schedule_type: "usage", usage_target: 6, usage_count: 4, next_due_at: null }, "2026-10-08");
    expect(view.status).toBe("manual");
    expect(view.dueDate).toBeNull();
  });
});
