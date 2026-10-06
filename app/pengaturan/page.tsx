import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { NotificationSettings } from "@/components/notification-settings";
import { requireUser } from "@/lib/auth";
import { pushIsConfigured } from "@/lib/push-server";

export const metadata: Metadata = { title: "Pengaturan" };
export const dynamic = "force-dynamic";

export default async function SettingsPage() {
  const { supabase, userId } = await requireUser();
  const { count } = await supabase.from("reminders").select("id", { count: "exact", head: true }).eq("user_id", userId).is("archived_at", null);
  const { error: migrationError } = await supabase.from("push_subscriptions").select("time_zone").limit(1);
  return (
    <AppShell active="settings">
      <div className="page-heading">
        <div><p className="eyebrow">PREFERENSI PRIBADI</p><h1>Pengaturan<span className="heading-period">.</span></h1><p className="page-intro">Atur notifikasi untuk perangkat ini.</p></div>
      </div>
      <NotificationSettings userId={userId} hasReminders={Boolean(count)} serverReady={pushIsConfigured() && !migrationError} publicKey={process.env.NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY ?? ""} />
    </AppShell>
  );
}
