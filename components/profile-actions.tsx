"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { AlertDialog, Button, Card, Input, Label, ListBox, Select, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import type { ProfileRow } from "@/lib/profile-model";
import { dispatchDueProfileReminders } from "@/lib/profile-push-client";
import { todayISO, type ReminderRow } from "@/lib/reminder-model";

export function ProfileActions({ profile, availableReminders, pushReady }: { profile: ProfileRow; availableReminders: ReminderRow[]; pushReady: boolean }) {
  const router = useRouter();
  const [today, setToday] = useState("");
  const [odometer, setOdometer] = useState(String(profile.odometer_km ?? ""));
  const [selectedReminder, setSelectedReminder] = useState("");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [confirmCorrection, setConfirmCorrection] = useState(false);
  const [confirmArchive, setConfirmArchive] = useState(false);

  useEffect(() => { setToday(todayISO(Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Makassar")); }, []);
  useEffect(() => { setOdometer(String(profile.odometer_km ?? "")); }, [profile.odometer_km]);

  async function saveOdometer(confirmed: boolean) {
    if (busy || !today) return;
    const reading = Number(odometer);
    if (odometer.trim() === "" || !Number.isFinite(reading) || reading < 0 || !/^\d+(?:\.\d)?$/.test(odometer)) {
      setMessage("Isi odometer dalam km, maksimal satu angka desimal."); return;
    }
    setBusy(true); setMessage("");
    try {
      const { error } = await createClient().rpc("update_profile_odometer", {
        p_profile_id: profile.id, p_odometer_km: reading,
        p_confirm_correction: confirmed, p_recorded_on: today,
      });
      if (error) throw error;
      const pushOk = !pushReady || await dispatchDueProfileReminders(profile.id, "distance");
      setConfirmCorrection(false);
      setMessage(pushOk ? confirmed ? "Koreksi odometer tersimpan dalam riwayat." : "Odometer dan reminder kendaraan diperbarui." : "Odometer tersimpan, tetapi notifikasi belum terkirim.");
      router.refresh();
    } catch { setMessage("Odometer belum tersimpan. Coba lagi."); }
    finally { setBusy(false); }
  }

  async function logWear(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy || !today) return;
    setBusy(true); setMessage("");
    try {
      const { error } = await createClient().rpc("log_profile_wear", { p_profile_id: profile.id, p_worn_on: today });
      if (error) throw error;
      const pushOk = !pushReady || await dispatchDueProfileReminders(profile.id, "usage");
      setMessage(pushOk ? "Pemakaian tercatat. Progres reminder terkait diperbarui." : "Pemakaian tercatat, tetapi notifikasi belum terkirim.");
      router.refresh();
    } catch { setMessage("Pemakaian belum tercatat. Coba lagi."); }
    finally { setBusy(false); }
  }

  async function linkReminder(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy || !selectedReminder) return;
    setBusy(true); setMessage("");
    try {
      const { error } = await createClient().rpc("set_reminder_profile", { p_reminder_id: selectedReminder, p_profile_id: profile.id });
      if (error) throw error;
      setSelectedReminder("");
      setMessage("Reminder terhubung ke profil.");
      router.refresh();
    } catch { setMessage("Reminder belum terhubung. Coba lagi."); }
    finally { setBusy(false); }
  }

  async function archiveProfile() {
    if (busy) return;
    setBusy(true); setMessage("");
    try {
      const { data, error } = await createClient().from("item_profiles")
        .update({ archived_at: new Date().toISOString() }).eq("id", profile.id).select("id").maybeSingle();
      if (error || !data) throw error ?? new Error("Profile not found");
      setConfirmArchive(false);
      router.refresh();
    } catch { setMessage("Profil belum diarsipkan. Coba lagi."); }
    finally { setBusy(false); }
  }

  return <>
    {profile.category === "vehicle" && <Card className="profile-action-card" variant="default">
      <Card.Header><Card.Title>Perbarui odometer</Card.Title><Card.Description>Pembacaan ini dipakai semua reminder jarak pada kendaraan ini.</Card.Description></Card.Header>
      <Card.Content><form className="profile-inline-form" onSubmit={(event) => {
        event.preventDefault();
        if (Number(odometer) < (profile.odometer_km ?? 0)) setConfirmCorrection(true);
        else void saveOdometer(false);
      }}>
        <TextField className="field" name="odometer" type="number" value={odometer} onChange={setOdometer} isRequired><Label>Odometer terbaru (km)</Label><Input min={0} step={0.1} inputMode="decimal" /></TextField>
        <Button type="submit" className="primary-button" isDisabled={busy || !today}>Simpan pembacaan</Button>
      </form></Card.Content>
    </Card>}
    {profile.category === "clothing" && <Card className="profile-action-card" variant="default">
      <Card.Header><Card.Title>Catat pemakaian</Card.Title><Card.Description>Satu catatan akan memperbarui tiap reminder pemakaian sesuai siklusnya.</Card.Description></Card.Header>
      <Card.Content><form className="profile-inline-form" onSubmit={logWear}>
        <TextField className="field" name="worn_on" type="date" value={today} onChange={setToday} isRequired><Label>Tanggal dipakai</Label><Input /></TextField>
        <Button type="submit" className="primary-button" isDisabled={busy || !today}>+1 pemakaian</Button>
      </form></Card.Content>
    </Card>}
    {!profile.archived_at && availableReminders.length > 0 && <Card className="profile-action-card" variant="default">
      <Card.Header><Card.Title>Hubungkan reminder</Card.Title><Card.Description>Reminder lama tetap dapat dipakai tanpa profil.</Card.Description></Card.Header>
      <Card.Content><form className="profile-inline-form" onSubmit={linkReminder}>
        <Select className="field" value={selectedReminder} onChange={(value) => setSelectedReminder(value ? String(value) : "")}><Label>Reminder yang sudah ada</Label><Select.Trigger><Select.Value /><Select.Indicator /></Select.Trigger><Select.Popover><ListBox>{availableReminders.map((reminder) => <ListBox.Item key={reminder.id} id={reminder.id} textValue={reminder.title}>{reminder.title}<ListBox.ItemIndicator /></ListBox.Item>)}</ListBox></Select.Popover></Select>
        <Button type="submit" variant="secondary" className="secondary-button" isDisabled={busy || !selectedReminder}>Hubungkan</Button>
      </form></Card.Content>
    </Card>}
    {!profile.archived_at && <div className="profile-archive-action"><Button variant="ghost" onPress={() => { setMessage(""); setConfirmArchive(true); }}>Arsipkan profil</Button></div>}
    {message && <p className="settings-message" role="status">{message}</p>}
    <AlertDialog.Backdrop variant="opaque" isOpen={confirmCorrection} onOpenChange={(open) => { if (!busy) setConfirmCorrection(open); }}>
      <AlertDialog.Container size="sm"><AlertDialog.Dialog><AlertDialog.Header><AlertDialog.Icon status="warning" /><AlertDialog.Heading>Koreksi odometer?</AlertDialog.Heading></AlertDialog.Header><AlertDialog.Body><p>Pembacaan baru lebih rendah dari {new Intl.NumberFormat("id-ID").format(profile.odometer_km ?? 0)} km. Periksa angkanya. Jika benar, koreksi akan dicatat di riwayat dan diterapkan ke semua reminder jarak.</p>{message && <p role="alert">{message}</p>}</AlertDialog.Body><AlertDialog.Footer><Button slot="close" variant="tertiary" isDisabled={busy}>Batal</Button><Button variant="primary" onPress={() => void saveOdometer(true)} isDisabled={busy}>Simpan koreksi</Button></AlertDialog.Footer></AlertDialog.Dialog></AlertDialog.Container>
    </AlertDialog.Backdrop>
    <AlertDialog.Backdrop variant="opaque" isOpen={confirmArchive} onOpenChange={(open) => { if (!busy) setConfirmArchive(open); }}>
      <AlertDialog.Container size="sm"><AlertDialog.Dialog><AlertDialog.Header><AlertDialog.Icon status="warning" /><AlertDialog.Heading>Arsipkan profil?</AlertDialog.Heading></AlertDialog.Header><AlertDialog.Body><p>Profil {profile.name} akan dipindahkan ke bagian arsip. Reminder dan semua riwayatnya tetap tersimpan dan dapat dibuka.</p>{message && <p role="alert">{message}</p>}</AlertDialog.Body><AlertDialog.Footer><Button slot="close" variant="tertiary" isDisabled={busy}>Batal</Button><Button variant="primary" onPress={() => void archiveProfile()} isDisabled={busy}>Arsipkan</Button></AlertDialog.Footer></AlertDialog.Dialog></AlertDialog.Container>
    </AlertDialog.Backdrop>
  </>;
}
