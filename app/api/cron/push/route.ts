import { adminClient, deliverReminder, pushIsConfigured, type SubscriptionRow } from "@/lib/push-server";
import { dueOccurrence } from "@/lib/push-schedule";
import type { ReminderRow } from "@/lib/reminder-model";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  if (!process.env.CRON_SECRET || request.headers.get("authorization") !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response("Unauthorized", { status: 401 });
  }
  if (!pushIsConfigured()) return Response.json({ error: "Push server is not configured." }, { status: 503 });

  try {
    const admin = adminClient();
    let attempted = 0;
    let sent = 0;
    let lastSubscriptionId: string | null = null;
    const now = new Date();

    while (true) {
      let subscriptionQuery = admin.from("push_subscriptions")
        .select("id,user_id,endpoint,p256dh,auth,time_zone,disabled_at")
        .is("disabled_at", null).order("id").limit(200);
      if (lastSubscriptionId) subscriptionQuery = subscriptionQuery.gt("id", lastSubscriptionId);
      const { data: subscriptions, error } = await subscriptionQuery;
      if (error) throw new Error(error.message);
      if (!subscriptions?.length) break;
      for (const subscription of subscriptions as SubscriptionRow[]) {
        let reminderOffset = 0;
        while (true) {
          const { data: reminders, error: reminderError } = await admin.from("reminders").select("*")
            .eq("user_id", subscription.user_id).eq("schedule_type", "time")
            .eq("notification_enabled", true).is("archived_at", null)
            .order("id").range(reminderOffset, reminderOffset + 199);
          if (reminderError) throw new Error(reminderError.message);
          for (const reminder of (reminders ?? []) as ReminderRow[]) {
            const occurrence = dueOccurrence(reminder, subscription.time_zone, now);
            if (!occurrence) continue;
            attempted++;
            if (await deliverReminder(admin, reminder, subscription, occurrence) === "sent") sent++;
          }
          if (!reminders || reminders.length < 200) break;
          reminderOffset += 200;
        }
      }
      if (subscriptions.length < 200) break;
      lastSubscriptionId = subscriptions[subscriptions.length - 1].id;
    }
    return Response.json({ attempted, sent });
  } catch (error) {
    console.error("Rootin push cron failed:", error);
    return Response.json({ error: "Push job failed." }, { status: 500 });
  }
}
