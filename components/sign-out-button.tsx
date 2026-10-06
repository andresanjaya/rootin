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
    const { error } = await createClient().auth.signOut();
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
