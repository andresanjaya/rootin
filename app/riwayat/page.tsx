import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { EmptyState } from "@/components/empty-state";
import { Icon } from "@/components/icons";
import { requireUser } from "@/lib/auth";
import { getHistory, getReminders } from "@/lib/reminder-data";

export const metadata: Metadata = { title: "Riwayat" };
export const dynamic = "force-dynamic";

const eventLabels = {
  completed: "Ditandai selesai",
  snoozed: "Ditunda",
  usage_incremented: "Pemakaian diperbarui",
  odometer_updated: "Odometer diperbarui",
  schedule_changed: "Jadwal diubah",
};

export default async function HistoryPage() {
  const { supabase, userId } = await requireUser();
  const [historyResult, reminderResult] = await Promise.all([getHistory(supabase, userId), getReminders(supabase, userId, true)]);
  const names = new Map(reminderResult.reminders.map((reminder) => [reminder.id, reminder.title]));
  const events = historyResult.history;

  return (
    <AppShell active="history">
      <div className="page-heading">
        <div>
          <p className="eyebrow">CATATAN AKTIVITAS</p>
          <h1>Riwayat<span className="heading-period">.</span></h1>
          <p className="page-intro">Lihat kapan aktivitas diselesaikan atau jadwalnya diubah.</p>
        </div>
      </div>

      {historyResult.error || reminderResult.error ? (
        <DataError />
      ) : events.length ? (
        <section className="content-section history-section" aria-labelledby="history-heading">
          <div className="section-heading">
            <div><p className="section-kicker">TERBARU</p><h2 id="history-heading">Aktivitas</h2></div>
            <span className="section-count">{events.length}</span>
          </div>
          <ol className="history-list">
            {events.map((item) => (
              <li className="history-row" key={item.id}>
                <span className={`history-icon history-${item.event_type}`}><Icon name={item.event_type === "completed" ? "check" : "clock"} width={18} height={18} /></span>
                <div className="history-content"><h3>{names.get(item.reminder_id) ?? "Reminder"}</h3><p>{eventLabels[item.event_type]}</p></div>
                <time className="history-date" dateTime={item.occurred_at}>{new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short" }).format(new Date(item.occurred_at))}</time>
              </li>
            ))}
          </ol>
        </section>
      ) : (
        <EmptyState title="Belum ada riwayat" description="Aktivitas yang kamu selesaikan dan perubahan jadwal akan tercatat di sini." />
      )}
    </AppShell>
  );
}
