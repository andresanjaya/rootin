import { createClient } from "@supabase/supabase-js";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

if (!url || !key) {
  console.error("Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY in .env.local.");
  process.exit(1);
}

try {
  const response = await fetch(`${url}/auth/v1/health`, {
    headers: { apikey: key },
    signal: AbortSignal.timeout(10000),
  });

  if (!response.ok) {
    console.error(`Supabase Auth health check failed (HTTP ${response.status}).`);
    process.exit(1);
  }

  console.log("Supabase Auth endpoint reachable.");

  const supabase = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
  const { count, error } = await supabase.from("reminders").select("id", { count: "exact" }).limit(0);

  if (error) {
    if (error.code === "PGRST205") {
      console.log("Rootin reminders table is not available in the public schema yet (PGRST205).");
      process.exitCode = 2;
    } else if (error.code === "42501") {
      console.log("Anonymous access to reminders is denied, as expected.");
    } else {
      console.log(`reminders query failed as an anonymous user (${error.code ?? error.message}).`);
      process.exitCode = 1;
    }
  } else {
    console.log(`reminders query succeeded with the publishable key; ${count ?? "unknown number of"} row(s) visible to an anonymous user.`);
    if (count && count > 0) {
      console.warn("Review RLS: anonymous users can see reminder rows.");
      process.exitCode = 1;
    } else {
      console.warn("Anonymous SELECT is allowed; review table grants even if RLS currently hides rows.");
      process.exitCode = 1;
    }
  }
} catch (error) {
  console.error(`Supabase connection failed: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
}
