export type ScheduleType = "time" | "usage" | "distance";
export type IntervalUnit = "day" | "week" | "month" | "year";
export type ReminderStatus = "overdue" | "due" | "soon" | "later" | "manual";

export type ReminderRow = {
  id: string;
  user_id: string;
  profile_id?: string | null;
  title: string;
  category: string | null;
  notes: string | null;
  schedule_type: ScheduleType;
  interval_value: number | null;
  interval_unit: IntervalUnit | null;
  usage_target: number | null;
  usage_count: number;
  last_odometer_km: number | null;
  distance_interval_km: number | null;
  current_odometer_km: number | null;
  last_completed_at: string | null;
  next_due_at: string | null;
  snoozed_until: string | null;
  notification_enabled: boolean;
  notification_cycle_id?: string;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
};

export type ReminderView = {
  id: string;
  title: string;
  category: string;
  description: string;
  status: ReminderStatus;
  statusText: string;
  dueDate: string | null;
};

function parseDate(value: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) throw new Error("Tanggal tidak valid.");
  const [year, month, day] = value.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) throw new Error("Tanggal tidak valid.");
  return { year, month, day, date };
}

function dateISO(date: Date) {
  return date.toISOString().slice(0, 10);
}

export function addInterval(lastDate: string, value: number, unit: IntervalUnit) {
  const { year, month, day, date } = parseDate(lastDate);
  if (!Number.isInteger(value) || value < 1) throw new Error("Interval harus bilangan positif.");

  if (unit === "day" || unit === "week") {
    date.setUTCDate(date.getUTCDate() + value * (unit === "week" ? 7 : 1));
    return dateISO(date);
  }

  const totalMonths = year * 12 + (month - 1) + value * (unit === "year" ? 12 : 1);
  const targetYear = Math.floor(totalMonths / 12);
  const targetMonth = totalMonths % 12;
  const lastDay = new Date(Date.UTC(targetYear, targetMonth + 1, 0)).getUTCDate();
  return dateISO(new Date(Date.UTC(targetYear, targetMonth, Math.min(day, lastDay))));
}

export function todayISO(timeZone = "Asia/Makassar", now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-US", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).formatToParts(now);
  const part = (type: string) => parts.find((item) => item.type === type)?.value;
  return `${part("year")}-${part("month")}-${part("day")}`;
}

export function toReminderView(reminder: ReminderRow, today: string): ReminderView {
  const base = { id: reminder.id, title: reminder.title, category: reminder.category ?? "Tanpa kategori" };
  if (reminder.schedule_type === "usage") {
    const count = reminder.usage_count;
    const target = reminder.usage_target ?? 0;
    return { ...base, description: "Berdasarkan pemakaian", status: count >= target ? "due" : "manual", statusText: count >= target ? "Target pemakaian tercapai" : `${count} dari ${target} pemakaian`, dueDate: null };
  }
  if (reminder.schedule_type === "distance") {
    const remaining = (reminder.last_odometer_km ?? 0) + (reminder.distance_interval_km ?? 0) - (reminder.current_odometer_km ?? 0);
    return { ...base, description: "Berdasarkan jarak tempuh", status: remaining <= 0 ? "due" : "manual", statusText: remaining <= 0 ? "Target jarak tercapai" : `${new Intl.NumberFormat("id-ID").format(remaining)} km lagi`, dueDate: null };
  }

  const dueDate = reminder.snoozed_until && reminder.next_due_at && reminder.snoozed_until > reminder.next_due_at ? reminder.snoozed_until : reminder.next_due_at;
  const days = dueDate ? Math.round((Date.parse(`${dueDate}T00:00:00Z`) - Date.parse(`${today}T00:00:00Z`)) / 86400000) : 0;
  const unitLabels: Record<IntervalUnit, string> = { day: "hari", week: "minggu", month: "bulan", year: "tahun" };
  const description = `Setiap ${reminder.interval_value} ${unitLabels[reminder.interval_unit ?? "day"]}`;
  const status: ReminderStatus = days < 0 ? "overdue" : days === 0 ? "due" : days <= 7 ? "soon" : "later";
  const statusText = days < 0 ? `Terlambat ${Math.abs(days)} hari` : days === 0 ? "Jatuh tempo hari ini" : `Dalam ${days} hari`;
  return { ...base, description, status, statusText, dueDate };
}

export function sortReminders(reminders: ReminderView[]) {
  const priority: Record<ReminderStatus, number> = { overdue: 0, due: 1, soon: 2, later: 3, manual: 4 };
  return [...reminders].sort((a, b) => priority[a.status] - priority[b.status] || (a.dueDate ?? "9999").localeCompare(b.dueDate ?? "9999") || a.title.localeCompare(b.title, "id"));
}
