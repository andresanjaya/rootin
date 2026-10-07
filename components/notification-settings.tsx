"use client";

import { useEffect, useRef, useState } from "react";
import { Button, Card, Chip, Input, Label, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import { isValidTimeZone } from "@/lib/push-schedule";

type Status = "checking" | "unavailable" | "install" | "unsupported" | "denied" | "ready" | "active" | "problem";

function isIos() { return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1); }
function isInstalled() { return window.matchMedia("(display-mode: standalone)").matches || Boolean((navigator as Navigator & { standalone?: boolean }).standalone); }

export function NotificationSettings({ userId, hasReminders, serverReady, publicKey }: { userId: string; hasReminders: boolean; serverReady: boolean; publicKey: string }) {
  const [status, setStatus] = useState<Status>("checking");
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [timeZone, setTimeZone] = useState("Asia/Makassar");
  const [endpoint, setEndpoint] = useState("");
  const registrationRef = useRef<ServiceWorkerRegistration | null>(null);
  const subscriptionRef = useRef<PushSubscription | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function inspect() {
      if (!serverReady) { setStatus("unavailable"); return; }
      if (!("serviceWorker" in navigator) || !("PushManager" in window) || !("Notification" in window)) { setStatus("unsupported"); return; }
      if (isIos() && !isInstalled()) { setStatus("install"); return; }
      try {
        const registration = await navigator.serviceWorker.register("/sw.js");
        registrationRef.current = registration;
        const subscription = await registration.pushManager.getSubscription();
        subscriptionRef.current = subscription;
        if (cancelled) return;
        setTimeZone(Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Makassar");
        if (!subscription) { setStatus(Notification.permission === "denied" ? "denied" : "ready"); return; }
        setEndpoint(subscription.endpoint);
        const { data, error } = await createClient().from("push_subscriptions")
          .select("disabled_at,time_zone").eq("user_id", userId).eq("endpoint", subscription.endpoint).maybeSingle();
        if (cancelled) return;
        if (error) { setStatus("problem"); return; }
        if (data?.disabled_at) {
          await subscription.unsubscribe();
          subscriptionRef.current = null;
          setEndpoint("");
          setStatus(Notification.permission === "denied" ? "denied" : "ready");
          return;
        }
        if (data?.time_zone) setTimeZone(data.time_zone);
        setStatus(Notification.permission === "denied" ? "denied" : data && Notification.permission === "granted" ? "active" : "problem");
      } catch { if (!cancelled) setStatus("problem"); }
    }
    void inspect();
    return () => { cancelled = true; };
  }, [serverReady, userId]);

  async function activate() {
    if (busy || !serverReady || !hasReminders || !isValidTimeZone(timeZone)) return;
    setBusy(true); setMessage("");
    try {
      const registration = registrationRef.current;
      if (!registration) throw new Error("Service worker belum siap.");
      const base64 = publicKey.replace(/-/g, "+").replace(/_/g, "/");
      const key = Uint8Array.from(atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, "=")), (character) => character.charCodeAt(0));
      // subscribe() starts directly in this click handler so iOS may show its permission prompt.
      const subscriptionPromise = subscriptionRef.current
        ? Promise.resolve(subscriptionRef.current)
        : registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: key });
      const subscription = await subscriptionPromise;
      const json = subscription.toJSON();
      if (!json.keys?.p256dh || !json.keys.auth) throw new Error("Kunci subscription tidak tersedia.");
      const zone = Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Makassar";
      const supabase = createClient();
      const { error } = await supabase.from("push_subscriptions").upsert({
        user_id: userId, endpoint: subscription.endpoint, p256dh: json.keys.p256dh,
        auth: json.keys.auth, time_zone: zone, disabled_at: null,
      }, { onConflict: "endpoint" });
      if (error) throw error;
      const { error: reminderError } = await supabase.from("reminders").update({ notification_enabled: true })
        .eq("user_id", userId).is("archived_at", null);
      if (reminderError) throw reminderError;
      subscriptionRef.current = subscription;
      setEndpoint(subscription.endpoint); setTimeZone(zone); setStatus("active");
      setMessage("Notifikasi aktif untuk reminder di perangkat ini.");
    } catch {
      setStatus(Notification.permission === "denied" ? "denied" : "problem"); setMessage("Belum berhasil mengaktifkan notifikasi. Coba periksa ulang.");
    } finally { setBusy(false); }
  }

  async function disable() {
    if (busy) return;
    setBusy(true); setMessage("");
    try {
      const subscription = subscriptionRef.current;
      if (subscription) {
        const { error } = await createClient().from("push_subscriptions").update({ disabled_at: new Date().toISOString() })
          .eq("user_id", userId).eq("endpoint", subscription.endpoint);
        if (error) throw error;
        await subscription.unsubscribe();
      }
      subscriptionRef.current = null;
      setEndpoint(""); setStatus("ready"); setMessage("Notifikasi dimatikan di perangkat ini.");
    } catch { setMessage("Gagal mematikan notifikasi. Coba lagi."); }
    finally { setBusy(false); }
  }

  async function saveTimeZone() {
    if (!isValidTimeZone(timeZone)) { setMessage("Gunakan nama zona waktu valid, misalnya Asia/Makassar."); return; }
    setBusy(true); setMessage("");
    const { error } = await createClient().from("push_subscriptions").update({ time_zone: timeZone.trim() })
      .eq("user_id", userId).eq("endpoint", endpoint);
    setMessage(error ? "Zona waktu belum tersimpan." : "Zona waktu tersimpan.");
    setBusy(false);
  }

  async function sendTest() {
    setBusy(true); setMessage("");
    try {
      const response = await fetch("/api/push/test", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ endpoint }) });
      if (!response.ok) throw new Error();
      setMessage("Notifikasi uji dikirim. Periksa perangkat ini.");
    } catch { setStatus("problem"); setMessage("Notifikasi uji gagal. Periksa ulang subscription."); }
    finally { setBusy(false); }
  }

  const descriptions: Record<Status, string> = {
    checking: "Memeriksa dukungan notifikasi…",
    unavailable: "Notifikasi belum tersedia. Reminder tetap dapat dilihat di aplikasi.",
    install: "Di iPhone, tambahkan Rootin ke Home Screen, lalu buka dari ikonnya untuk mengaktifkan notifikasi.",
    unsupported: "Perangkat atau browser ini belum mendukung Web Push. Reminder tetap tampil di aplikasi.",
    denied: "Izin notifikasi ditolak. Ubah izin Rootin melalui pengaturan perangkat atau browser.",
    ready: "Izin belum diberikan. Aktifkan setelah kamu siap menerima pengingat.",
    active: "Notifikasi aktif di perangkat ini. Reminder waktu diperiksa sekali sehari.",
    problem: "Subscription perlu diperiksa ulang agar pengingat dapat diterima.",
  };

  return <Card className="settings-panel" variant="default" aria-labelledby="notification-heading">
    <p className="section-kicker">PERANGKAT INI</p>
    <Card.Header><Card.Title id="notification-heading">Notifikasi</Card.Title></Card.Header>
    <p className="settings-status"><Chip size="sm" color={status === "active" ? "success" : status === "problem" ? "warning" : "default"} variant="soft">{status === "active" ? "Aktif" : status === "checking" ? "Memeriksa" : status === "problem" ? "Bermasalah" : "Belum aktif"}</Chip> {descriptions[status]}</p>
    {!hasReminders && <p className="settings-help">Buat reminder pertama sebelum mengaktifkan notifikasi.</p>}
    {status === "install" && <p className="settings-help">Di Safari: ketuk Bagikan → Tambah ke Layar Utama. Buka Rootin dari ikon yang muncul.</p>}
    {(status === "ready" || status === "problem") && <Button type="button" className="primary-button settings-button" onPress={activate} isDisabled={busy || !hasReminders}>{busy ? "Memproses…" : status === "problem" ? "Sambungkan ulang" : "Aktifkan notifikasi"}</Button>}
    {(status === "denied" || status === "problem") && endpoint && <Button type="button" variant="secondary" className="secondary-button settings-button" onPress={disable} isDisabled={busy}>Matikan subscription</Button>}
    {status === "active" && <>
      <div className="settings-actions"><Button type="button" className="primary-button settings-button" onPress={sendTest} isDisabled={busy}>{busy ? "Memproses…" : "Kirim notifikasi uji"}</Button><Button type="button" variant="secondary" className="secondary-button" onPress={disable} isDisabled={busy}>Matikan</Button></div>
      <div className="settings-field"><TextField className="field" name="time_zone" value={timeZone} onChange={setTimeZone}><Label>Zona waktu perangkat</Label><Input placeholder="Asia/Makassar" /></TextField><p className="settings-help">Tanggal jatuh tempo mengikuti zona waktu ini. Pengiriman harian dapat bergeser menurut lokasi.</p><Button type="button" variant="secondary" className="secondary-button" onPress={saveTimeZone} isDisabled={busy}>Simpan zona waktu</Button></div>
    </>}
    {message && <p className="settings-message" role="status">{message}</p>}
  </Card>;
}
