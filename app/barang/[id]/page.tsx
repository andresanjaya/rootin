import type { Metadata } from "next";
import Link from "next/link";
import { Card, Chip } from "@heroui/react";
import { notFound } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { ProfileActions } from "@/components/profile-actions";
import { ReminderList } from "@/components/reminder-list";
import { requireUser } from "@/lib/auth";
import { getProfileEvents } from "@/lib/profile-data";
import { activeProfileReminders, distanceIsNearDue, distanceRemainingKm, profileCategoryLabels, profileReminderViews, type ProfileRow } from "@/lib/profile-model";
import { getReminders } from "@/lib/reminder-data";
import { pushIsConfigured } from "@/lib/push-server";
import { todayISO } from "@/lib/reminder-model";

export const metadata: Metadata = { title: "Detail profil barang" };
export const dynamic = "force-dynamic";

const reminderEventLabels: Record<string, string> = {
  completed: "Ditandai selesai", snoozed: "Ditunda", usage_incremented: "Pemakaian diperbarui",
  odometer_updated: "Odometer diperbarui", schedule_changed: "Jadwal diubah",
};

export default async function ProfileDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();
  const { supabase, userId } = await requireUser();
  const { data, error: profileError } = await supabase.from("item_profiles").select("*").eq("id", id).eq("user_id", userId).maybeSingle();
  if (!data && !profileError) notFound();
  const profile = data as ProfileRow | null;
  if (profileError || !profile) return <AppShell active="items"><DataError /></AppShell>;

  const [reminderResult, profileEventResult] = await Promise.all([
    getReminders(supabase, userId, true), getProfileEvents(supabase, userId, id),
  ]);
  const allRelated = reminderResult.reminders.filter((reminder) => reminder.profile_id === id);
  const reminderIds = allRelated.map((reminder) => reminder.id);
  const historyResult = reminderIds.length
    ? await supabase.from("activity_history").select("id,reminder_id,event_type,occurred_at,value_after")
      .eq("user_id", userId).in("reminder_id", reminderIds).order("occurred_at", { ascending: false }).limit(100)
    : { data: [], error: null };
  if (reminderResult.error || profileEventResult.error || historyResult.error) return <AppShell active="items"><DataError /></AppShell>;

  const active = activeProfileReminders(id, reminderResult.reminders);
  const views = profileReminderViews(id, reminderResult.reminders, todayISO());
  const available = reminderResult.reminders.filter((reminder) => !reminder.profile_id && !reminder.archived_at);
  const names = new Map(allRelated.map((reminder) => [reminder.id, reminder.title]));
  const history = [
    ...profileEventResult.events.map((event) => ({
      id: event.id, date: event.occurred_on, createdAt: event.created_at,
      title: event.event_type === "usage_logged" ? "Pemakaian dicatat" : event.event_type === "odometer_corrected" ? "Koreksi odometer" : "Odometer diperbarui",
      detail: event.event_type === "usage_logged" ? "Satu kali pemakaian" : `${new Intl.NumberFormat("id-ID").format(event.odometer_before_km ?? 0)} → ${new Intl.NumberFormat("id-ID").format(event.odometer_after_km ?? 0)} km`,
    })),
    ...(historyResult.data ?? []).filter((event) => event.value_after?.source !== "profile").map((event) => ({
      id: event.id, date: todayISO("Asia/Makassar", new Date(event.occurred_at)), createdAt: event.occurred_at,
      title: names.get(event.reminder_id) ?? "Reminder", detail: reminderEventLabels[event.event_type] ?? "Aktivitas reminder",
    })),
  ].sort((a, b) => b.date.localeCompare(a.date) || b.createdAt.localeCompare(a.createdAt)).slice(0, 100);

  return <AppShell active="items">
    <Link className="text-link back-link" href="/barang">← Profil barang</Link>
    <div className="page-heading profile-detail-heading"><div><p className="eyebrow">PROFIL BARANG</p><h1>{profile.name}<span className="heading-period">.</span></h1><p className="page-intro">{profileCategoryLabels[profile.category]}{profile.archived_at ? " · Diarsipkan" : ""}</p></div><Link className="text-link" href={`/barang/${id}/edit`}>Edit profil</Link></div>

    <Card className="profile-summary-card" variant="default">
      <Card.Header><Card.Title>Ringkasan</Card.Title>{profile.archived_at && <Chip size="sm" variant="tertiary">Diarsipkan</Chip>}</Card.Header>
      <Card.Content>
        <dl className="detail-list"><div><dt>Reminder aktif</dt><dd>{active.length}</dd></div>
          {profile.category === "vehicle" && <div><dt>Odometer terbaru</dt><dd>{new Intl.NumberFormat("id-ID").format(profile.odometer_km ?? 0)} km</dd></div>}
          {profile.notes && <div><dt>Catatan</dt><dd className="detail-notes">{profile.notes}</dd></div>}
        </dl>
      </Card.Content>
    </Card>

    <section className="content-section profile-section" aria-labelledby="profile-reminders-heading">
      <div className="section-heading"><div><p className="section-kicker">TERHUBUNG</p><h2 id="profile-reminders-heading">Reminder aktif</h2></div><Chip size="sm" variant="tertiary" className="section-count">{active.length}</Chip></div>
      {views.length ? <ReminderList reminders={views} /> : <p className="section-empty">Belum ada reminder aktif untuk barang ini.</p>}
      {!profile.archived_at && <Link className="text-link all-link" href={`/baru?profile=${id}`}>+ Buat reminder untuk {profile.name}</Link>}
    </section>

    {active.some((reminder) => reminder.schedule_type === "distance" || reminder.schedule_type === "usage") && <section className="content-section profile-section" aria-labelledby="profile-progress-heading">
      <div className="section-heading"><div><p className="section-kicker">PERKEMBANGAN</p><h2 id="profile-progress-heading">Progres</h2></div></div>
      <ul className="profile-progress-list">{active.filter((reminder) => reminder.schedule_type !== "time").map((reminder) => {
        const remaining = distanceRemainingKm(reminder);
        const progress = reminder.schedule_type === "usage"
          ? `${reminder.usage_count} dari ${reminder.usage_target} pemakaian`
          : remaining !== null && remaining <= 0 ? "Jatuh tempo"
            : `${new Intl.NumberFormat("id-ID").format(remaining ?? 0)} km lagi${distanceIsNearDue(reminder) ? " · Hampir jatuh tempo" : ""}`;
        return <li key={reminder.id}><Link href={`/reminder/${reminder.id}`}>{reminder.title}</Link><span>{progress}</span></li>;
      })}</ul>
    </section>}

    <section className="content-section profile-section" aria-labelledby="profile-actions-heading"><div className="section-heading"><div><p className="section-kicker">AKSI CEPAT</p><h2 id="profile-actions-heading">Perbarui barang</h2></div></div><ProfileActions profile={profile} availableReminders={available} pushReady={pushIsConfigured()} /></section>

    <section className="content-section profile-section" aria-labelledby="profile-history-heading"><div className="section-heading"><div><p className="section-kicker">AKTIVITAS</p><h2 id="profile-history-heading">Riwayat profil</h2></div></div>
      {history.length ? <ol className="profile-history-list">{history.map((event) => <li key={event.id}><div><strong>{event.title}</strong><span>{event.detail}</span></div><time dateTime={event.date}>{new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" }).format(new Date(`${event.date}T00:00:00Z`))}</time></li>)}</ol> : <p className="section-empty">Belum ada aktivitas untuk profil ini.</p>}
    </section>
  </AppShell>;
}
