import { createClient } from "@/lib/supabase/server";
import { adminClient, deliverReminder, pushIsConfigured, type SubscriptionRow } from "@/lib/push-server";
import { dueOccurrence } from "@/lib/push-schedule";
import type { ReminderRow } from "@/lib/reminder-model";

export const runtime = "nodejs";

export async function POST(request: Request) {
  const origin = request.headers.get("origin");
  if (origin && origin !== new URL(request.url).origin) return new Response("Forbidden", { status: 403 });
  if (!pushIsConfigured()) return Response.json({ error: "Push is unavailable." }, { status: 503 });
  const body = await request.json().catch(() => null);
  if (typeof body?.reminderId !== "string" || !/^[0-9a-f-]{36}$/i.test(body.reminderId)) return new Response("Bad request", { status: 400 });

  const supabase = await createClient();
  const { data: claims } = await supabase.auth.getClaims();
  const userId = claims?.claims?.sub;
  if (!userId) return new Response("Unauthorized", { status: 401 });
  const { data, error } = await supabase.from("reminders").select("*")
    .eq("id", body.reminderId).eq("user_id", userId).maybeSingle();
  if (error || !data) return new Response("Reminder not found", { status: 404 });
  const reminder = data as ReminderRow;
  if (reminder.schedule_type === "time") return new Response("Bad request", { status: 400 });

  try {
    const admin = adminClient();
    const { data: subscriptions, error: subscriptionError } = await admin.from("push_subscriptions").select("*")
      .eq("user_id", userId).is("disabled_at", null);
    if (subscriptionError) throw subscriptionError;
    let sent = 0;
    for (const subscription of (subscriptions ?? []) as SubscriptionRow[]) {
      const occurrence = dueOccurrence(reminder, subscription.time_zone);
      if (occurrence && await deliverReminder(admin, reminder, subscription, occurrence) === "sent") sent++;
    }
    return Response.json({ sent });
  } catch (dispatchError) {
    console.error("Rootin progress push failed:", dispatchError);
    return Response.json({ error: "Push delivery failed." }, { status: 500 });
  }
}
