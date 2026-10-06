import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { ReminderActions } from "@/components/reminder-actions";
import { requireUser } from "@/lib/auth";
import { pushIsConfigured } from "@/lib/push-server";
import { todayISO, toReminderView, type ReminderRow } from "@/lib/reminder-model";

export const metadata: Metadata = { title: "Detail reminder" };
export const dynamic = "force-dynamic";

export default async function ReminderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();
  const { supabase, userId } = await requireUser();
  const { data, error } = await supabase.from("reminders").select("*").eq("id", id).eq("user_id", userId).maybeSingle();
  if (!data && !error) notFound();
  const reminder = data as ReminderRow | null;
  const view = reminder ? toReminderView(reminder, todayISO()) : null;

  return (
    <AppShell active="all">
      {error || !reminder || !view ? <DataError /> : <>
        <Link className="text-link back-link" href="/semua">← Semua reminder</Link>
        <div className="page-heading detail-heading"><div><p className="eyebrow">DETAIL REMINDER</p><h1>{reminder.title}<span className="heading-period">.</span></h1><p className="page-intro">{reminder.category ?? "Tanpa kategori"}</p></div></div>
        <div className="detail-status"><span className={`row-marker marker-${view.status}`} aria-hidden="true" /><strong>{view.statusText}</strong></div>
        <dl className="detail-list">
          <div><dt>Aturan</dt><dd>{view.description}</dd></div>
          {reminder.last_completed_at && <div><dt>Terakhir dilakukan</dt><dd>{reminder.last_completed_at}</dd></div>}
          {view.dueDate && <div><dt>Jatuh tempo</dt><dd>{view.dueDate}</dd></div>}
          {reminder.notes && <div><dt>Catatan</dt><dd>{reminder.notes}</dd></div>}
        </dl>
        {reminder.notification_cycle_id && <ReminderActions reminder={reminder} pushReady={pushIsConfigured()} />}
      </>}
    </AppShell>
  );
}
