"use client";

import { useEffect, useRef, useState, type ChangeEvent, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Button, Card, Input, Label, ListBox, Select, TextArea, TextField } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";
import { prepareProfilePhoto } from "@/lib/profile-photo-client";
import { profileCategoryLabels, type ProfileCategory, type ProfileRow } from "@/lib/profile-model";
import { ProfilePhoto } from "@/components/profile-photo";
import { Icon } from "@/components/icons";

class PhotoActionError extends Error {}

export function ProfileForm({ profile }: { profile?: ProfileRow }) {
  const router = useRouter();
  const [name, setName] = useState(profile?.name ?? "");
  const [category, setCategory] = useState<ProfileCategory>(profile?.category ?? "other");
  const [notes, setNotes] = useState(profile?.notes ?? "");
  const [odometer, setOdometer] = useState(profile?.odometer_km === null || profile?.odometer_km === undefined ? "" : String(profile.odometer_km));
  const [createdId, setCreatedId] = useState<string | null>(null);
  const [photo, setPhoto] = useState<File | null>(null);
  const [removePhoto, setRemovePhoto] = useState(false);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [stage, setStage] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const cameraInput = useRef<HTMLInputElement>(null);
  const galleryInput = useRef<HTMLInputElement>(null);
  const needsOdometer = category === "vehicle" && profile?.category !== "vehicle";

  useEffect(() => {
    if (!photo) { setPreviewUrl(null); return; }
    const url = URL.createObjectURL(photo);
    setPreviewUrl(url);
    return () => URL.revokeObjectURL(url);
  }, [photo]);

  async function choosePhoto(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file) return;
    setBusy(true);
    setStage("Menyiapkan foto…");
    try {
      const prepared = await prepareProfilePhoto(file);
      setError("");
      setPhoto(prepared);
      setRemovePhoto(false);
    } catch (photoError) {
      setPhoto(null);
      setRemovePhoto(false);
      setError(photoError instanceof Error ? photoError.message : "Foto tidak dapat disiapkan. Coba lagi.");
    } finally {
      setBusy(false);
      setStage("");
    }
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy) return;
    setError("");
    const cleanedName = name.trim();
    if (!cleanedName || cleanedName.length > 120) { setError("Nama barang wajib diisi, maksimal 120 karakter."); return; }
    if (notes.trim().length > 2000) { setError("Catatan maksimal 2000 karakter."); return; }
    const reading = category === "vehicle" ? Number(odometer) : null;
    if (category === "vehicle" && (odometer.trim() === "" || !Number.isFinite(reading) || reading! < 0 || !/^\d+(?:\.\d)?$/.test(odometer))) {
      setError("Isi odometer kendaraan dalam km, maksimal satu angka desimal."); return;
    }
    setBusy(true);
    setStage("Menyimpan profil…");
    const supabase = createClient();
    let savingPhoto = false;
    try {
      let targetId = profile?.id ?? createdId;
      if (targetId) {
        const { error: saveError } = await supabase.rpc("update_item_profile", {
          p_profile_id: targetId, p_name: cleanedName, p_category: category,
          p_notes: notes.trim() || null, p_odometer_km: reading,
        });
        if (saveError) throw saveError;
      } else {
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) throw new Error("Sesi berakhir. Masuk kembali.");
        const { data, error: saveError } = await supabase.from("item_profiles")
          .insert({ user_id: user.id, name: cleanedName, category, notes: notes.trim() || null, odometer_km: reading })
          .select("id").single();
        if (saveError || !data) throw saveError ?? new Error("Profil belum tersimpan.");
        targetId = data.id;
        setCreatedId(targetId);
      }
      if (photo) {
        savingPhoto = true;
        setStage("Mengunggah foto…");
        const body = new FormData();
        body.set("photo", photo);
        const response = await fetch(`/api/profile-photo/${targetId}`, { method: "POST", body });
        if (!response.ok) {
          const result = await response.json().catch(() => null);
          throw new PhotoActionError(result?.error ?? "Foto belum terunggah. Coba lagi.");
        }
      } else if (removePhoto && profile?.photo_path) {
        savingPhoto = true;
        setStage("Menghapus foto…");
        const response = await fetch(`/api/profile-photo/${targetId}`, { method: "DELETE" });
        if (!response.ok) {
          const result = await response.json().catch(() => null);
          throw new PhotoActionError(result?.error ?? "Foto belum terhapus. Coba lagi.");
        }
      }
      router.replace(`/barang/${targetId}`);
      router.refresh();
    } catch (saveError) {
      setError(savingPhoto
        ? saveError instanceof PhotoActionError ? saveError.message : "Foto belum tersimpan. Periksa koneksi dan coba lagi."
        : "Profil belum tersimpan. Periksa data dan coba lagi.");
      setBusy(false);
      setStage("");
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
        <div className="profile-photo-field">
          <p className="profile-photo-label">Foto barang <span className="optional">opsional</span></p>
          <div className="profile-photo-editor">
            {previewUrl ? <span className="profile-photo profile-photo-detail"><img src={previewUrl} alt={`Pratinjau foto ${name.trim() || "barang"}`} /></span>
              : profile && !removePhoto ? <ProfilePhoto profile={profile} size="detail" />
                : <span className="profile-photo profile-photo-detail" role="img" aria-label="Belum ada foto"><Icon name="items" width={30} height={30} /></span>}
            <div className="profile-photo-controls">
              <p>{photo ? `${photo.name} · pratinjau sebelum disimpan` : removePhoto ? "Foto akan dihapus saat perubahan disimpan." : "JPG, PNG, atau WebP. HEIC kamera disiapkan otomatis. Maksimal 4 MB setelah diproses."}</p>
              <div className="profile-photo-buttons">
                <Button type="button" variant="secondary" className="secondary-button" onPress={() => cameraInput.current?.click()} isDisabled={busy}>Ambil foto</Button>
                <Button type="button" variant="secondary" className="secondary-button" onPress={() => galleryInput.current?.click()} isDisabled={busy}>Pilih dari galeri</Button>
                {(photo || (profile?.photo_path && !removePhoto)) && <Button type="button" variant="tertiary" onPress={() => { setPhoto(null); setRemovePhoto(Boolean(profile?.photo_path)); setError(""); }} isDisabled={busy}>Hapus foto</Button>}
              </div>
            </div>
          </div>
          <input ref={cameraInput} className="profile-photo-input" type="file" accept="image/*" capture="environment" aria-label="Ambil foto dengan kamera" onChange={choosePhoto} tabIndex={-1} />
          <input ref={galleryInput} className="profile-photo-input" type="file" accept="image/jpeg,image/png,image/webp,image/heic,image/heif,.heic,.heif" aria-label="Pilih gambar dari perangkat" onChange={choosePhoto} tabIndex={-1} />
        </div>
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
    {stage && <p className="settings-help" role="status" aria-live="polite">{stage}</p>}
    <Button type="submit" className="primary-button" isDisabled={busy}>{busy ? "Menyimpan…" : createdId ? "Coba simpan lagi" : profile ? "Simpan perubahan" : "Buat profil"}</Button>
  </form>;
}
