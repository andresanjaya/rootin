import { z } from "zod";
import { addInterval, type IntervalUnit, type ScheduleType } from "./reminder-model";

const positiveInteger = z.preprocess((value) => value === "" ? undefined : value, z.coerce.number().int().positive().optional());
const nonNegativeNumber = z.preprocess((value) => value === "" ? undefined : value, z.coerce.number().finite().nonnegative().optional());
const positiveNumber = z.preprocess((value) => value === "" ? undefined : value, z.coerce.number().finite().positive().optional());

export const reminderInputSchema = z.object({
  title: z.string().trim().min(1, "Nama reminder wajib diisi.").max(120),
  category: z.string().trim().max(60),
  notes: z.string().trim().max(2000),
  schedule_type: z.enum(["time", "usage", "distance"]),
  last_completed_at: z.string(),
  interval_value: positiveInteger,
  interval_unit: z.enum(["day", "week", "month", "year"]),
  usage_target: positiveInteger,
  last_odometer_km: nonNegativeNumber,
  distance_interval_km: positiveNumber,
}).superRefine((value, context) => {
  if (value.schedule_type === "time") {
    if (!value.last_completed_at) context.addIssue({ code: "custom", path: ["last_completed_at"], message: "Isi tanggal terakhir dilakukan." });
    if (!value.interval_value) context.addIssue({ code: "custom", path: ["interval_value"], message: "Isi interval yang valid." });
    if (value.last_completed_at && value.interval_value) {
      try { addInterval(value.last_completed_at, value.interval_value, value.interval_unit as IntervalUnit); }
      catch { context.addIssue({ code: "custom", path: ["last_completed_at"], message: "Tanggal tidak valid." }); }
    }
  }
  if (value.schedule_type === "usage" && !value.usage_target) context.addIssue({ code: "custom", path: ["usage_target"], message: "Isi target pemakaian." });
  if (value.schedule_type === "distance") {
    if (value.last_odometer_km === undefined) context.addIssue({ code: "custom", path: ["last_odometer_km"], message: "Isi odometer terakhir." });
    if (!value.distance_interval_km) context.addIssue({ code: "custom", path: ["distance_interval_km"], message: "Isi interval jarak." });
  }
});

export type ReminderInput = z.infer<typeof reminderInputSchema>;

export type ReminderInsert = {
  user_id: string;
  title: string;
  category: string | null;
  notes: string | null;
  schedule_type: ScheduleType;
  last_completed_at?: string;
  interval_value?: number;
  interval_unit?: IntervalUnit;
  next_due_at?: string;
  usage_target?: number;
  usage_count?: number;
  last_odometer_km?: number;
  current_odometer_km?: number;
  distance_interval_km?: number;
};

export function toReminderInsert(input: ReminderInput, userId: string): ReminderInsert {
  const common = { user_id: userId, title: input.title, category: input.category || null, notes: input.notes || null, schedule_type: input.schedule_type };
  if (input.schedule_type === "time") {
    return { ...common, last_completed_at: input.last_completed_at, interval_value: input.interval_value!, interval_unit: input.interval_unit, next_due_at: addInterval(input.last_completed_at, input.interval_value!, input.interval_unit) };
  }
  if (input.schedule_type === "usage") return { ...common, usage_target: input.usage_target!, usage_count: 0 };
  return { ...common, last_odometer_km: input.last_odometer_km!, current_odometer_km: input.last_odometer_km!, distance_interval_km: input.distance_interval_km! };
}
