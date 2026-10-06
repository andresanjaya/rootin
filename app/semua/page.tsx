import type { Metadata } from "next";
import Link from "next/link";
import { AddReminderButton } from "@/components/add-reminder-button";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { EmptyState } from "@/components/empty-state";
import { ReminderList } from "@/components/reminder-list";
import { requireUser } from "@/lib/auth";
import { getReminders } from "@/lib/reminder-data";
import { pushIsConfigured } from "@/lib/push-server";
import { sortReminders, todayISO, toReminderView } from "@/lib/reminder-model";

export const metadata: Metadata = { title: "Semua" };
export const dynamic = "force-dynamic";

const filters = [
  { id: "all", label: "Semua" },
  { id: "soon", label: "Segera" },
  { id: "overdue", label: "Terlambat" },
  { id: "undated", label: "Tanpa jadwal waktu" },
] as const;
type Filter = (typeof filters)[number]["id"];

export default async function AllPage({ searchParams }: { searchParams: Promise<{ filter?: string; notifications?: string }> }) {
  const params = await searchParams;
  const activeFilter: Filter = filters.find((item) => item.id === params.filter)?.id ?? "all";
  const { supabase, userId } = await requireUser();
  const { reminders: rows, error } = await getReminders(supabase, userId);
  const allReminders = sortReminders(rows.map((row) => toReminderView(row, todayISO())));
  const reminders = allReminders.filter((item) => {
    if (activeFilter === "soon") return item.status === "due" || item.status === "soon";
    if (activeFilter === "overdue") return item.status === "overdue";
    if (activeFilter === "undated") return item.dueDate === null;
    return true;
  });

  return (
    <AppShell active="all">
      <div className="page-heading">
        <div>
          <p className="eyebrow">DAFTAR REMINDER</p>
          <h1>Semua<span className="heading-period">.</span></h1>
          <p className="page-intro">Semua hal yang sedang kamu pantau, di satu tempat.</p>
        </div>
        <AddReminderButton />
      </div>

      {params.notifications === "offer" && !error && allReminders.length === 1 && pushIsConfigured() && <div className="notification-invite"><strong>Ingin diingatkan saat jatuh tempo?</strong><p>Aktifkan notifikasi setelah menambahkan Rootin ke Home Screen pada iPhone.</p><Link className="text-link" href="/pengaturan">Atur notifikasi</Link></div>}

      <nav className="filter-list" aria-label="Filter reminder">
        {filters.map((filter) => (
          <Link key={filter.id} href={filter.id === "all" ? "/semua" : `/semua?filter=${filter.id}`} className={`filter-chip ${activeFilter === filter.id ? "filter-chip-active" : ""}`} aria-current={activeFilter === filter.id ? "page" : undefined}>{filter.label}</Link>
        ))}
      </nav>

      {error ? (
        <DataError />
      ) : reminders.length ? (
        <section className="content-section all-section" aria-labelledby="all-heading">
          <div className="section-heading">
            <div><p className="section-kicker">AKTIF</p><h2 id="all-heading">{activeFilter === "all" ? "Semua reminder" : filters.find((item) => item.id === activeFilter)?.label}</h2></div>
            <span className="section-count">{reminders.length}</span>
          </div>
          <ReminderList reminders={reminders} />
        </section>
      ) : (
        <EmptyState
          title={allReminders.length ? "Tidak ada reminder di sini" : "Belum ada reminder"}
          description={allReminders.length ? "Coba pilih filter lain untuk melihat reminder yang ada." : "Buat reminder pertama untuk mulai mengatur aktivitas rutinmu."}
          action={allReminders.length ? <Link className="text-link" href="/semua">Lihat semua reminder</Link> : <Link className="text-link" href="/baru">Buat reminder pertama</Link>}
        />
      )}
    </AppShell>
  );
}
