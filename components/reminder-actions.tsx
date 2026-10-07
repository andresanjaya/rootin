"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Button, Input, Label, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import { todayISO, type ReminderRow } from "@/lib/reminder-model";

export function ReminderActions({ reminder, pushReady }: { reminder: ReminderRow; pushReady: boolean }) {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [odometer, setOdometer] = useState(String(reminder.current_odometer_km ?? ""));
  const [completedOn, setCompletedOn] = useState("");
  const [notificationEnabled, setNotificationEnabled] = useState(reminder.notification_enabled);

  useEffect(() => {
    setOdometer(String(reminder.current_odometer_km ?? ""));
    setNotificationEnabled(reminder.notification_enabled);
  }, [reminder.current_odometer_km, reminder.notification_enabled]);

  useEffect(() => { setCompletedOn(todayISO(Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Makassar")); }, []);

  async function progress(event?: FormEvent<HTMLFormElement>) {
    event?.preventDefault();
    if (busy) return;
    if (reminder.schedule_type === "distance" && (!Number.isFinite(Number(odometer)) || Number(odometer) < (reminder.current_odometer_km ?? 0))) {
      setMessage("Odometer tidak boleh lebih kecil dari catatan terakhir."); return;
    }
    setBusy(true); setMessage("");
    const supabase = createClient();
    const { data, error } = await supabase.rpc("record_reminder_progress", {
      p_reminder_id: reminder.id,
      p_odometer_km: reminder.schedule_type === "distance" ? Number(odometer) : null,
    });
    if (error) { setMessage("Progres belum tersimpan. Coba lagi."); setBusy(false); return; }
    const updated = data as ReminderRow;
    let pushFailed = false;
    if (pushReady && updated.notification_enabled) {
      const due = updated.schedule_type === "usage" ? (updated.usage_target !== null && updated.usage_count >= updated.usage_target)
        : (updated.last_odometer_km !== null && updated.distance_interval_km !== null && updated.current_odometer_km !== null && updated.current_odometer_km >= updated.last_odometer_km + updated.distance_interval_km);
      if (due) {
        const response = await fetch("/api/push/dispatch", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ reminderId: reminder.id }) });
        pushFailed = !response.ok;
      }
    }
    setMessage(pushFailed ? "Progres tersimpan, tetapi notifikasi belum terkirim." : "Progres tersimpan.");
    setBusy(false); router.refresh();
  }

  async function complete(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy || !completedOn) return;
    setBusy(true); setMessage("");
    const { error } = await createClient().rpc("complete_reminder", { p_reminder_id: reminder.id, p_completed_on: completedOn });
    setMessage(error ? "Penyelesaian belum tersimpan. Coba lagi." : "Reminder selesai. Siklus berikutnya dimulai dari tanggal ini.");
    setBusy(false); if (!error) router.refresh();
  }

  async function toggleNotification() {
    if (busy) return;
    setBusy(true); setMessage("");
    const next = !notificationEnabled;
    const { error } = await createClient().from("reminders").update({ notification_enabled: next }).eq("id", reminder.id);
    if (error) setMessage("Pengaturan reminder belum tersimpan.");
    else { setNotificationEnabled(next); setMessage(next ? "Pengingat diaktifkan untuk reminder ini jika perangkat tersambung." : "Pengingat dimatikan untuk reminder ini."); router.refresh(); }
    setBusy(false);
  }

  return <section className="detail-actions" aria-labelledby="actions-heading">
    <p className="section-kicker">AKSI</p><h2 id="actions-heading">Perbarui reminder</h2>
    {reminder.schedule_type === "usage" && (reminder.usage_target !== null && reminder.usage_count >= reminder.usage_target
      ? <p className="settings-help">Target sudah tercapai. Tandai selesai untuk memulai siklus baru.</p>
      : <Button type="button" className="primary-button" onPress={() => void progress()} isDisabled={busy}>+1 pemakaian</Button>)}
    {reminder.schedule_type === "distance" && <form className="detail-action-form" onSubmit={progress}><TextField className="field" name="current_odometer" type="number" value={odometer} onChange={setOdometer} isRequired><Label>Odometer sekarang (km)</Label><Input min={reminder.current_odometer_km ?? 0} step={0.1} /></TextField><Button className="primary-button" type="submit" isDisabled={busy}>Simpan odometer</Button></form>}
    <form className="detail-action-form" onSubmit={complete}><TextField className="field" name="completed_on" type="date" value={completedOn} onChange={setCompletedOn} isRequired><Label>Tanggal selesai</Label><Input /></TextField><Button variant="secondary" className="secondary-button" type="submit" isDisabled={busy}>Tandai selesai</Button></form>
    <div className="detail-notification"><p><strong>Notifikasi reminder</strong><span>{notificationEnabled ? "Aktif jika perangkat tersambung" : "Mati"}</span></p><Button type="button" variant="secondary" className="secondary-button" onPress={toggleNotification} isDisabled={busy}>{notificationEnabled ? "Matikan" : "Aktifkan"}</Button></div>
    {message && <p className="settings-message" role="status">{message}</p>}
  </section>;
}
