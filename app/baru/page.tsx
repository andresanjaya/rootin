import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { ReminderForm } from "@/components/reminder-form";
import { requireUser } from "@/lib/auth";

export const metadata: Metadata = { title: "Buat reminder" };
export const dynamic = "force-dynamic";

export default async function NewReminderPage() {
  await requireUser();
  return (
    <AppShell active="all">
      <div className="page-heading">
        <div><p className="eyebrow">REMINDER BARU</p><h1>Buat reminder<span className="heading-period">.</span></h1><p className="page-intro">Catat terakhir dilakukan dan tentukan kapan perlu diingat lagi.</p></div>
      </div>
      <ReminderForm />
    </AppShell>
  );
}
