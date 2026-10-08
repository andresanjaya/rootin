import Link from "next/link";
import { Alert, Chip } from "@heroui/react";
import { AddReminderButton } from "@/components/add-reminder-button";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { EmptyState } from "@/components/empty-state";
import { Icon } from "@/components/icons";
import { ReminderList } from "@/components/reminder-list";
import { requireUser } from "@/lib/auth";
import { getReminders } from "@/lib/reminder-data";
import { sortReminders, todayISO, toReminderView } from "@/lib/reminder-model";

export const dynamic = "force-dynamic";

export default async function TodayPage() {
  const { supabase, userId } = await requireUser();
  const { reminders: rows, error } = await getReminders(supabase, userId);
  const reminders = sortReminders(rows.map((row) => toReminderView(row, todayISO())));
  const attention = reminders.filter((item) => item.status === "overdue" || item.status === "due");
  const soon = reminders.filter((item) => item.status === "soon");

  return (
    <AppShell active="today">
      <div className="page-heading">
        <div>
          <p className="eyebrow">RUTINITAS PRIBADI</p>
          <h1>Hari ini<span className="heading-period">.</span></h1>
          <p className="page-intro">Lihat apa yang perlu dilakukan dan apa yang segera tiba.</p>
        </div>
        <AddReminderButton />
      </div>

      {error ? (
        <DataError />
      ) : reminders.length === 0 ? (
        <EmptyState title="Belum ada reminder" description="Buat reminder pertama untuk mulai mencatat kapan sesuatu perlu dilakukan lagi." action={<Link className="text-link" href="/baru">Buat reminder pertama</Link>} />
      ) : (
        <>
          <Alert status="accent" className="summary-strip" aria-label="Ringkasan hari ini">
            <Alert.Indicator><Icon name="calendar" width={18} height={18} /></Alert.Indicator>
            <Alert.Content><Alert.Title>{attention.length} perlu diperhatikan</Alert.Title><Alert.Description>{soon.length} segera</Alert.Description></Alert.Content>
          </Alert>

          <section className="content-section" aria-labelledby="attention-heading">
            <div className="section-heading">
              <div><p className="section-kicker">PRIORITAS</p><h2 id="attention-heading">Perlu dilakukan</h2></div>
              <Chip size="sm" variant="tertiary" className="section-count">{attention.length}</Chip>
            </div>
            {attention.length ? <ReminderList reminders={attention} /> : <p className="section-empty">Tidak ada yang perlu dilakukan saat ini.</p>}
          </section>

          <section className="content-section" aria-labelledby="soon-heading">
            <div className="section-heading">
              <div><p className="section-kicker">MENDATANG</p><h2 id="soon-heading">Segera</h2></div>
              <Chip size="sm" variant="tertiary" className="section-count">{soon.length}</Chip>
            </div>
            {soon.length ? <ReminderList reminders={soon} /> : <p className="section-empty">Belum ada reminder yang segera jatuh tempo.</p>}
          </section>

          <Link className="text-link all-link" href="/semua">Lihat semua reminder <Icon name="arrow" width={16} height={16} /></Link>
        </>
      )}
    </AppShell>
  );
}
