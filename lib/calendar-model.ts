import { sortReminders, toReminderView, type ReminderRow, type ReminderView } from "./reminder-model";

export function calendarReminders(reminders: ReminderRow[], today: string) {
  const active = reminders.filter((reminder) => !reminder.archived_at);
  const dated = sortReminders(active.filter((reminder) => reminder.schedule_type === "time")
    .map((reminder) => toReminderView(reminder, today)).filter((view) => view.dueDate !== null));
  const undated = sortReminders(active.filter((reminder) => reminder.schedule_type === "usage" || reminder.schedule_type === "distance")
    .map((reminder) => toReminderView(reminder, today)));
  const overdue = dated.filter((view) => view.dueDate! < today);
  return { dated, undated, overdue };
}

export function remindersOnDate(reminders: ReminderView[], date: string) {
  return reminders.filter((reminder) => reminder.dueDate === date);
}

export function shiftCalendarMonth(month: string, offset: number) {
  const [year, number] = month.split("-").map(Number);
  const date = new Date(Date.UTC(year, number - 1 + offset, 1));
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

export function calendarMonthDays(month: string): (string | null)[] {
  const [year, number] = month.split("-").map(Number);
  const first = new Date(Date.UTC(year, number - 1, 1));
  const offset = (first.getUTCDay() + 6) % 7; // Monday first, as used in Indonesia.
  const days = new Date(Date.UTC(year, number, 0)).getUTCDate();
  const cells = Array<string | null>(Math.ceil((offset + days) / 7) * 7).fill(null);
  for (let day = 1; day <= days; day++) cells[offset + day - 1] = `${month}-${String(day).padStart(2, "0")}`;
  return cells;
}
