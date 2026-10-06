"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { createClient } from "@/lib/supabase/client";
import { reminderInputSchema, toReminderInsert } from "@/lib/reminder-input";
import { addInterval, type IntervalUnit, type ScheduleType } from "@/lib/reminder-model";

type FormValues = {
  title: string;
  category: string;
  notes: string;
  schedule_type: ScheduleType;
  last_completed_at: string;
  interval_value: string;
  interval_unit: IntervalUnit;
  usage_target: string;
  last_odometer_km: string;
  distance_interval_km: string;
};

const initial: FormValues = {
  title: "", category: "", notes: "", schedule_type: "time", last_completed_at: "", interval_value: "3", interval_unit: "month", usage_target: "6", last_odometer_km: "", distance_interval_km: "1000",
};

export function ReminderForm() {
  const router = useRouter();
  const [values, setValues] = useState<FormValues>(initial);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState("");
  const [busy, setBusy] = useState(false);

  function set<K extends keyof FormValues>(key: K, value: FormValues[K]) {
    setValues((current) => ({ ...current, [key]: value }));
    setErrors((current) => ({ ...current, [key]: "" }));
  }

  let preview = "Isi jadwal untuk melihat perkiraan berikutnya.";
  if (values.schedule_type === "time" && values.last_completed_at && Number(values.interval_value) > 0) {
    try {
      const due = addInterval(values.last_completed_at, Number(values.interval_value), values.interval_unit);
      preview = `Jatuh tempo berikutnya ${new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" }).format(new Date(`${due}T00:00:00Z`))}`;
    } catch { /* Inline validation handles invalid dates. */ }
  } else if (values.schedule_type === "usage") {
    preview = `Ingatkan setelah ${values.usage_target || "—"} pemakaian.`;
  } else if (values.schedule_type === "distance") {
    preview = `Ingatkan setelah ${values.distance_interval_km || "—"} km dari odometer terakhir.`;
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError("");
    const result = reminderInputSchema.safeParse(values);
    if (!result.success) {
      const next: Record<string, string> = {};
      for (const issue of result.error.issues) next[String(issue.path[0])] ??= issue.message;
      setErrors(next);
      return;
    }

    setBusy(true);
    const supabase = createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      setFormError("Sesi berakhir. Masuk kembali untuk menyimpan reminder.");
      setBusy(false);
      return;
    }

    const { count } = await supabase.from("reminders").select("id", { count: "exact", head: true }).eq("user_id", user.id);
    const { error } = await supabase.from("reminders").insert({ ...toReminderInsert(result.data, user.id), notification_enabled: true });
    if (error) {
      setFormError(error.code === "PGRST205" ? "Tabel Rootin belum tersedia di Supabase." : "Reminder belum tersimpan. Periksa koneksi dan coba lagi.");
      setBusy(false);
      return;
    }

    router.replace(count === 0 ? "/semua?notifications=offer" : "/semua");
    router.refresh();
  }

  return (
    <form className="reminder-form" onSubmit={submit} noValidate>
      <div className="form-section">
        <h2>Aktivitas</h2>
        <div className="field"><label htmlFor="title">Nama reminder <span aria-hidden="true">*</span></label><input id="title" value={values.title} onChange={(event) => set("title", event.target.value)} placeholder="Contoh: Ganti sikat gigi" maxLength={120} aria-invalid={Boolean(errors.title)} aria-describedby={errors.title ? "title-error" : undefined} required />{errors.title && <p className="field-error" id="title-error">{errors.title}</p>}</div>
        <div className="field"><label htmlFor="category">Kategori <span className="optional">opsional</span></label><input id="category" value={values.category} onChange={(event) => set("category", event.target.value)} placeholder="Perawatan, rumah, kendaraan…" maxLength={60} /></div>
        <div className="field"><label htmlFor="notes">Catatan <span className="optional">opsional</span></label><textarea id="notes" value={values.notes} onChange={(event) => set("notes", event.target.value)} rows={3} maxLength={2000} placeholder="Detail yang ingin diingat" /></div>
      </div>

      <div className="form-section">
        <h2>Aturan pengulangan</h2>
        <div className="field"><label htmlFor="schedule-type">Hitung berdasarkan</label><select id="schedule-type" value={values.schedule_type} onChange={(event) => set("schedule_type", event.target.value as ScheduleType)}><option value="time">Waktu</option><option value="usage">Jumlah pemakaian</option><option value="distance">Jarak tempuh</option></select></div>

        {values.schedule_type === "time" && <>
          <div className="field"><label htmlFor="last-completed">Terakhir dilakukan</label><input id="last-completed" type="date" value={values.last_completed_at} onChange={(event) => set("last_completed_at", event.target.value)} aria-invalid={Boolean(errors.last_completed_at)} aria-describedby={errors.last_completed_at ? "date-error" : undefined} />{errors.last_completed_at && <p className="field-error" id="date-error">{errors.last_completed_at}</p>}</div>
          <div className="field"><label htmlFor="interval-value">Ulangi setiap</label><div className="field-pair"><input id="interval-value" type="number" min="1" step="1" inputMode="numeric" value={values.interval_value} onChange={(event) => set("interval_value", event.target.value)} aria-invalid={Boolean(errors.interval_value)} /><select aria-label="Satuan interval" value={values.interval_unit} onChange={(event) => set("interval_unit", event.target.value as IntervalUnit)}><option value="day">hari</option><option value="week">minggu</option><option value="month">bulan</option><option value="year">tahun</option></select></div>{errors.interval_value && <p className="field-error">{errors.interval_value}</p>}</div>
        </>}

        {values.schedule_type === "usage" && <div className="field"><label htmlFor="usage-target">Target pemakaian</label><input id="usage-target" type="number" min="1" step="1" inputMode="numeric" value={values.usage_target} onChange={(event) => set("usage_target", event.target.value)} aria-invalid={Boolean(errors.usage_target)} />{errors.usage_target && <p className="field-error">{errors.usage_target}</p>}</div>}

        {values.schedule_type === "distance" && <>
          <div className="field"><label htmlFor="odometer">Odometer sekarang (km)</label><input id="odometer" type="number" min="0" step="0.1" inputMode="decimal" value={values.last_odometer_km} onChange={(event) => set("last_odometer_km", event.target.value)} aria-invalid={Boolean(errors.last_odometer_km)} />{errors.last_odometer_km && <p className="field-error">{errors.last_odometer_km}</p>}</div>
          <div className="field"><label htmlFor="distance-interval">Ulangi setiap (km)</label><input id="distance-interval" type="number" min="0.1" step="0.1" inputMode="decimal" value={values.distance_interval_km} onChange={(event) => set("distance_interval_km", event.target.value)} aria-invalid={Boolean(errors.distance_interval_km)} />{errors.distance_interval_km && <p className="field-error">{errors.distance_interval_km}</p>}</div>
        </>}
      </div>

      <div className="schedule-preview" aria-live="polite"><span>PRATINJAU JADWAL</span><p>{preview}</p></div>
      {formError && <p className="form-message" role="alert">{formError}</p>}
      <button className="primary-button" type="submit" disabled={busy}>{busy ? "Menyimpan…" : "Simpan reminder"}</button>
    </form>
  );
}
