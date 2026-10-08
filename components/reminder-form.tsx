"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { Button, Card, FieldError, Input, Label, ListBox, Select, TextArea, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import { reminderInputSchema, toReminderInsert } from "@/lib/reminder-input";
import { addInterval, type IntervalUnit, type ScheduleType } from "@/lib/reminder-model";
import { profileCategoryLabels, type ProfileRow } from "@/lib/profile-model";

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

export function ReminderForm({ profiles = [], initialProfileId }: { profiles?: ProfileRow[]; initialProfileId?: string }) {
  const router = useRouter();
  const initialProfile = profiles.find((profile) => profile.id === initialProfileId);
  const [profileId, setProfileId] = useState(initialProfile?.id ?? "");
  const [values, setValues] = useState<FormValues>(() => ({ ...initial, last_odometer_km: initialProfile?.category === "vehicle" ? String(initialProfile.odometer_km ?? "") : "" }));
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [formError, setFormError] = useState("");
  const [busy, setBusy] = useState(false);

  function set<K extends keyof FormValues>(key: K, value: FormValues[K]) {
    setValues((current) => ({ ...current, [key]: value }));
    setErrors((current) => ({ ...current, [key]: "" }));
  }

  const selectedProfile = profiles.find((profile) => profile.id === profileId);

  function changeProfile(nextId: string) {
    setProfileId(nextId);
    const nextProfile = profiles.find((profile) => profile.id === nextId);
    if (nextProfile?.category === "vehicle" && values.schedule_type === "distance" && !values.last_odometer_km) {
      set("last_odometer_km", String(nextProfile.odometer_km ?? ""));
    }
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
    const { error } = await supabase.from("reminders").insert({ ...toReminderInsert(result.data, user.id), ...(profileId ? { profile_id: profileId } : {}), notification_enabled: true });
    if (error) {
      setFormError(error.code === "PGRST205" ? "Tabel Rootin belum tersedia di Supabase." : "Reminder belum tersimpan. Periksa koneksi dan coba lagi.");
      setBusy(false);
      return;
    }

    router.replace(profileId ? `/barang/${profileId}` : count === 0 ? "/semua?notifications=offer" : "/semua");
    router.refresh();
  }

  return (
    <form className="reminder-form" onSubmit={submit} noValidate>
      <Card className="form-section" variant="default">
        <Card.Header><Card.Title>Aktivitas</Card.Title></Card.Header>
        <Card.Content>
          {profiles.length > 0 && <Select className="field" value={profileId || "none"} onChange={(value) => changeProfile(value && value !== "none" ? String(value) : "")}>
            <Label>Profil barang <span className="optional">opsional</span></Label>
            <Select.Trigger><Select.Value /><Select.Indicator /></Select.Trigger>
            <Select.Popover><ListBox>
              <ListBox.Item id="none" textValue="Tanpa profil">Tanpa profil<ListBox.ItemIndicator /></ListBox.Item>
              {profiles.map((profile) => <ListBox.Item key={profile.id} id={profile.id} textValue={profile.name}>{profile.name} · {profileCategoryLabels[profile.category]}<ListBox.ItemIndicator /></ListBox.Item>)}
            </ListBox></Select.Popover>
          </Select>}
          <TextField className="field" name="title" value={values.title} onChange={(value) => set("title", value)} isInvalid={Boolean(errors.title)} isRequired>
            <Label>Nama reminder</Label><Input placeholder="Contoh: Ganti sikat gigi" maxLength={120} />
            {errors.title && <FieldError>{errors.title}</FieldError>}
          </TextField>
          <TextField className="field" name="category" value={values.category} onChange={(value) => set("category", value)}>
            <Label>Kategori <span className="optional">opsional</span></Label><Input placeholder="Perawatan, rumah, kendaraan…" maxLength={60} />
          </TextField>
          <TextField className="field" name="notes" value={values.notes} onChange={(value) => set("notes", value)}>
            <Label>Catatan <span className="optional">opsional</span></Label><TextArea rows={3} maxLength={2000} placeholder="Detail yang ingin diingat" />
          </TextField>
        </Card.Content>
      </Card>

      <Card className="form-section" variant="default">
        <Card.Header><Card.Title>Aturan pengulangan</Card.Title></Card.Header>
        <Card.Content>
          <Select className="field" value={values.schedule_type} onChange={(value) => { if (value) { set("schedule_type", String(value) as ScheduleType); if (value === "distance" && selectedProfile?.category === "vehicle" && !values.last_odometer_km) set("last_odometer_km", String(selectedProfile.odometer_km ?? "")); } }}>
            <Label>Hitung berdasarkan</Label>
            <Select.Trigger><Select.Value /><Select.Indicator /></Select.Trigger>
            <Select.Popover><ListBox>
              <ListBox.Item id="time" textValue="Waktu">Waktu<ListBox.ItemIndicator /></ListBox.Item>
              <ListBox.Item id="usage" textValue="Jumlah pemakaian">Jumlah pemakaian<ListBox.ItemIndicator /></ListBox.Item>
              <ListBox.Item id="distance" textValue="Jarak tempuh">Jarak tempuh<ListBox.ItemIndicator /></ListBox.Item>
            </ListBox></Select.Popover>
          </Select>

          {values.schedule_type === "time" && <>
            <TextField className="field" name="last_completed_at" type="date" value={values.last_completed_at} onChange={(value) => set("last_completed_at", value)} isInvalid={Boolean(errors.last_completed_at)}>
              <Label>Terakhir dilakukan</Label><Input />
              {errors.last_completed_at && <FieldError>{errors.last_completed_at}</FieldError>}
            </TextField>
            <div className="field-pair">
              <TextField className="field" name="interval_value" type="number" value={values.interval_value} onChange={(value) => set("interval_value", value)} isInvalid={Boolean(errors.interval_value)}>
                <Label>Ulangi setiap</Label><Input min={1} step={1} inputMode="numeric" />
                {errors.interval_value && <FieldError>{errors.interval_value}</FieldError>}
              </TextField>
              <Select className="field" value={values.interval_unit} onChange={(value) => value && set("interval_unit", String(value) as IntervalUnit)}>
                <Label>Satuan interval</Label><Select.Trigger><Select.Value /><Select.Indicator /></Select.Trigger>
                <Select.Popover><ListBox>
                  <ListBox.Item id="day" textValue="hari">hari<ListBox.ItemIndicator /></ListBox.Item>
                  <ListBox.Item id="week" textValue="minggu">minggu<ListBox.ItemIndicator /></ListBox.Item>
                  <ListBox.Item id="month" textValue="bulan">bulan<ListBox.ItemIndicator /></ListBox.Item>
                  <ListBox.Item id="year" textValue="tahun">tahun<ListBox.ItemIndicator /></ListBox.Item>
                </ListBox></Select.Popover>
              </Select>
            </div>
          </>}

          {values.schedule_type === "usage" && <TextField className="field" name="usage_target" type="number" value={values.usage_target} onChange={(value) => set("usage_target", value)} isInvalid={Boolean(errors.usage_target)}>
            <Label>Target pemakaian</Label><Input min={1} step={1} inputMode="numeric" />
            {errors.usage_target && <FieldError>{errors.usage_target}</FieldError>}
          </TextField>}

          {values.schedule_type === "distance" && <>
            <TextField className="field" name="last_odometer_km" type="number" value={values.last_odometer_km} onChange={(value) => set("last_odometer_km", value)} isInvalid={Boolean(errors.last_odometer_km)}>
              <Label>{selectedProfile?.category === "vehicle" ? "Odometer dasar servis (km)" : "Odometer sekarang (km)"}</Label><Input min={0} step={0.1} inputMode="decimal" />
              {errors.last_odometer_km && <FieldError>{errors.last_odometer_km}</FieldError>}
            </TextField>
            {selectedProfile?.category === "vehicle" && <p className="settings-help">Pembacaan sekarang mengikuti profil {selectedProfile.name}: {new Intl.NumberFormat("id-ID").format(selectedProfile.odometer_km ?? 0)} km. Dasar servis reminder tetap terpisah.</p>}
            <TextField className="field" name="distance_interval_km" type="number" value={values.distance_interval_km} onChange={(value) => set("distance_interval_km", value)} isInvalid={Boolean(errors.distance_interval_km)}>
              <Label>Ulangi setiap (km)</Label><Input min={0.1} step={0.1} inputMode="decimal" />
              {errors.distance_interval_km && <FieldError>{errors.distance_interval_km}</FieldError>}
            </TextField>
          </>}
        </Card.Content>
      </Card>

      <Card className="schedule-preview" variant="secondary" aria-live="polite"><Card.Header><Card.Title>PRATINJAU JADWAL</Card.Title><Card.Description>{preview}</Card.Description></Card.Header></Card>
      {formError && <p className="form-message" role="alert">{formError}</p>}
      <Button className="primary-button" type="submit" isDisabled={busy}>{busy ? "Menyimpan…" : "Simpan reminder"}</Button>
    </form>
  );
}
