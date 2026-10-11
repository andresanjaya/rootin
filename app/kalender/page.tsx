import type { Metadata } from "next";
import Link from "next/link";
import { AppShell } from "@/components/app-shell";
import { CalendarView } from "@/components/calendar-view";
import { DataError } from "@/components/data-error";
import { requireUser } from "@/lib/auth";
import { getReminders } from "@/lib/reminder-data";
import { todayISO } from "@/lib/reminder-model";

export const metadata: Metadata = { title: "Kalender" };
export const dynamic = "force-dynamic";

export default async function CalendarPage() {
  const { supabase, userId } = await requireUser();
  const { reminders, error } = await getReminders(supabase, userId);
  return <AppShell active="today">
    <Link className="text-link back-link" href="/">← Hari ini</Link>
    <div className="page-heading"><div><p className="eyebrow">JADWAL REMINDER</p><h1>Kalender<span className="heading-period">.</span></h1><p className="page-intro">Lihat tanggal jatuh tempo dan pilih hari untuk membuka reminder.</p></div></div>
    {error ? <DataError /> : <CalendarView reminders={reminders} initialToday={todayISO()} />}
  </AppShell>;
}
