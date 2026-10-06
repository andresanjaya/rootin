import "server-only";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import webpush from "web-push";
import type { ReminderRow } from "./reminder-model";
import type { PushOccurrence } from "./push-schedule";

export type SubscriptionRow = {
  id: string;
  user_id: string;
  endpoint: string;
  p256dh: string;
  auth: string;
  time_zone: string;
  disabled_at: string | null;
};

export function pushIsConfigured() {
  return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_SECRET_KEY &&
    process.env.NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY && process.env.PUSH_VAPID_PRIVATE_KEY && process.env.CRON_SECRET);
}

export function adminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SECRET_KEY;
  if (!url || !key) throw new Error("Supabase server credentials are missing.");
  return createClient(url, key, { auth: { autoRefreshToken: false, persistSession: false } });
}

function vapidDetails() {
  const publicKey = process.env.NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY;
  const privateKey = process.env.PUSH_VAPID_PRIVATE_KEY;
  if (!publicKey || !privateKey) throw new Error("Web Push VAPID keys are missing.");
  return { subject: process.env.PUSH_VAPID_SUBJECT || "https://rootin-reminder.vercel.app", publicKey, privateKey };
}

export async function sendToSubscription(subscription: SubscriptionRow, body: string, path = "/", tag = "rootin") {
  try {
    await webpush.sendNotification({ endpoint: subscription.endpoint, keys: { p256dh: subscription.p256dh, auth: subscription.auth } },
      JSON.stringify({ body, url: path, tag }), { vapidDetails: vapidDetails(), TTL: 86400, timeout: 10000 });
    return { sent: true as const };
  } catch (error) {
    const status = typeof error === "object" && error && "statusCode" in error ? Number(error.statusCode) : 0;
    return { sent: false as const, invalid: status === 404 || status === 410, code: status ? String(status) : "network" };
  }
}

export async function deliverReminder(admin: SupabaseClient, reminder: ReminderRow, subscription: SubscriptionRow, occurrence: PushOccurrence) {
  const { data: claim, error: claimError } = await admin.from("push_deliveries").insert({
    user_id: reminder.user_id, reminder_id: reminder.id, subscription_id: subscription.id,
    due_key: occurrence.dueKey, notification_type: occurrence.type,
  }).select("id").single();
  if (claimError?.code === "23505") return "duplicate" as const;
  if (claimError || !claim) throw new Error(`Could not claim push delivery: ${claimError?.message ?? "unknown"}`);

  const result = await sendToSubscription(subscription, `Saatnya ${reminder.title}`, `/reminder/${reminder.id}`,
    `${reminder.id}:${occurrence.dueKey}:${occurrence.type}`.slice(0, 32));
  const { error: updateError } = await admin.from("push_deliveries").update({
    sent_at: result.sent ? new Date().toISOString() : null,
    error_code: result.sent ? null : result.code,
  }).eq("id", claim.id);
  if (updateError) throw new Error(`Could not record push result: ${updateError.message}`);
  if (result.sent) {
    await admin.from("push_subscriptions").update({ last_success_at: new Date().toISOString() }).eq("id", subscription.id);
    return "sent" as const;
  }
  if (result.invalid) await admin.from("push_subscriptions").update({ disabled_at: new Date().toISOString() }).eq("id", subscription.id);
  return "failed" as const;
}
