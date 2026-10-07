"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState, type FormEvent } from "react";
import { Button, Card, Input, Label, TextField } from "@heroui/react";
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
      <Card className="auth-panel" variant="default">
        <span className="brand">rootin<span className="brand-dot">.</span></span>
        <p className="eyebrow auth-eyebrow">AKUN PRIBADI</p>
        <h1>{mode === "login" ? "Masuk ke Rootin" : "Buat akun"}</h1>
        <p className="page-intro">Simpan reminder dan buka kembali di perangkatmu.</p>

        <div className="auth-switch" role="group" aria-label="Pilih alur akun">
          <Button type="button" variant={mode === "login" ? "secondary" : "ghost"} className={mode === "login" ? "auth-switch-active" : ""} onPress={() => { setMode("login"); setMessage(""); }}>Masuk</Button>
          <Button type="button" variant={mode === "signup" ? "secondary" : "ghost"} className={mode === "signup" ? "auth-switch-active" : ""} onPress={() => { setMode("signup"); setMessage(""); }}>Daftar</Button>
        </div>

        <form className="form-stack" onSubmit={submit}>
          <TextField name="email" type="email" value={email} onChange={setEmail} isRequired><Label>Email</Label><Input autoComplete="email" /></TextField>
          <TextField name="password" type="password" value={password} onChange={setPassword} isRequired><Label>Kata sandi</Label><Input autoComplete={mode === "login" ? "current-password" : "new-password"} minLength={6} /></TextField>
          {message && <p className="form-message" role="status">{message}</p>}
          <Button className="primary-button" type="submit" isDisabled={busy}>{busy ? "Memproses…" : mode === "login" ? "Masuk" : "Buat akun"}</Button>
        </form>
      </Card>
    </main>
  );
}
