import type { SupabaseClient } from "@supabase/supabase-js";
import type { ProfileEvent, ProfileRow } from "./profile-model";

export async function getProfiles(supabase: SupabaseClient, userId: string, includeArchived = false) {
  let query = supabase.from("item_profiles").select("*").eq("user_id", userId);
  if (!includeArchived) query = query.is("archived_at", null);
  const { data, error } = await query.order("created_at", { ascending: false });
  return { profiles: (data ?? []) as ProfileRow[], error };
}

export async function getProfileEvents(supabase: SupabaseClient, userId: string, profileId: string) {
  const { data, error } = await supabase.from("profile_events")
    .select("id,profile_id,event_type,occurred_on,odometer_before_km,odometer_after_km,created_at")
    .eq("user_id", userId).eq("profile_id", profileId)
    .order("created_at", { ascending: false }).limit(100);
  return { events: (data ?? []) as ProfileEvent[], error };
}
