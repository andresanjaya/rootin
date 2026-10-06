import { createClient } from "@/lib/supabase/server";
import { pushIsConfigured, sendToSubscription, type SubscriptionRow } from "@/lib/push-server";

export const runtime = "nodejs";

export async function POST(request: Request) {
  const origin = request.headers.get("origin");
  if (origin && origin !== new URL(request.url).origin) return new Response("Forbidden", { status: 403 });
  if (!pushIsConfigured()) return Response.json({ error: "Push is unavailable." }, { status: 503 });
  const body = await request.json().catch(() => null);
  if (typeof body?.endpoint !== "string" || body.endpoint.length > 2048) return new Response("Bad request", { status: 400 });
  const supabase = await createClient();
  const { data: claims } = await supabase.auth.getClaims();
  const userId = claims?.claims?.sub;
  if (!userId) return new Response("Unauthorized", { status: 401 });
  const { data, error } = await supabase.from("push_subscriptions").select("*")
    .eq("user_id", userId).eq("endpoint", body.endpoint).is("disabled_at", null).maybeSingle();
  if (error || !data) return new Response("Subscription not found", { status: 404 });

  const subscription = data as SubscriptionRow;
  const result = await sendToSubscription(subscription, "Notifikasi uji berhasil. Rootin siap mengingatkanmu.");
  if (!result.sent) {
    if (result.invalid) await supabase.from("push_subscriptions").update({ disabled_at: new Date().toISOString() }).eq("id", subscription.id);
    return Response.json({ error: "Push delivery failed." }, { status: 502 });
  }
  await supabase.from("push_subscriptions").update({ last_success_at: new Date().toISOString() }).eq("id", subscription.id);
  return Response.json({ sent: true });
}
