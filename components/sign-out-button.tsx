"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

export function SignOutButton() {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  async function signOut() {
    setErrorMessage("");
    setBusy(true);
    const supabase = createClient();
    try {
      if ("serviceWorker" in navigator) {
        const registration = await navigator.serviceWorker.getRegistration("/");
        const subscription = registration && "pushManager" in registration ? await registration.pushManager.getSubscription() : null;
        if (subscription) {
          const { error } = await supabase.from("push_subscriptions").update({ disabled_at: new Date().toISOString() }).eq("endpoint", subscription.endpoint);
          if (error) throw error;
          await subscription.unsubscribe();
        }
      }
    } catch {
      setErrorMessage("Notifikasi perangkat belum bisa dimatikan. Coba lagi sebelum keluar.");
      setBusy(false);
      return;
    }
    const { error } = await supabase.auth.signOut();
    if (error) {
      setErrorMessage("Gagal keluar. Coba lagi.");
      setBusy(false);
      return;
    }
    router.replace("/login");
    router.refresh();
  }

  return <span className="sign-out-wrap"><button type="button" className="sign-out-button" onClick={signOut} disabled={busy}>{busy ? "Keluar…" : "Keluar"}</button>{errorMessage && <span className="sign-out-error" role="alert">{errorMessage}</span>}</span>;
}
