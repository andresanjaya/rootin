"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Button, Card, Input, Label, ListBox, Select, TextArea, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import { profileCategoryLabels, type ProfileCategory, type ProfileRow } from "@/lib/profile-model";

export function ProfileForm({ profile }: { profile?: ProfileRow }) {
  const router = useRouter();
  const [name, setName] = useState(profile?.name ?? "");
  const [category, setCategory] = useState<ProfileCategory>(profile?.category ?? "other");
  const [notes, setNotes] = useState(profile?.notes ?? "");
  const [odometer, setOdometer] = useState(profile?.odometer_km === null || profile?.odometer_km === undefined ? "" : String(profile.odometer_km));
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const needsOdometer = category === "vehicle" && profile?.category !== "vehicle";

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    const cleanedName = name.trim();
    if (!cleanedName || cleanedName.length > 120) { setError("Nama barang wajib diisi, maksimal 120 karakter."); return; }
    if (notes.trim().length > 2000) { setError("Catatan maksimal 2000 karakter."); return; }
    const reading = category === "vehicle" ? Number(odometer) : null;
    if (category === "vehicle" && (odometer.trim() === "" || !Number.isFinite(reading) || reading! < 0 || !/^\d+(?:\.\d)?$/.test(odometer))) {
      setError("Isi odometer kendaraan dalam km, maksimal satu angka desimal."); return;
    }
    setBusy(true);
    const supabase = createClient();
    try {
      if (profile) {
        const { error: saveError } = await supabase.rpc("update_item_profile", {
          p_profile_id: profile.id, p_name: cleanedName, p_category: category,
          p_notes: notes.trim() || null, p_odometer_km: reading,
        });
        if (saveError) throw saveError;
        router.replace(`/barang/${profile.id}`);
      } else {
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) throw new Error("Sesi berakhir. Masuk kembali.");
        const { data, error: saveError } = await supabase.from("item_profiles")
          .insert({ user_id: user.id, name: cleanedName, category, notes: notes.trim() || null, odometer_km: reading })
          .select("id").single();
        if (saveError || !data) throw saveError ?? new Error("Profil belum tersimpan.");
        router.replace(`/barang/${data.id}`);
      }
      router.refresh();
    } catch {
      setError("Profil belum tersimpan. Periksa data dan coba lagi.");
      setBusy(false);
    }
  }

  return <form className="reminder-form" onSubmit={submit} noValidate>
    <Card className="form-section" variant="default">
      <Card.Header><Card.Title>Informasi barang</Card.Title></Card.Header>
      <Card.Content>
        <TextField className="field" name="name" value={name} onChange={setName} isRequired>
          <Label>Nama profil</Label><Input maxLength={120} placeholder="Contoh: Motor, Jaket, Sikat gigi" />
        </TextField>
        <Select className="field" value={category} onChange={(value) => value && setCategory(String(value) as ProfileCategory)}>
          <Label>Kategori</Label>
          <Select.Trigger><Select.Value /><Select.Indicator /></Select.Trigger>
          <Select.Popover><ListBox>
            {(Object.keys(profileCategoryLabels) as ProfileCategory[]).map((key) =>
              <ListBox.Item key={key} id={key} textValue={profileCategoryLabels[key]}>{profileCategoryLabels[key]}<ListBox.ItemIndicator /></ListBox.Item>
            )}
          </ListBox></Select.Popover>
        </Select>
        {needsOdometer && <TextField className="field" name="odometer" type="number" value={odometer} onChange={setOdometer} isRequired>
          <Label>Odometer sekarang (km)</Label><Input min={0} step={0.1} inputMode="decimal" />
        </TextField>}
        {category === "vehicle" && profile?.category === "vehicle" && <p className="settings-help">Odometer terbaru: {new Intl.NumberFormat("id-ID").format(profile.odometer_km ?? 0)} km. Perbarui pembacaan dari halaman profil agar riwayat tercatat.</p>}
        <TextField className="field" name="notes" value={notes} onChange={setNotes}>
          <Label>Catatan <span className="optional">opsional</span></Label><TextArea rows={3} maxLength={2000} placeholder="Detail barang yang ingin disimpan" />
        </TextField>
        {error && <p className="form-message" role="alert">{error}</p>}
      </Card.Content>
    </Card>
    <Button type="submit" className="primary-button" isDisabled={busy}>{busy ? "Menyimpan…" : profile ? "Simpan perubahan" : "Buat profil"}</Button>
  </form>;
}
