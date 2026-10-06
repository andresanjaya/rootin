"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState, type FormEvent } from "react";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const [mode, setMode] = useState<"login" | "signup">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (new URLSearchParams(window.location.search).get("error") === "callback") {
      setMessage("Konfirmasi akun belum berhasil. Coba masuk kembali.");
    }
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMessage("");
    setBusy(true);
    const supabase = createClient();

    if (mode === "login") {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) {
        setMessage("Email atau kata sandi tidak cocok. Coba lagi.");
        setBusy(false);
        return;
      }
      router.replace("/");
      router.refresh();
      return;
    }

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
    });
    setBusy(false);
    if (error) {
      setMessage(error.message);
    } else if (data.session) {
      router.replace("/");
      router.refresh();
    } else {
      setMessage("Periksa email untuk mengonfirmasi akun, lalu masuk ke Rootin.");
    }
  }

  return (
    <main className="auth-page">
      <div className="auth-panel">
        <span className="brand">rootin<span className="brand-dot">.</span></span>
        <p className="eyebrow auth-eyebrow">AKUN PRIBADI</p>
        <h1>{mode === "login" ? "Masuk ke Rootin" : "Buat akun"}</h1>
        <p className="page-intro">Simpan reminder dan buka kembali di perangkatmu.</p>

        <div className="auth-switch" role="group" aria-label="Pilih alur akun">
          <button type="button" className={mode === "login" ? "auth-switch-active" : ""} onClick={() => { setMode("login"); setMessage(""); }}>Masuk</button>
          <button type="button" className={mode === "signup" ? "auth-switch-active" : ""} onClick={() => { setMode("signup"); setMessage(""); }}>Daftar</button>
        </div>

        <form className="form-stack" onSubmit={submit}>
          <label htmlFor="email">Email</label>
          <input id="email" type="email" autoComplete="email" value={email} onChange={(event) => setEmail(event.target.value)} required />
          <label htmlFor="password">Kata sandi</label>
          <input id="password" type="password" autoComplete={mode === "login" ? "current-password" : "new-password"} minLength={6} value={password} onChange={(event) => setPassword(event.target.value)} required />
          {message && <p className="form-message" role="status">{message}</p>}
          <button className="primary-button" type="submit" disabled={busy}>{busy ? "Memproses…" : mode === "login" ? "Masuk" : "Buat akun"}</button>
        </form>
      </div>
    </main>
  );
}
